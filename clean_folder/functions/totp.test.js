/**
 * Dependency-free checks for totp.js. Run: node functions/totp.test.js
 */

const assert = require("assert");
const totp = require("./totp");

let failures = 0;
function check(name, fn) {
  try {
    fn();
    console.log(`ok   ${name}`);
  } catch (error) {
    failures++;
    console.error(`FAIL ${name}\n     ${error.message}`);
  }
}

// RFC 6238 Appendix B, SHA-1 (8-digit codes there; the last 6 digits here).
const rfcSecret = totp.base32Encode(Buffer.from("12345678901234567890", "ascii"));
const vectors = [
  [59, "287082"],
  [1111111109, "081804"],
  [1111111111, "050471"],
  [1234567890, "005924"],
  [2000000000, "279037"],
];

check("RFC 4648 Base32 of the RFC 6238 key", () => {
  assert.strictEqual(rfcSecret, "GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ");
});

for (const [seconds, expected] of vectors) {
  check(`RFC 6238 SHA-1 vector at T=${seconds}`, () => {
    assert.strictEqual(totp.codeAt(rfcSecret, seconds * 1000), expected);
    assert.ok(totp.verify(rfcSecret, expected, seconds * 1000));
  });
}

check("Base32 round-trips random bytes of every length", () => {
  for (let len = 0; len <= 25; len++) {
    const bytes = require("crypto").randomBytes(len);
    assert.deepStrictEqual(totp.base32Decode(totp.base32Encode(bytes)), bytes);
  }
});

check("Base32 decode ignores case, spaces and padding (like the Dart code)", () => {
  assert.deepStrictEqual(
    totp.base32Decode("gezd gnbv gy3t qojq gezd gnbv gy3t qojq=="),
    Buffer.from("12345678901234567890", "ascii"),
  );
  assert.throws(() => totp.base32Decode("NOT-BASE32!"));
});

check("generateSecret is 160 bits, 32 Base32 characters, random", () => {
  const a = totp.generateSecret();
  const b = totp.generateSecret();
  assert.match(a, /^[A-Z2-7]{32}$/);
  assert.strictEqual(totp.base32Decode(a).length, 20);
  assert.notStrictEqual(a, b);
});

// A code the Dart algorithm (lib/core/security/totp.dart, Totp.codeAt) made for
// the secret used in test/features/admin_dashboard/presentation/admin_mfa_gate_test.dart,
// at 2026-01-01T00:00:00Z. test/core/security/totp_test.dart asserts the same
// value from the Dart side ("same code as the Cloud Function"), so the two
// implementations are pinned to each other.
const DART_SECRET = "JBSWY3DPEHPK3PXPJBSWY3DPEHPK3PXP";
const DART_TIME_MS = Date.UTC(2026, 0, 1);
const DART_CODE = "452777";

check("matches a code from the Dart Totp.codeAt", () => {
  assert.strictEqual(totp.codeAt(DART_SECRET, DART_TIME_MS), DART_CODE);
});

check("accepts the previous and next step, rejects two steps away", () => {
  const now = 1700000000000;
  const prev = totp.codeAt(rfcSecret, now - 30000);
  const next = totp.codeAt(rfcSecret, now + 30000);
  const far = totp.codeAt(rfcSecret, now + 60000);
  assert.strictEqual(totp.matchStep(rfcSecret, prev, now), totp.stepAt(now) - 1);
  assert.strictEqual(totp.matchStep(rfcSecret, next, now), totp.stepAt(now) + 1);
  if (far !== prev && far !== next && far !== totp.codeAt(rfcSecret, now)) {
    assert.strictEqual(totp.verify(rfcSecret, far, now), false);
  }
});

check("rejects malformed codes", () => {
  for (const bad of ["", "12345", "1234567", "abcdef", null, undefined, 123456]) {
    assert.strictEqual(totp.verify(rfcSecret, bad, 59000), false, String(bad));
  }
  assert.ok(totp.verify(rfcSecret, "287 082", 59000), "spaces are ignored");
});

if (failures > 0) {
  console.error(`\n${failures} check(s) failed`);
  process.exit(1);
}
console.log("\nall TOTP checks passed");
