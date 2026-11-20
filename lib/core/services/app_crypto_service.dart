import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:netsales/core/constants/api_constants.dart';
import 'package:netsales/core/constants/storage_keys.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/services/storage_service.dart';
import 'package:netsales/core/services/infinityfree_challenge_solver.dart';
import 'package:sodium/sodium.dart';

/// ============================================================================
/// كائن حمولة الطلب المشفر (Encrypted Request Payload Container)
/// ============================================================================
/// يحمل زوج المفاتيح المؤقت في الذاكرة العشوائية ومفتاح العميل العام
/// وجسم الطلب المغلف { "payload": "..." }.
/// يلتزم بمبدأ مسح المفتاح السري فور اكتمال دورة الطلب/الاستجابة.
class EncryptedPayload {
  const EncryptedPayload({
    required this.ephemeralKeyPair,
    required this.clientPublicKeyHex,
    required this.body,
  });

  /// زوج المفاتيح المؤقت الخاص بهذا الطلب حصراً في الـ RAM
  final KeyPair ephemeralKeyPair;

  /// المفتاح العام للعميل بصيغة Hex الممرر للخادم
  final String clientPublicKeyHex;

  /// الحمولة المغلفة المشفرة الموجهة للخادم
  final Map<String, dynamic> body;

  /// مسح المفتاح السري وتحرير الذاكرة الآمنة فوراً
  void dispose() {
    try {
      ephemeralKeyPair.dispose();
    } catch (e) {
      log('⚠️ [Crypto] Failed to dispose ephemeral keypair: $e');
    }
  }
}

/// ============================================================================
/// خدمة التشفير اللامتناظر والتوثيق الرقمي السيادي (App Crypto Service)
/// ============================================================================
/// تطبق معمارية التشفير السيبراني الصارمة المتطابقة مع الواجهة الخلفية Laravel:
/// 1. انعدام الأسرار والمفاتيح الخاصة بالعميل على القرص أو الكود (Zero Client Secrets).
/// 2. توليد أزواج مفاتيح مؤقتة في الـ RAM لكل طلب مشفر (Ephemeral X25519 Keypairs).
/// 3. تعمية وتشفير حمولة الطلبات بمفتاح الخادم العام عبر `crypto_box_seal`.
/// 4. فك تشفير استجابات الخادم بمفتاح الطلب المؤقت عبر `crypto_box_seal_open`.
/// 5. التحقق من التوقيعات الرقمية للوثائق والكروت (Ed25519 Digital Signatures).
/// 6. مزامنة المفاتيح السيادية للخادم من نقطة الوصول /api/v1/security/public-keys.
class AppCryptoService {
  AppCryptoService._internal();

  static final AppCryptoService instance = AppCryptoService._internal();
  factory AppCryptoService() => instance;

  Sodium? _sodium;
  bool _isInitialized = false;

  /// معرف مفتاح الخادم المعتمد
  static const String serverKeyId = 'netsales-key-2026-v1';
  static const String serverBoxKeyId = 'netsales-key-2026-v1-enc';

  /// بادئة الاستجابات المشفرة القادمة من الخادم
  static const String encResponsePrefix = 'NTS_ENC_';

  /// مفتاح التشفير العام للخادم (X25519 Box Public Key - 32 bytes)
  Uint8List? _serverBoxPublicKey;

  /// مفتاح التوقيع الرقمي العام للخادم (Ed25519 Sign Public Key - 32 bytes)
  Uint8List? _serverSignPublicKey;
  Future<bool>? _publicKeysSyncFuture;

  /// هل مكتبة التشفير جاهزة للاستخدام
  bool get isReady => _isInitialized && _sodium != null;

  /// هل مفتاح التشفير العام للخادم متوفر
  bool get hasServerBoxKey => _serverBoxPublicKey != null;

  /// هل التشفير مفعّل فعلياً (تلقائياً بمجرد جاهزية مكتبة التشفير السيادية عبر كافة البيئات)
  bool get isEncryptionActive => isReady;

