import 'package:netsales/features/auth/domain/entities/auth_result_entity.dart';
import 'package:netsales/features/auth/domain/entities/directorate_entity.dart';
import 'package:netsales/features/auth/domain/entities/governorate_entity.dart';
import 'package:netsales/features/auth/domain/entities/register_network_result_entity.dart';

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

  /// اعتماد كلمة المرور الجديدة بعد استيفاء رمز التحقق OTP
  Future<void> resetPassword({
    required String phoneNumber,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  });

  /// إتمام التحقق الثنائي وتأكيد ربط الجهاز وإنشاء الجلسة
  Future<AuthResultEntity> verifyTwoFactor({
    required String phoneNumber,
    required String otp,
    required String deviceUuid,
    required String fcmToken,
    String? deviceName,
    String? deviceType,
  });

  /// إعادة إرسال رمز OTP محدد النوع
  Future<void> resendOtp({
    required String phoneNumber,
    required String otpType,
    required String deviceUuid,
  });

  /// جلب قائمة المحافظات المتاحة
  Future<List<GovernorateEntity>> getGovernorates();

  /// جلب قائمة المديريات التابعة لمحافظة معينة
  Future<List<DirectorateEntity>> getDirectorates(int governorateId);

  /// تقديم طلب تسجيل مزود شبكة جديد
  Future<RegisterNetworkResultEntity> registerNetwork({
    required String networkName,
    required int governorateId,
    required int directorateId,
    String? networkEmail,
    String? networkAddress,
    String? networkProfileLogoPath,
    required String userFullName,
    required String userPhoneNumber,
    required String userPassword,
    String? userEmail,
    String? userProfileLogoPath,
    required String deviceUuid,
    required String fcmToken,
    String? deviceName,
    String? deviceType,
  });
}
