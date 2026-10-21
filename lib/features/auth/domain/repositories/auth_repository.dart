import 'package:netsales/features/auth/domain/entities/auth_result_entity.dart';

/// عقد مستودع المصادقة الدوميني المجرد
abstract interface class AuthRepository {
  /// تسجيل الدخول إلى النظام والتحقق من المستخدم وإنشاء الجلسة
  Future<AuthResultEntity> login({
    required String phoneNumber,
    required String password,
    required String deviceUuid,
    required String fcmToken,
    String? deviceName,
    String? deviceType,
  });

  /// تحديث كلمة المرور للمستخدم المسجل وتأكيد الهوية وتحديث الصلاحيات
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  });

  /// طلب رمز التحقق لاستعادة كلمة المرور عبر SMS
  Future<void> requestPasswordReset(String phoneNumber);

  /// التحقق من رمز OTP واستلام كلمة المرور المؤقتة عبر SMS
  Future<void> verifyResetOtp({
    required String phoneNumber,
    required String otp,
  });
}
