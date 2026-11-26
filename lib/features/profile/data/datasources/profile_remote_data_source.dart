import 'package:netsales/core/models/user_model.dart';
import 'package:netsales/features/profile/data/models/update_profile_request_model.dart';

/// عقد مصدر البيانات البعيد لوحدة الملف الشخصي.
abstract interface class ProfileRemoteDataSource {
  /// جلب الملف الشخصي للمستخدم المصادَق.
  Future<UserModel> getProfile();

  /// تحديث بيانات الملف الشخصي (الاسم، الهاتف، البريد، الصورة اختيارياً).
  ///
  /// يُرسَل إلى: PUT /api/v1/users/{userId}
  Future<UserModel> updateProfile({
    required int userId,
    required UpdateProfileRequestModel body,
  });

  /// رفع صورة شخصية جديدة للمستخدم.
  ///
  /// يُرسَل إلى: POST /api/v1/users/{userId}/profile-picture
  /// يُعيد: مسار الصورة الجديدة.
  Future<String> updateAvatar({required int userId, required String filePath});

  /// تغيير كلمة المرور للمستخدم المصادَق.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  });

  /// طلب رمز OTP لتفعيل التحقق بخطوتين.
  Future<void> requestTwoFactorOtp();

  /// تفعيل أو تعطيل التحقق بخطوتين.
  Future<void> toggleTwoFactor({
    required bool enable,
    String? otp,
    String? currentPassword,
  });
}
