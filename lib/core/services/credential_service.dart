import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

/// حالة نتيجة التحقق بالمقاييس الحيوية
enum BiometricAuthStatus {
  success,
  failed,
  canceled,
  notEnrolled,
  lockedOut,
  unsupported,
}

/// نتيجة عملية التحقق بالمقاييس الحيوية المعقمة
@immutable
class BiometricAuthResult {
  const BiometricAuthResult({required this.status, this.errorMessage});

  final BiometricAuthStatus status;
  final String? errorMessage;

  bool get isSuccess => status == BiometricAuthStatus.success;

  const BiometricAuthResult.success()
    : status = BiometricAuthStatus.success,
      errorMessage = null;

  const BiometricAuthResult.failed([String? message])
    : status = BiometricAuthStatus.failed,
      errorMessage = message ?? 'فشلت عملية التحقق الحيوي';

  const BiometricAuthResult.canceled()
    : status = BiometricAuthStatus.canceled,
      errorMessage = 'تم إلغاء عملية التحقق بواسطة المستخدم';

  const BiometricAuthResult.notEnrolled()
    : status = BiometricAuthStatus.notEnrolled,
      errorMessage = 'لا توجد بصمة مسجلة في هذا الجهاز';

  const BiometricAuthResult.lockedOut()
    : status = BiometricAuthStatus.lockedOut,
      errorMessage = 'تم قفل البصمة مؤقتاً لكثرة المحاولات الخاطئة';

  const BiometricAuthResult.unsupported()
    : status = BiometricAuthStatus.unsupported,
      errorMessage = 'الجهاز لا يدعم المصادقة بالمقاييس الحيوية';
}

/// كائن بيانات الاعتماد المشفرة والمحفوظة بأمان
@immutable
class SavedCredentials {
  const SavedCredentials({required this.phone, required this.password});

  final String phone;
  final String password;
}

/// ============================================================================
/// خدمة إدارة الاعتماد المشفرة والمصادقة الحيوية (Secure Credential & Biometrics)
/// ============================================================================
/// خدمة معيارية نظيفة (Clean Code & Decoupled) صالحة للاستخدام في أي مشروع Flutter:
/// 1. التخزين السيادي المشفر للاعتمادات الحساسة عبر FlutterSecureStorage (Keystore / Keychain).
/// 2. إدارة المقاييس الحيوية وفحص العتاد عبر LocalAuthentication.
/// 3. تجريد كامل للأخطاء والمنصات وتوفير واجهة موحدة للتسجيل السريع والآمن.
class CredentialService extends GetxService {
  CredentialService._();

  static final CredentialService instance = CredentialService._();

  static CredentialService get to => Get.find<CredentialService>();

  static const String _keyPhone = 'nts_secure_cred_phone';
  static const String _keyPassword = 'nts_secure_cred_password';
  static const String _keyBiometricsEnabled = 'nts_biometrics_enabled';

  final LocalAuthentication _localAuth = LocalAuthentication();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      resetOnError: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  /// تهيئة الخدمة
  Future<CredentialService> init() async {
    return this;
  }

  // ===========================================================================
  // 1. استعلامات المقاييس الحيوية (Hardware & Biometric Capabilities)
  // ===========================================================================

  /// فحص ما إذا كان العتاد يدعم المقاييس الحيوية مع توفر بصمة مسجلة
  Future<bool> canAuthenticateWithBiometrics() async {
    try {
      final isSupported = await _localAuth.isDeviceSupported();
      if (!isSupported) return false;

      final canCheck = await _localAuth.canCheckBiometrics;
      if (!canCheck) return false;

      final available = await _localAuth.getAvailableBiometrics();
      return available.isNotEmpty;
    } on PlatformException catch (e) {
      log('⚠️ [CredentialService] canAuthenticateWithBiometrics error: $e');
      return false;
    } catch (e) {
      log('⚠️ [CredentialService] Unexpected error: $e');
      return false;
    }
  }

