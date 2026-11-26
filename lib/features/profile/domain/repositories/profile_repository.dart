import 'package:netsales/features/profile/domain/entities/profile_entity.dart';
import 'package:netsales/features/profile/domain/entities/profile_security_params.dart';
import 'package:netsales/features/profile/domain/entities/update_profile_params.dart';

/// عقد المستودع لوحدة الملف الشخصي.
abstract interface class ProfileRepository {
  /// جلب الملف الشخصي للمستخدم المصادَق.
  Future<ProfileEntity> getProfile();

  /// تحديث بيانات الملف الشخصي.
  Future<ProfileEntity> updateProfile(UpdateProfileParams params);

  /// رفع صورة شخصية جديدة — يُعيد URL المحدَّث.
  Future<String> updateAvatar(UpdateAvatarParams params);

  /// تغيير كلمة مرور المستخدم المصادَق.
  Future<void> changePassword(ChangePasswordParams params);

  /// طلب رمز تحقق لإتمام تفعيل التحقق بخطوتين.
  Future<void> requestTwoFactorOtp();

  /// تفعيل أو تعطيل التحقق بخطوتين.
  Future<void> toggleTwoFactor(ToggleTwoFactorParams params);
}
