// Security checks for firestore.rules, run against the Firebase emulator.
//
//   cd rules_test && npm install   (once)
//   npx firebase emulators:exec --only firestore --project demo-resq "node --test firestore.rules.test.cjs"
//
// Each test signs in as a different kind of user and checks what the rules
// allow and refuse. Nothing here touches the real database.
const { test, before, after, beforeEach } = require('node:test');
const fs = require('node:fs');
const path = require('node:path');
const {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} = require('@firebase/rules-unit-testing');
const {
  doc, getDoc, setDoc, updateDoc, deleteDoc, addDoc, collection, collectionGroup,
  query, where, getDocs, writeBatch, serverTimestamp, Timestamp,
} = require('firebase/firestore');

const EVIDENCE = 'https://res.cloudinary.com/g45cmboy/image/upload/v1/report.jpg';
const SIGN_IN = 1000; // auth_time of the admin's verified sign-in
let env;

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-resq',
    firestore: { rules: fs.readFileSync(path.join(__dirname, '..', 'firestore.rules'), 'utf8') },
  });
});

after(async () => { await env.cleanup(); });

beforeEach(async () => {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    const future = Timestamp.fromMillis(Date.now() + 3600e3);
    await setDoc(doc(db, 'users/resA'), { role: 'resident', isActive: true, isVerified: true });
    await setDoc(doc(db, 'users/resB'), { role: 'resident', isActive: true, isVerified: false });
    await setDoc(doc(db, 'users/resC'), { role: 'resident', isActive: true, isVerified: true });
    await setDoc(doc(db, 'users/admin1'), { role: 'admin', isActive: true });
    await setDoc(doc(db, 'users/super1'), { role: 'admin', isActive: true, isSuperAdmin: true });
    await setDoc(doc(db, 'users/resp1'), { role: 'responder', isActive: true, department: 'tanod' });
    await setDoc(doc(db, 'admin_sessions/admin1'), { authTime: SIGN_IN, expiresAt: future });
    await setDoc(doc(db, 'admin_sessions/super1'), { authTime: SIGN_IN, expiresAt: future });
    await setDoc(doc(db, 'admin_mfa/admin1'), { secret: 'JBSWY3DPEHPK3PXP', email: 'a@x.ph' });
    await setDoc(doc(db, 'incidents/inc1'), {
      reporterId: 'resA', category: 'Fire', description: 'Sunog', status: 'pending',
    });
    await setDoc(doc(db, 'incidents/inc1/confidential/contact'), {
      reporterId: 'resA', reporterName: 'Ana', photoUrl: EVIDENCE,
    });
  });
});

const as = (uid, authTime = SIGN_IN) => env.authenticatedContext(uid, { auth_time: authTime }).firestore();

// ── Evidence and contact details ─────────────────────────────────────────
test('another verified resident cannot see the evidence or contact details', async () => {
  await assertSucceeds(getDoc(doc(as('resC'), 'incidents/inc1')));
  await assertFails(getDoc(doc(as('resC'), 'incidents/inc1/confidential/contact')));
});

test('the reporter, an admin and the assigned responder can see the evidence', async () => {
  await assertSucceeds(getDoc(doc(as('resA'), 'incidents/inc1/confidential/contact')));
  await assertSucceeds(getDocs(query(collectionGroup(as('resA'), 'confidential'), where('reporterId', '==', 'resA'))));
  await assertSucceeds(getDoc(doc(as('admin1'), 'incidents/inc1/confidential/contact')));
  await assertFails(getDoc(doc(as('resp1'), 'incidents/inc1/confidential/contact')));
  await env.withSecurityRulesDisabled((ctx) =>
    updateDoc(doc(ctx.firestore(), 'incidents/inc1'), { assignedResponderId: 'resp1' }));
  await assertSucceeds(getDoc(doc(as('resp1'), 'incidents/inc1/confidential/contact')));
});

test('a new report cannot put evidence or contact details in the public document', async () => {
  const db = as('resA');
  const base = { reporterId: 'resA', category: 'Fire', description: 'Usok', status: 'pending' };
  await assertFails(setDoc(doc(db, 'incidents/x1'), { ...base, photoUrl: EVIDENCE }));
  await assertFails(setDoc(doc(db, 'incidents/x2'), { ...base, reporterName: 'Ana' }));
  await assertSucceeds(setDoc(doc(db, 'incidents/x3'), base));
});

test('report text has length limits', async () => {
  const db = as('resA');
  await assertFails(setDoc(doc(db, 'incidents/long'), {
    reporterId: 'resA', category: 'Fire', status: 'pending', description: 'x'.repeat(3001),
  }));
  await assertFails(setDoc(doc(db, 'incidents/badgps'), {
    reporterId: 'resA', category: 'Fire', status: 'pending', latitude: 999,
  }));
});