  /// الحصول على قائمة أنواع البصمات المتاحة على الجهاز
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (_) {
      return const [];
    }
  }

  // ===========================================================================
  // 2. التحقق بالمقاييس الحيوية (Biometric Authentication Execution)
  // ===========================================================================

  /// إجراء المصادقة الحيوية للمستخدم مع معالجة استثناءات النظام
  Future<BiometricAuthResult> authenticate({
    String reason = 'يرجى تأكيد هويتك للمتابعة إلى حسابك',
  }) async {
    try {
      final canAuth = await canAuthenticateWithBiometrics();
      if (!canAuth) {
        return const BiometricAuthResult.unsupported();
      }

      final authenticated = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
          useErrorDialogs: true,
        ),
      );

      return authenticated
          ? const BiometricAuthResult.success()
          : const BiometricAuthResult.failed();
    } on PlatformException catch (e) {
      log(
        '⚠️ [CredentialService] Biometric platform exception: ${e.code} - ${e.message}',
      );
      switch (e.code) {
        case auth_error.notEnrolled:
          return const BiometricAuthResult.notEnrolled();
        case auth_error.lockedOut:
        case auth_error.permanentlyLockedOut:
          return const BiometricAuthResult.lockedOut();
        case auth_error.passcodeNotSet:
          return const BiometricAuthResult.failed('رمز قفل الجهاز غير مفعل');
        case auth_error.notAvailable:
          return const BiometricAuthResult.unsupported();
        default:
          return BiometricAuthResult.failed(e.message);
      }
    } catch (e) {
      log('⚠️ [CredentialService] Biometric unexpected error: $e');
      return BiometricAuthResult.failed(e.toString());
    }
  }

  // ===========================================================================
  // 3. الخزنة المشفرة للاعتمادات (Encrypted Secure Storage Vault)
  // ===========================================================================

  /// حفظ بيانات الاعتماد بشكل مشفر داخل Keystore / Keychain
  Future<void> saveCredentials({
    required String phone,
    required String password,
  }) async {
    try {
      await _secureStorage.write(key: _keyPhone, value: phone.trim());
      await _secureStorage.write(key: _keyPassword, value: password);
      await setBiometricsEnabled(true);
    } catch (e) {
      log('⚠️ [CredentialService] Failed to save secure credentials: $e');
    }
  }

  /// استرجاع بيانات الاعتماد المشفرة
  Future<SavedCredentials?> getSavedCredentials() async {
    try {
      final phone = await _secureStorage.read(key: _keyPhone);
      final password = await _secureStorage.read(key: _keyPassword);

      if (phone != null &&
          phone.isNotEmpty &&
          password != null &&
          password.isNotEmpty) {
        return SavedCredentials(phone: phone, password: password);
      }
      return null;
    } catch (e) {
      log('⚠️ [CredentialService] Failed to read credentials: $e');
      return null;
    }
  }

  /// استرجاع رقم الهاتف المحفوظ فقط للتعبئة التلقائية المريحة
  Future<String?> getSavedPhone() async {
    try {
      return await _secureStorage.read(key: _keyPhone);
    } catch (_) {
      return null;
    }
  }

  /// التحقق من توفر اعتمادات مشفرة محفوظة
  Future<bool> hasSavedCredentials() async {
    final creds = await getSavedCredentials();
    return creds != null;
  }

  /// حذف الاعتمادات المشفرة بأمان عند تسجيل الخروج أو إلغاء التفعيل
  Future<void> clearCredentials() async {
    try {
      await _secureStorage.delete(key: _keyPhone);
      await _secureStorage.delete(key: _keyPassword);
      await _secureStorage.delete(key: _keyBiometricsEnabled);
    } catch (e) {
      log('⚠️ [CredentialService] Failed to clear credentials: $e');
    }
  }

  // ===========================================================================
  // 4. إعدادات تفضيلات المستخدم (Preferences & Toggles)
  // ===========================================================================

  /// هل الدخول بالبصمة مفعل ومسموح به للمستخدم الحالي
  Future<bool> isBiometricsEnabled() async {
    try {
      final value = await _secureStorage.read(key: _keyBiometricsEnabled);
      return value == 'true';
    } catch (_) {
      return false;
    }
  }

  /// تفعيل أو تعطيل خيار الدخول بالبصمة
  Future<void> setBiometricsEnabled(bool enabled) async {
    try {
      await _secureStorage.write(
        key: _keyBiometricsEnabled,
        value: enabled ? 'true' : 'false',
      );
    } catch (_) {}
  }
}