  /// ==========================================================================
  /// 1. تهيئة مكتبة التشفير libsodium (Native Assets / Build Hooks)
  /// ==========================================================================
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      _sodium = await SodiumInit.init();
      _isInitialized = true;
      log(
        '🔒 [Crypto] libsodium initialized successfully (version: ${_sodium?.version})',
      );

      // استرجاع المفاتيح المخزنة محلياً إن وجدت
      _restoreCachedKeys();
    } catch (e, stack) {
      log('❌ [Crypto] Failed to initialize libsodium: $e\n$stack');
      _isInitialized = false;
    }
  }

  /// يتم بناء وتحميل مكتبة libsodium تلقائياً عبر Native Assets.

  /// ==========================================================================
  /// 2. مزامنة المفاتيح العامة السيادية للخادم (Public Keys Synchronization)
  /// ==========================================================================
  Future<bool> syncServerPublicKeys({
    required Dio dio,
    bool force = false,
  }) {
    if (!force && hasServerBoxKey) return Future<bool>.value(true);

    final inFlight = _publicKeysSyncFuture;
    if (inFlight != null) return inFlight;

    final syncFuture = _syncServerPublicKeys(dio: dio);
    _publicKeysSyncFuture = syncFuture;
    return syncFuture.whenComplete(() {
      if (identical(_publicKeysSyncFuture, syncFuture)) {
        _publicKeysSyncFuture = null;
      }
    });
  }

  Future<bool> _syncServerPublicKeys({required Dio dio}) async {
    try {
      final response = await dio.get<dynamic>(
        ApiConstants.securityPublicKeys,
        options: Options(headers: {'X-Bypass-Encryption': 'true'}),
      );

      if (InfinityFreeChallengeSolver.isChallengeResponse(response.data)) {
        log(
          '❌ [Crypto] Public-key endpoint still returned the InfinityFree '
          'JavaScript challenge after its single verification replay '
          '(status: ${response.statusCode}).',
        );
        return false;
      }

      if (response.statusCode != 200) {
        log(
          '❌ [Crypto] Public-key endpoint returned HTTP '
          '${response.statusCode}; expected 200.',
        );
        return false;
      }

      final responseData = response.data;
      if (responseData is! Map) {
        log(
          '❌ [Crypto] Public-key response has an invalid envelope '
          '(type: ${responseData.runtimeType}).',
        );
        return false;
      }

      final payload = responseData['data'];
      final keys = payload is Map ? payload['keys'] : null;
      if (keys is! List) {
        log(
          '❌ [Crypto] Public-key response does not contain data.keys.',
        );
        return false;
      }

      var foundBoxKey = false;
      for (final keyItem in keys) {
        if (keyItem is! Map) continue;

        final kid = keyItem['kid']?.toString() ?? '';
        final crv = keyItem['crv']?.toString() ?? '';
        final hex = keyItem['public_key']?.toString() ?? '';
        final isValidPublicKey =
            RegExp(r'^[0-9a-fA-F]{64}$').hasMatch(hex);

        if (!isValidPublicKey) continue;

        if (crv == 'X25519' || kid.endsWith('-enc')) {
          _serverBoxPublicKey = hexToBytes(hex);
          await StorageService.instance.setString(
            StorageKeys.serverBoxPublicKey,
            hex.toLowerCase(),
          );
          foundBoxKey = true;
          log(
            '🔑 [Crypto] Server X25519 public key synchronized successfully.',
          );
        } else if (crv == 'Ed25519' || kid == serverKeyId) {
          _serverSignPublicKey = hexToBytes(hex);
          await StorageService.instance.setString(
            StorageKeys.serverSignPublicKey,
            hex.toLowerCase(),
          );
          log(
            '🔑 [Crypto] Server Ed25519 public key synchronized successfully.',
          );
        }
      }

      if (!foundBoxKey && !hasServerBoxKey) {
        log(
          '❌ [Crypto] The public-key response contained no valid X25519 '
          'encryption key.',
        );
      }

      return hasServerBoxKey;
    } catch (e, stack) {
      log(
        '❌ [Crypto] Failed to synchronize server public keys: $e\n$stack',
      );
      return hasServerBoxKey;
    }
  }

  /// استرجاع المفاتيح المحفوظة محلياً لتسريع الإقلاع
  void _restoreCachedKeys() {
    try {
      final storage = StorageService.instance;
      final cachedBoxHex = storage.getString(StorageKeys.serverBoxPublicKey);
      final cachedSignHex = storage.getString(StorageKeys.serverSignPublicKey);

      if (cachedBoxHex != null && cachedBoxHex.length == 64) {
        _serverBoxPublicKey = hexToBytes(cachedBoxHex);
      }

      if (cachedSignHex != null && cachedSignHex.length == 64) {
        _serverSignPublicKey = hexToBytes(cachedSignHex);
      }
    } catch (e) {
      log('ℹ️ [Crypto] No local keys restored: $e');
    }
  }

  /// توليد زوج مفاتيح لامتناظر مؤقت في الـ RAM
  KeyPair generateEphemeralKeyPair() {
    if (!isReady) {
      throw const AppException('مكتبة التشفير غير مهيأة.');
    }
    return _sodium!.crypto.box.keyPair();
  }

  /// ==========================================================================
  /// 3. تشفير حمولة الطلب (Sealed Box Request Encryption: Client -> Server)
  /// ==========================================================================
  /// ينشئ زوج مفاتيح مؤقت، يضمن المفتاح العام في الترويسة والحمولة،
  /// ويشفر البيانات بمفتاح الخادم العام السيادي.
  EncryptedPayload sealRequestPayload(dynamic rawData) {
    if (!isReady || _serverBoxPublicKey == null) {
      throw const AppException(
        'مكتبة التشفير أو مفتاح الخادم العام غير جاهز للإرسال المشفر.',
      );
    }

    // 1. توليد زوج مفاتيح لامتناظر مؤقت في الـ RAM
    final ephemeralKeyPair = generateEphemeralKeyPair();
    final clientPublicKeyHex = bytesToHex(ephemeralKeyPair.publicKey);

    // 2. تجهيز الحمولة وتضمين المفتاح العام للعميل للتحقق المزدوج
    final Map<String, dynamic> payloadMap;
    if (rawData is Map<String, dynamic>) {
      payloadMap = Map<String, dynamic>.from(rawData);
    } else if (rawData == null) {
      payloadMap = <String, dynamic>{};
    } else {
      payloadMap = {'_data': rawData};
    }

    payloadMap['_client_public_key'] = clientPublicKeyHex;

    // 3. تحويل الحمولة إلى JSON مشفر
    final jsonString = jsonEncode(payloadMap);
    final plaintextBytes = Uint8List.fromList(utf8.encode(jsonString));

    // 4. التشفير المصمت بمفتاح الخادم العام (crypto_box_seal)
    final cipherBytes = _sodium!.crypto.box.seal(
      message: plaintextBytes,
      publicKey: _serverBoxPublicKey!,
    );

    // 5. ترميز الناتج بصيغة Base64URL غير مبطنة مطابقة للواجهة الخلفية
    final base64UrlPayload = base64UrlEncodeNoPadding(cipherBytes);

    return EncryptedPayload(
      ephemeralKeyPair: ephemeralKeyPair,
      clientPublicKeyHex: clientPublicKeyHex,
      body: {'payload': base64UrlPayload},
    );
  }

  /// ==========================================================================
  /// 4. فك تشفير استجابة الخادم (Sealed Box Response Decryption: Server -> Client)
  /// ==========================================================================
  /// يفك تعمية الرد بواسطة المفتاح الخاص المؤقت لنفس الطلب حصراً.
  dynamic unsealResponseData({
    required dynamic rawResponseData,
    required KeyPair ephemeralKeyPair,
  }) {
    if (!isReady) {
      throw const AppException('مكتبة التشفير غير مهيأة.');
    }

    // إذا لم تكن البيانات مشفرة (سلسلة تبدأ بـ NTS_ENC_) تعاد كما هي
    if (rawResponseData is! String ||
        !rawResponseData.startsWith(encResponsePrefix)) {
      return rawResponseData;
    }

    try {
      // 1. استخراج الـ CipherText بفك تشفير Base64URL
      final base64Cipher = rawResponseData.substring(encResponsePrefix.length);
      final cipherBytes = base64UrlDecodeUnpadded(base64Cipher);

      // 2. فتح الصندوق المصمت بواسطة المفتاح المؤقت للطلب (crypto_box_seal_open)
      final decryptedBytes = _sodium!.crypto.box.sealOpen(
        cipherText: cipherBytes,
        publicKey: ephemeralKeyPair.publicKey,
        secretKey: ephemeralKeyPair.secretKey,
      );

      // 3. تحويل البايتات إلى نص JSON ثم كائن برمجي
      final jsonString = utf8.decode(decryptedBytes);
      return jsonDecode(jsonString);
    } catch (e, stack) {
      log('❌ [Crypto] Failed to unseal server response: $e\n$stack');
      throw const AppException('فشل فك تشفير استجابة الخادم الآمنة.');
    }
  }

  /// ==========================================================================
  /// 5. التحقق من التوقيع الرقمي السيادي (Ed25519 Signature Verification)
  /// ==========================================================================
  bool verifyDigitalSignature({
    required Uint8List message,
    required Uint8List signature,
  }) {
    if (!isReady || _serverSignPublicKey == null) {
      log('⚠️ [Crypto] Sign public key is not available for verification');
      return false;
    }

    try {
      return _sodium!.crypto.sign.verifyDetached(
        signature: signature,
        message: message,
        publicKey: _serverSignPublicKey!,
      );
    } catch (e) {
      log('❌ [Crypto] Signature verification failed: $e');
      return false;
    }
  }

  /// التحقق من نص موقع رقمياً بتوقيع Hex أو Base64
  bool verifyTextSignature({
    required String text,
    required String signatureString,
  }) {
    final messageBytes = Uint8List.fromList(utf8.encode(text));
    final signatureBytes = signatureString.length == 128
        ? hexToBytes(signatureString)
        : base64UrlDecodeUnpadded(signatureString);

    return verifyDigitalSignature(
      message: messageBytes,
      signature: signatureBytes,
    );
  }

  // ==========================================================================
  // دوال التحويل القياسية المساعدة (Hex & Base64URL Helpers)
  // ==========================================================================

  /// تحويل Hex String إلى Uint8List
  static Uint8List hexToBytes(String hex) {
    final clean = hex.replaceAll(RegExp(r'\s+'), '');
    final result = Uint8List(clean.length ~/ 2);
    for (var i = 0; i < clean.length; i += 2) {
      result[i ~/ 2] = int.parse(clean.substring(i, i + 2), radix: 16);
    }
    return result;
  }

  /// تحويل Uint8List إلى Hex String
  static String bytesToHex(Uint8List bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// ترميز Base64URL بدون حشو (Unpadded Base64URL) مطابق لدالة PHP:
  /// `rtrim(strtr(base64_encode($data), '+/', '-_'), '=')`
  static String base64UrlEncodeNoPadding(Uint8List bytes) {
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  /// فك ترميز Base64URL مع إعادة الحشو التلقائي
  static Uint8List base64UrlDecodeUnpadded(String input) {
    var normalized = input.replaceAll('-', '+').replaceAll('_', '/');
    while (normalized.length % 4 != 0) {
      normalized += '=';
    }
    return base64.decode(normalized);
  }
}
