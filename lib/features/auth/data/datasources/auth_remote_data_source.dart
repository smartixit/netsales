import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/features/auth/data/models/login_request_model.dart';
import 'package:netsales/features/auth/data/models/login_response_model.dart';

/// عقد مصدر البيانات البعيد للمصادقة والحسابات
abstract interface class AuthRemoteDataSource {
  /// إرسال طلب تسجيل الدخول للواجهة الخلفية
  Future<ApiResponse<LoginResponseModel>> login(LoginRequestModel request);

  /// تحديث كلمة المرور للمستخدم المسجل (إلزامي أو اختياري)
  Future<ApiResponse<void>> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  });

  /// جلب الملف الشخصي والصلاحيات المحدثة للمستخدم المسجل
  Future<ApiResponse<Map<String, dynamic>>> getProfile();
}
