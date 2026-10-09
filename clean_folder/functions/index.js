/**
 * ResQ Cloud Functions
 *
 * 1. geminiAssist  - Callable. The ONLY place the Gemini API key lives.
 *                    The app sends a task + text, the server builds the prompt.
 * 2. pushOnBroadcast    - When an admin sends an emergency siren, push it to every
 *                         resident phone (works even when the app is closed).
 * 3. pushOnNotification - When a personal notification is created (status change,
 *                         neighbour corroboration), push it to that resident's phones.
 *
 * Setup (once):  firebase functions:secrets:set GEMINI_API_KEY
 * Deploy:        firebase deploy --only functions
 */

const functions = require("firebase-functions/v1");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

// Closest Google region to Metro Manila.
const REGION = "asia-southeast1";
const GEMINI_MODEL = "gemini-3.5-flash";
const EMERGENCY_TOPIC = "resq_emergency_broadcasts";
const ANDROID_CHANNEL_ID = "resq_emergency_alerts_v3";

// Per-user AI limit, protects the Gemini bill from abuse.
const AI_LIMIT_PER_MINUTE = 10;

// ───────────────────────────────────────────────────────────────────
// Helpers
// ───────────────────────────────────────────────────────────────────

function cleanText(value, maxLength) {
  if (typeof value !== "string") return "";
  return value.trim().slice(0, maxLength);
}

function stripCodeFences(text) {
  return text.replace(/```json/g, "").replace(/```/g, "").trim();
}

async function assertActiveUser(uid) {
  const snap = await db.collection("users").doc(uid).get();
  if (snap.exists && snap.get("isActive") === false) {
    throw new functions.https.HttpsError(
      "permission-denied",
      "This account has been suspended.",
    );
  }
}

async function enforceRateLimit(uid) {
  const ref = db.collection("ai_usage").doc(uid);
  await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    const now = Date.now();
    const windowStart = snap.exists ? snap.get("windowStart") || 0 : 0;
    const count = snap.exists ? snap.get("count") || 0 : 0;

    if (now - windowStart > 60 * 1000) {
      tx.set(ref, { windowStart: now, count: 1 });
      return;
    }
    if (count >= AI_LIMIT_PER_MINUTE) {
      throw new functions.https.HttpsError(
        "resource-exhausted",
        "Too many AI requests. Please wait a minute and try again.",
      );
    }
    tx.update(ref, { count: count + 1 });
  });
}

async function callGemini(apiKey, body) {
  const url =
    `https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL}` +
    `:generateContent?key=${apiKey}`;

  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), 25000);
  try {
    const response = await fetch(url, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(body),
      signal: controller.signal,
    });
    if (!response.ok) {
      functions.logger.error("Gemini error", response.status, await response.text());
      throw new functions.https.HttpsError("unavailable", "AI service is busy. Please try again.");
    }
    const json = await response.json();
    const text = json?.candidates?.[0]?.content?.parts?.[0]?.text;
    if (typeof text !== "string" || text.length === 0) {
      throw new functions.https.HttpsError("internal", "AI returned an empty answer.");
    }
    return text;
  } catch (error) {
    if (error instanceof functions.https.HttpsError) throw error;
    functions.logger.error("Gemini request failed", error);
    throw new functions.https.HttpsError("unavailable", "AI service could not be reached.");
  } finally {
    clearTimeout(timer);
  }
}

// ───────────────────────────────────────────────────────────────────
// Prompts (kept on the server so the endpoint can't be used as a free,
// general-purpose Gemini proxy)
// ───────────────────────────────────────────────────────────────────

function triageRequest(narrative) {
  const prompt = `You are an expert emergency response dispatcher for Barangay Moonwalk.
Evaluate the following incident narrative and determine the urgency of the situation.
You must reply ONLY in raw, valid JSON format without any markdown wrappers or additional text.
The JSON must have exactly two keys:
1. "urgency": strictly either "LOW", "MEDIUM", or "HIGH".
2. "justification": a brief 1-2 sentence explanation for the urgency level.

Narrative: "${narrative}"`;
  return {
    contents: [{ parts: [{ text: prompt }] }],
    generationConfig: { responseMimeType: "application/json" },
  };
}

