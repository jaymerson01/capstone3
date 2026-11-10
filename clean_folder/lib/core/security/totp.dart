import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// Time-based one-time codes (RFC 6238), as shown by Google Authenticator,
/// Microsoft Authenticator and similar apps: 6 digits, a new one every 30 s.
class Totp {
  const Totp._();

  static const int digits = 6;
  static const Duration step = Duration(seconds: 30);
  static const String _alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';

  /// A new random secret, Base32 encoded (160 bits, as RFC 4226 recommends).
  static String generateSecret([Random? random]) {
    final rng = random ?? Random.secure();
    return _base32Encode(Uint8List.fromList(List.generate(20, (_) => rng.nextInt(256))));
  }

  /// The link an authenticator app reads from the setup QR code.
  static String otpauthUri({
    required String secret,
    required String account,
    String issuer = 'ResQ Admin',
  }) {
    final label = Uri.encodeComponent('$issuer:$account');
    return 'otpauth://totp/$label?secret=$secret&issuer=${Uri.encodeComponent(issuer)}'
        '&algorithm=SHA1&digits=$digits&period=${step.inSeconds}';
  }

  /// The code for [time].
  static String codeAt(String secret, DateTime time) {
    // The 30-second step count as 8 big-endian bytes, written by hand:
    // ByteData.setInt64 isn't supported in web (JavaScript) builds.
    var counter = time.millisecondsSinceEpoch ~/ step.inMilliseconds;
    final message = Uint8List(8);
    for (var i = 7; i >= 0; i--) {
      message[i] = counter % 256;
      counter ~/= 256;
    }
    final hash = Hmac(sha1, _base32Decode(secret)).convert(message).bytes;
    final offset = hash.last & 0x0f;
    final binary = ((hash[offset] & 0x7f) << 24) |
        (hash[offset + 1] << 16) |
        (hash[offset + 2] << 8) |
        hash[offset + 3];
    return (binary % pow(10, digits)).toString().padLeft(digits, '0');
  }

  /// Whether [code] is right now, allowing [window] steps either side for a
  /// phone clock that is slightly off.
  static bool verify(String secret, String code, {DateTime? now, int window = 1}) {
    final cleaned = code.replaceAll(RegExp(r'\s'), '');
    if (cleaned.length != digits) return false;
    final time = now ?? DateTime.now();
    for (var i = -window; i <= window; i++) {
      if (codeAt(secret, time.add(step * i)) == cleaned) return true;
    }
    return false;
  }

  static String _base32Encode(Uint8List bytes) {
    final out = StringBuffer();
    var buffer = 0, bits = 0;
    for (final byte in bytes) {
      buffer = (buffer << 8) | byte;
      bits += 8;
      while (bits >= 5) {
        out.write(_alphabet[(buffer >> (bits - 5)) & 31]);
        bits -= 5;
      }
    }
    if (bits > 0) out.write(_alphabet[(buffer << (5 - bits)) & 31]);
    return out.toString();
  }

  static Uint8List _base32Decode(String input) {
    final out = <int>[];
    var buffer = 0, bits = 0;
    for (final char in input.toUpperCase().replaceAll(RegExp(r'[\s=]'), '').split('')) {
      final value = _alphabet.indexOf(char);
      if (value < 0) throw FormatException('Not a Base32 secret', input);
      buffer = (buffer << 5) | value;
      bits += 5;
      if (bits >= 8) {
        out.add((buffer >> (bits - 8)) & 0xff);
        bits -= 8;
      }
    }
    return Uint8List.fromList(out);
  }
}
