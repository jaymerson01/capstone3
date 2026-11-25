/**
 * Time-based one-time codes (RFC 6238) for admin two-step sign-in.
 *
 * Must stay identical to lib/core/security/totp.dart: SHA-1, 6 digits,
 * 30-second steps, ±1 step for a phone clock that is slightly off, and the
 * same Base32 alphabet (RFC 4648, no padding) for the secret.
 * Node's built-in crypto only: no npm packages.
 */

const crypto = require("crypto");

const DIGITS = 6;
const STEP_SECONDS = 30;
const ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567";

function base32Encode(bytes) {
  let out = "";
  let buffer = 0;
  let bits = 0;
  for (const byte of bytes) {
    buffer = ((buffer << 8) | byte) & 0xffff;
    bits += 8;
    while (bits >= 5) {
      out += ALPHABET[(buffer >> (bits - 5)) & 31];
      bits -= 5;
    }
  }
  if (bits > 0) out += ALPHABET[(buffer << (5 - bits)) & 31];
  return out;
}

function base32Decode(input) {
  const cleaned = String(input).toUpperCase().replace(/[\s=]/g, "");
  const out = [];
  let buffer = 0;
  let bits = 0;
  for (const char of cleaned) {
    const value = ALPHABET.indexOf(char);
    if (value < 0) throw new Error("Not a Base32 secret");
    buffer = ((buffer << 5) | value) & 0xffff;
    bits += 5;
    if (bits >= 8) {
      out.push((buffer >> (bits - 8)) & 0xff);
      bits -= 8;
    }
  }
  return Buffer.from(out);
}

/** A new random secret: 160 bits (as RFC 4226 recommends), Base32 encoded. */
function generateSecret() {
  return base32Encode(crypto.randomBytes(20));
}

/** The 30-second step number for [timeMs] (milliseconds since 1970). */
function stepAt(timeMs) {
  return Math.floor(timeMs / 1000 / STEP_SECONDS);
}

/** The code for step [counter], using raw key bytes [key]. */
function hotp(key, counter) {
  const message = Buffer.alloc(8);
  message.writeBigUInt64BE(BigInt(counter));
  const hash = crypto.createHmac("sha1", key).update(message).digest();
  const offset = hash[hash.length - 1] & 0x0f;
  const binary =
    ((hash[offset] & 0x7f) << 24) |
    (hash[offset + 1] << 16) |
    (hash[offset + 2] << 8) |
    hash[offset + 3];
  return String(binary % 10 ** DIGITS).padStart(DIGITS, "0");
}

/** The code at [timeMs] for a Base32 [secret]. */
function codeAt(secret, timeMs) {
  return hotp(base32Decode(secret), stepAt(timeMs));
}

/**
 * The step [code] matches, within [window] steps of [nowMs], or null.
 * Compared in constant time.
 */
function matchStep(secret, code, nowMs = Date.now(), window = 1) {
  const cleaned = String(code ?? "").replace(/\s/g, "");
  if (!new RegExp(`^\\d{${DIGITS}}$`).test(cleaned)) return null;
  const key = base32Decode(secret);
  const now = stepAt(nowMs);
  let found = null;
  for (let i = -window; i <= window; i++) {
    const expected = Buffer.from(hotp(key, now + i));
    if (crypto.timingSafeEqual(expected, Buffer.from(cleaned)) && found === null) {
      found = now + i;
    }
  }
  return found;
}

/** Whether [code] is right at [nowMs] (±[window] steps). */
function verify(secret, code, nowMs = Date.now(), window = 1) {
  return matchStep(secret, code, nowMs, window) !== null;
}

module.exports = {
  DIGITS,
  STEP_SECONDS,
  base32Encode,
  base32Decode,
  generateSecret,
  stepAt,
  hotp,
  codeAt,
  matchStep,
  verify,
};