function precautionsRequest(category, narrative, location) {
  const prompt = `You are an expert civil defense and emergency safety officer for Barangay Moonwalk.
A resident has reported the following incident:
- Category: "${category}"
- Details: "${narrative}"
- Location: "${location || "Barangay Moonwalk"}"

Generate 3 to 4 concise, immediate, life-safety precautionary actions or first-aid instructions that the resident must take RIGHT NOW while waiting for emergency responders to arrive.
Rules:
- Be clear, direct, and actionable.
- Prioritize life safety, evacuation if necessary, avoiding secondary hazards.
- Output ONLY a raw, valid JSON array of strings, e.g.:
["Evacuate the structure immediately and stay upwind.", "Turn off main power breaker if safe to do so.", "Do not use elevators or re-enter for belongings."]
- Do NOT include markdown code blocks, intro, or explanations. Return only the JSON array.`;
  return {
    contents: [{ parts: [{ text: prompt }] }],
    generationConfig: { responseMimeType: "application/json" },
  };
}

const ASSISTANT_SYSTEM_PROMPT = `You are the ResQ Civil Defense Emergency & Safety Assistant for Barangay Moonwalk.
Your mission: Deliver immediate, life-saving civil defense, disaster preparedness, and first-aid instructions to residents during safety crises and everyday inquiries.

Core Directives:
1. Immediate Life Safety First: If the resident's query involves active fire, raging flood, armed violence, structural collapse, gas leaks, or severe medical trauma, FIRST instruct them to evacuate or seek safe cover, call 911 or the Barangay Moonwalk Emergency Desk, and protect life over property.
2. Step-by-Step Clarity: Provide concise, numbered, easy-to-read instructions (e.g. 1., 2., 3.). In an emergency, people cannot read long walls of text. Keep responses direct and actionable.
3. Localized to Barangay Moonwalk, Parañaque: Aware of local context (emergency hotlines: National 911, Philippine Red Cross 143, Barangay Moonwalk Emergency Desk 888-9999).
4. Language Adaptability: Respond fluently in English, Tagalog, or Taglish depending on the resident's phrasing.
5. Basic First-Aid: Provide recognized basic first-aid steps (e.g., direct pressure for bleeding, cool water for minor burns, recovery position for unconscious breathing victims). Never attempt speculative clinical diagnosis.
6. Clean Complete Output: Ensure the response is fully completed and not cut off. Use clean text formatting with simple numbers or bullet points.`;

function assistantRequest(message, history) {
  const contents = [];
  const recent = Array.isArray(history) ? history.slice(-6) : [];
  for (const item of recent) {
    const text = cleanText(item?.text, 2000);
    if (!text) continue;
    contents.push({
      role: item?.role === "user" ? "user" : "model",
      parts: [{ text }],
    });
  }
  contents.push({ role: "user", parts: [{ text: message }] });

  return {
    systemInstruction: { parts: [{ text: ASSISTANT_SYSTEM_PROMPT }] },
    contents,
    generationConfig: {
      temperature: 0.3,
      maxOutputTokens: 2048,
      thinkingConfig: { thinkingBudget: 0 },
    },
  };
}

// ───────────────────────────────────────────────────────────────────
// 1. Gemini proxy
// ───────────────────────────────────────────────────────────────────

exports.geminiAssist = functions
  .region(REGION)
  .runWith({ secrets: ["GEMINI_API_KEY"], timeoutSeconds: 60, memory: "256MB" })
  .https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError("unauthenticated", "Please sign in first.");
    }
    const uid = context.auth.uid;
    await assertActiveUser(uid);
    await enforceRateLimit(uid);

    const apiKey = process.env.GEMINI_API_KEY;
    if (!apiKey) {
      throw new functions.https.HttpsError("failed-precondition", "AI is not configured on the server.");
    }

    const task = data?.task;

    if (task === "triage") {
      const narrative = cleanText(data?.narrative, 2000);
      if (!narrative) throw new functions.https.HttpsError("invalid-argument", "Narrative is required.");
      const text = await callGemini(apiKey, triageRequest(narrative));
      try {
        const parsed = JSON.parse(stripCodeFences(text));
        return {
          urgency: String(parsed.urgency || "MEDIUM").toUpperCase(),
          justification: String(parsed.justification || ""),
        };
      } catch (_) {
        throw new functions.https.HttpsError("internal", "AI answer could not be read.");
      }
    }

    if (task === "precautions") {
      const category = cleanText(data?.category, 200);
      const narrative = cleanText(data?.narrative, 2000);
      const location = cleanText(data?.location, 300);
      if (!category) throw new functions.https.HttpsError("invalid-argument", "Category is required.");
      const text = await callGemini(apiKey, precautionsRequest(category, narrative, location));
      try {
        const parsed = JSON.parse(stripCodeFences(text));
        let list = [];
        if (Array.isArray(parsed)) list = parsed;
        else if (parsed && typeof parsed === "object") {
          const firstArray = Object.values(parsed).find((v) => Array.isArray(v));
          if (firstArray) list = firstArray;
        }
        return {
          measures: list.map((v) => String(v).trim()).filter((v) => v.length > 0).slice(0, 6),
        };
      } catch (_) {
        throw new functions.https.HttpsError("internal", "AI answer could not be read.");
      }
    }

    if (task === "assistant") {
      const message = cleanText(data?.message, 1000);
      if (!message) throw new functions.https.HttpsError("invalid-argument", "Message is required.");
      const text = await callGemini(apiKey, assistantRequest(message, data?.history));
      return { reply: text.trim() };
    }

    throw new functions.https.HttpsError("invalid-argument", "Unknown AI task.");
  });

