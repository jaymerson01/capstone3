import 'package:flutter_test/flutter_test.dart';
import 'package:community_safety_app/core/security/totp.dart';

void main() {
  // RFC 6238 appendix B: the SHA-1 secret "12345678901234567890", last 6 digits.
  const rfcSecret = 'GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ';
  DateTime at(int seconds) => DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: true);

  test('matches the RFC 6238 test vectors', () {
    expect(Totp.codeAt(rfcSecret, at(59)), '287082');
    expect(Totp.codeAt(rfcSecret, at(1111111109)), '081804');
    expect(Totp.codeAt(rfcSecret, at(1234567890)), '005924');
    expect(Totp.codeAt(rfcSecret, at(2000000000)), '279037');
  });

  test('accepts the code one step either side, not further', () {
    final now = at(1234567890);
    expect(Totp.verify(rfcSecret, '005924', now: now), isTrue);
    expect(Totp.verify(rfcSecret, Totp.codeAt(rfcSecret, at(1234567860)), now: now), isTrue);
    expect(Totp.verify(rfcSecret, Totp.codeAt(rfcSecret, at(1234567800)), now: now), isFalse);
    expect(Totp.verify(rfcSecret, '005 924', now: now), isTrue);
    expect(Totp.verify(rfcSecret, '00592', now: now), isFalse);
  });

  test('new secrets are 32 Base32 characters and work', () {
    final secret = Totp.generateSecret();
    expect(secret, matches(RegExp(r'^[A-Z2-7]{32}$')));
    final now = DateTime.now();
    expect(Totp.verify(secret, Totp.codeAt(secret, now), now: now), isTrue);
  });

  test('same code as the Cloud Function (functions/totp.test.js)', () {
    // The server checks codes with functions/totp.js; this pins both to one value.
    expect(
      Totp.codeAt('JBSWY3DPEHPK3PXPJBSWY3DPEHPK3PXP', DateTime.utc(2026, 1, 1)),
      '452777',
    );
  });

  test('builds the authenticator link', () {
    expect(
      Totp.otpauthUri(secret: 'ABC', account: 'desk@resq.ph'),
      'otpauth://totp/ResQ%20Admin%3Adesk%40resq.ph?secret=ABC&issuer=ResQ%20Admin'
      '&algorithm=SHA1&digits=6&period=30',
    );
  });
}
