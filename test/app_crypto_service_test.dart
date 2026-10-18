import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/services/app_crypto_service.dart';
import 'package:netsales/core/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.instance.init();
  });

  group('AppCryptoService Base Helpers', () {
    test('Hex to Bytes and Bytes to Hex roundtrip', () {
      const originalHex =
          '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
      final bytes = AppCryptoService.hexToBytes(originalHex);
      expect(bytes.length, equals(32));

      final hex = AppCryptoService.bytesToHex(bytes);
      expect(hex, equals(originalHex));
    });

    test('Unpadded Base64URL encode and decode roundtrip', () {
      final sample = Uint8List.fromList(
        utf8.encode('NetSales High Security Enterprise 2026'),
      );
      final encoded = AppCryptoService.base64UrlEncodeNoPadding(sample);

      expect(encoded.contains('='), isFalse);
      expect(encoded.contains('+'), isFalse);
      expect(encoded.contains('/'), isFalse);

      final decoded = AppCryptoService.base64UrlDecodeUnpadded(encoded);
      expect(
        utf8.decode(decoded),
        equals('NetSales High Security Enterprise 2026'),
      );
    });
  });

  group('AppCryptoService Core Cryptography', () {
    test('Initialization and Ephemeral KeyPair generation', () async {
      final crypto = AppCryptoService.instance;
      await crypto.init();

      expect(crypto.isReady, isTrue);

      final keyPair = crypto.generateEphemeralKeyPair();
      expect(keyPair.publicKey.length, equals(32));
      final hex = AppCryptoService.bytesToHex(keyPair.publicKey);
      expect(hex.length, equals(64));

      keyPair.dispose();
    });
  });
}