// ───────────────────────────────────────────────────────────────────
// 2. Emergency siren → push to every resident phone
// ───────────────────────────────────────────────────────────────────

exports.pushOnBroadcast = functions
  .region(REGION)
  .firestore.document("broadcasts/{broadcastId}")
  .onCreate(async (snap, context) => {
    const b = snap.data() || {};
    if (b.isActive === false) return null;

    const title = `🚨 ${cleanText(b.title, 120) || "Emergency Alert"}`;
    const details = [cleanText(b.alertType, 60), cleanText(b.sector, 80)]
      .filter((v) => v)
      .join(" • ");
    const message = cleanText(b.message, 400) || "Immediate safety precautions advised by authorities.";
    const body = details ? `[${details}] ${message}` : message;

    await admin.messaging().send({
      topic: EMERGENCY_TOPIC,
      notification: { title, body },
      data: {
        origin: "resq_functions",
        type: "siren",
        broadcastId: context.params.broadcastId,
      },
      android: {
        priority: "high",
        notification: {
          channelId: ANDROID_CHANNEL_ID,
          sound: "resq_alert",
          defaultVibrateTimings: true,
        },
      },
      apns: {
        payload: { aps: { sound: "resq_alert.wav" } },
      },
    });
    functions.logger.info("Siren pushed", context.params.broadcastId);
    return null;
  });

// ───────────────────────────────────────────────────────────────────
// 3. Personal notification → push to that resident's phones
// ───────────────────────────────────────────────────────────────────

const SHARED_OR_DESK = new Set(["all_residents", "broadcast", "admin"]);

exports.pushOnNotification = functions
  .region(REGION)
  .firestore.document("notifications/{notifId}")
  .onCreate(async (snap) => {
    const n = snap.data() || {};
    const recipientId = n.recipientId;
    // Shared alerts are covered by pushOnBroadcast; the admin desk is a web page.
    if (!recipientId || SHARED_OR_DESK.has(recipientId)) return null;

    const userRef = db.collection("users").doc(recipientId);
    const userSnap = await userRef.get();
    const tokens = (userSnap.exists && userSnap.get("fcmTokens")) || [];
    if (!Array.isArray(tokens) || tokens.length === 0) return null;

    const response = await admin.messaging().sendEachForMulticast({
      tokens: tokens.slice(0, 500),
      notification: {
        title: cleanText(n.title, 120) || "ResQ Update",
        body: cleanText(n.message, 400),
      },
      data: {
        origin: "resq_functions",
        type: String(n.type || "general"),
        incidentId: String(n.incidentId || ""),
      },
      android: {
        priority: "high",
        notification: { channelId: ANDROID_CHANNEL_ID, sound: "resq_alert" },
      },
    });

    // Remove tokens from uninstalled apps / logged-out phones.
    const deadTokens = [];
    response.responses.forEach((r, i) => {
      const code = r.error?.code || "";
      if (
        code === "messaging/registration-token-not-registered" ||
        code === "messaging/invalid-registration-token"
      ) {
        deadTokens.push(tokens[i]);
      }
    });
    if (deadTokens.length > 0) {
      await userRef.update({
        fcmTokens: admin.firestore.FieldValue.arrayRemove(...deadTokens),
      });
    }
    return null;
  });
