import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/models/user_model.dart';
import 'package:netsales/core/models/user_session_model.dart';
import 'package:netsales/core/services/permission_service.dart';
import 'package:netsales/core/services/session_service.dart';
import 'package:netsales/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:netsales/features/auth/data/models/login_request_model.dart';
import 'package:netsales/features/auth/domain/entities/auth_result_entity.dart';
import 'package:netsales/features/auth/domain/repositories/auth_repository.dart';

/// تطبيق مستودع المصادقة وتنسيق البيانات بين مصدر البيانات وإدارة الجلسات
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remoteDataSource);

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<AuthResultEntity> login({
    required String phoneNumber,
    required String password,
    required String deviceUuid,
    required String fcmToken,
    String? deviceName,
    String? deviceType,
  }) async {
    final request = LoginRequestModel(
      userPhoneNumber: phoneNumber,
      userPassword: password,
      deviceUuid: deviceUuid,
      fcmToken: fcmToken,
      deviceName: deviceName,
      deviceType: deviceType,
    );

    final response = await _remoteDataSource.login(request);

    if (!response.success) {
      throw AppException(response.message);
    }

    final data = response.data;
    if (data == null) {
      throw AppException(
        response.message.isNotEmpty
            ? response.message
            : 'تعذر استلام بيانات المصادقة من الخادم',
      );
    }

    // إذا كانت المصادقة مباشرة وناجحة، نبدأ الجلسة فورياً في الذاكرة والتخزين الآمن
    if (!data.require2fa && data.user != null) {
      await SessionService.to.startSession(
        user: data.user!,
        session: UserSessionModel(
          sessionId: data.sessionId,
          userId: data.user!.userId,
          deviceUuid: data.deviceUuid,
        ),
        permissions: data.permissions,
      );
    }

    // LoginResponseModel يرث مباشرة من AuthResultEntity (LSP)
    return data;
  }

  @override
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final response = await _remoteDataSource.updatePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );

    if (!response.success) {
      throw AppException(response.message);
    }

    // بعد نجاح تحديث كلمة المرور، نقوم بفك الحظر وتحديث بيانات المستخدم محلياً
    await SessionService.to.markPasswordChanged();

    // جلب الملف الشخصي والصلاحيات المحدثة لترقية الجلسة فورياً
    try {
      final profileResp = await _remoteDataSource.getProfile();
      if (profileResp.success && profileResp.data != null) {
        final profileData = profileResp.data!;
        final rawUser = profileData['user'];
        if (rawUser is Map) {
          final updatedUser = UserModel.fromJson(Map<String, dynamic>.from(rawUser));
          await SessionService.to.updateCurrentUser(updatedUser);
        }
        final rawPerms = profileData['permissions'];
        final permissions = rawPerms is List
            ? rawPerms.map((e) => e.toString()).toList()
            : <String>[];
        if (Get.isRegistered<PermissionService>()) {
          final roleKey = profileData['role_key']?.toString() ?? '';
          PermissionService.to.updateAccess(
            roleKey: roleKey,
            permissions: permissions,
          );
        }
      }
    } catch (_) {
      // استمرار آمن في حال عدم توفر اتصال لحظي للملف الشخصي
    }
  }

  @override
  Future<void> requestPasswordReset(String phoneNumber) async {
    final response = await _remoteDataSource.requestPasswordReset(phoneNumber);
    if (!response.success) {
      throw AppException(response.message);
    }
  }

  @override
  Future<void> verifyResetOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    final response = await _remoteDataSource.verifyResetOtp(
      phoneNumber: phoneNumber,
      otp: otp,
    );
    if (!response.success) {
      throw AppException(response.message);
    }
  }
}