test('evidence links must be ResQ Cloudinary links', async () => {
  const db = as('resA');
  const ok = writeBatch(db);
  ok.set(doc(db, 'incidents/y1'), { reporterId: 'resA', category: 'Fire', status: 'pending' });
  ok.set(doc(db, 'incidents/y1/confidential/contact'), { reporterId: 'resA', photoUrl: EVIDENCE });
  await assertSucceeds(ok.commit());

  const bad = writeBatch(db);
  bad.set(doc(db, 'incidents/y2'), { reporterId: 'resA', category: 'Fire', status: 'pending' });
  bad.set(doc(db, 'incidents/y2/confidential/contact'), { reporterId: 'resA', photoUrl: 'https://evil.example/x.jpg' });
  await assertFails(bad.commit());
});

test('the reporter may change the photo only while the report is pending', async () => {
  const ref = (db) => doc(db, 'incidents/inc1/confidential/contact');
  await assertSucceeds(updateDoc(ref(as('resA')), { photoUrl: EVIDENCE.replace('report', 'new') }));
  await assertFails(updateDoc(ref(as('resA')), { reporterName: 'Someone else' }));
  await assertFails(updateDoc(ref(as('resC')), { photoUrl: EVIDENCE }));
  await env.withSecurityRulesDisabled((ctx) =>
    updateDoc(doc(ctx.firestore(), 'incidents/inc1'), { status: 'in_progress' }));
  await assertFails(updateDoc(ref(as('resA')), { photoUrl: EVIDENCE }));
});

// ── Admin two-step verification ──────────────────────────────────────────
test('an admin with a verified two-step session has admin rights', async () => {
  await assertSucceeds(getDoc(doc(as('admin1'), 'users/resA')));
});

test('a stolen admin password (new sign-in, no code) gets no admin rights', async () => {
  const thief = as('admin1', SIGN_IN + 5000);
  await assertFails(getDoc(doc(thief, 'users/resA')));
  await assertFails(updateDoc(doc(thief, 'incidents/inc1'), { status: 'resolved' }));
  await assertFails(getDoc(doc(thief, 'incidents/inc1/confidential/contact')));
});

test('an expired two-step session gets no admin rights', async () => {
  await env.withSecurityRulesDisabled((ctx) =>
    setDoc(doc(ctx.firestore(), 'admin_sessions/admin1'),
      { authTime: SIGN_IN, expiresAt: Timestamp.fromMillis(Date.now() - 1000) }));
  await assertFails(getDoc(doc(as('admin1'), 'users/resA')));
});

test('nobody can read authenticator keys or forge a session from the app', async () => {
  await assertFails(getDoc(doc(as('admin1'), 'admin_mfa/admin1')));
  await assertFails(setDoc(doc(as('admin1'), 'admin_mfa/admin1'), { secret: 'X', email: 'a', enabledAt: 1 }));
  await assertFails(setDoc(doc(as('admin1', 9999), 'admin_sessions/admin1'),
    { authTime: 9999, expiresAt: Timestamp.fromMillis(Date.now() + 1e7) }));
  await assertSucceeds(getDoc(doc(as('admin1'), 'admin_sessions/admin1')));
  await assertFails(getDoc(doc(as('resA'), 'admin_sessions/admin1')));
});

test('a resident cannot make themselves an admin', async () => {
  await assertFails(updateDoc(doc(as('resA'), 'users/resA'), { role: 'admin' }));
  await assertFails(updateDoc(doc(as('resB'), 'users/resB'), { isVerified: true }));
});

test('a regular admin cannot suspend or delete another admin; a super admin can', async () => {
  await assertFails(updateDoc(doc(as('admin1'), 'users/super1'), { isActive: false }));
  await assertFails(deleteDoc(doc(as('admin1'), 'users/super1')));
  await assertSucceeds(updateDoc(doc(as('admin1'), 'users/resB'), { isVerified: true }));
  await assertSucceeds(updateDoc(doc(as('super1'), 'users/admin1'), { isActive: false }));
});

test('a suspended admin loses admin rights', async () => {
  await env.withSecurityRulesDisabled((ctx) =>
    updateDoc(doc(ctx.firestore(), 'users/admin1'), { isActive: false }));
  await assertFails(getDoc(doc(as('admin1'), 'users/resA')));
});

// ── Audit logs ───────────────────────────────────────────────────────────
test('audit log entries carry the real admin and the server time', async () => {
  const db = as('admin1');
  const entry = { adminName: 'A', adminEmail: 'a@x.ph', actionType: 'Test', details: 'ok' };
  await assertSucceeds(addDoc(collection(db, 'audit_logs'), { ...entry, adminUid: 'admin1', timestamp: serverTimestamp() }));
  await assertFails(addDoc(collection(db, 'audit_logs'), { ...entry, adminUid: 'super1', timestamp: serverTimestamp() }));
  await assertFails(addDoc(collection(db, 'audit_logs'), { ...entry, adminUid: 'admin1', timestamp: Timestamp.fromMillis(0) }));
  await assertFails(addDoc(collection(as('resA'), 'audit_logs'), { ...entry, adminUid: 'resA', timestamp: serverTimestamp() }));
});
