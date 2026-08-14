// lib/paytm_checksum.dart
//
// Local implementation of Paytm's V2 Checksum algorithm.
// This mirrors the official paytmchecksum Node.js / Java SDK exactly:
//   1. Generate a 4-char random salt.
//   2. Compute SHA-256 of (body|salt) → hex string.
//   3. Append salt → hashString.
//   4. AES-128-CBC encrypt hashString with MERCHANT_KEY as key and
//      "@@@@&&&&####$$$$" as IV → Base64 result.
//
// NOTE: For production apps, checksum MUST be generated on your backend server,
// not in the mobile app, to protect your MERCHANT_KEY.

import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;

class PaytmChecksum {
  PaytmChecksum._(); // prevent instantiation

  static const String _iv = '@@@@&&&&####\$\$\$\$';
  static const String _saltChars =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

  /// Generates a Paytm V2 checksum/signature.
  ///
  /// [body] — the JSON-encoded request body string.
  /// [merchantKey] — your 16-character Paytm Merchant Key.
  ///
  /// Returns a Base64-encoded signature string, identical to what
  /// Paytm's official backend SDKs produce.
  static String generateSignature(String body, String merchantKey) {
    assert(merchantKey.length == 16,
        'MERCHANT_KEY must be exactly 16 characters (AES-128).');

    // Step 1: random 4-char salt
    final random = Random.secure();
    final salt = String.fromCharCodes(
      Iterable.generate(
        4,
        (_) => _saltChars.codeUnitAt(random.nextInt(_saltChars.length)),
      ),
    );

    // Step 2: SHA-256(body|salt) → hex
    final hash = sha256.convert(utf8.encode('$body|$salt')).toString();

    // Step 3: append salt
    final hashString = '$hash$salt';

    // Step 4: AES-128-CBC encrypt
    final key = enc.Key.fromUtf8(merchantKey);
    final iv = enc.IV.fromUtf8(_iv);
    final encrypter =
        enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc, padding: 'PKCS7'));

    return encrypter.encrypt(hashString, iv: iv).base64;
  }
}
