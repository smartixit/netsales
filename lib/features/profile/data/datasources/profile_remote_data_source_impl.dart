import 'package:dio/dio.dart';
import 'package:netsales/core/constants/api_constants.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/models/user_model.dart';
import 'package:netsales/core/services/api_service.dart';
import 'package:netsales/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:netsales/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:netsales/features/profile/data/models/update_profile_request_model.dart';
import 'package:path/path.dart' as p;

/// تنفيذ مصدر البيانات البعيد لوحدة الملف الشخصي.
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  const ProfileRemoteDataSourceImpl(this._authRemoteDataSource);

  final AuthRemoteDataSource _authRemoteDataSource;

  @override
  Future<UserModel> getProfile() async {
    final response = await _authRemoteDataSource.getProfile();

    if (!response.success || response.data == null) {
      throw AppException(
        response.message.isNotEmpty
            ? response.message
            : 'تعذر تحميل بيانات الحساب.',
      );
    }

    final payload = response.data!;
    final rawUser = payload['user'];

    if (rawUser is! Map) {
      throw const AppException(
        'استجابة الملف الشخصي لا تحتوي بيانات مستخدم صالحة.',
      );
    }

    final userData = Map<String, dynamic>.from(rawUser);
    final memberships =
        payload['workspace_roles'] ??
        payload['workspace_memberships'] ??
        userData['workspace_roles'] ??
        userData['workspace_memberships'] ??
        const <dynamic>[];

    final user = UserModel.fromJson({
      ...userData,
      'workspace_roles': memberships,
      'workspace_memberships': memberships,
      'is_super_admin': payload['is_super_admin'],
      'role_key': payload['role_key'],
    });

    if (user.userId <= 0) {
      throw const AppException('معرِّف الحساب المستلم من الخادم غير صالح.');
    }

    return user;
  }

  @override
  Future<UserModel> updateProfile({
    required int userId,
    required UpdateProfileRequestModel body,
  }) async {
    final dynamic data =
        body.hasAvatar ? await body.toFormData() : body.toJson();

    final response = await ApiService.instance.put<Map<String, dynamic>>(
      ApiConstants.user(userId),
      data: data,
      fromJson: (json) =>
          json is Map ? Map<String, dynamic>.from(json) : <String, dynamic>{},
    );

    if (!response.success || response.data == null) {
      throw AppException(
        response.message.isNotEmpty
            ? response.message
            : 'تعذر تحديث الملف الشخصي.',
      );
    }

    final raw = response.data!;
    final userRaw = raw['user'] ?? raw;

    return UserModel.fromJson(Map<String, dynamic>.from(userRaw as Map));
  }

  @override
  Future<String> updateAvatar({
    required int userId,
    required String filePath,
  }) async {
    final formData = FormData.fromMap({
      'profile_picture': await MultipartFile.fromFile(
        filePath,
        filename: p.basename(filePath),
      ),
    });

    final response = await ApiService.instance.post<Map<String, dynamic>>(
      ApiConstants.userProfilePicture(userId),
      data: formData,
      fromJson: (json) =>
          json is Map ? Map<String, dynamic>.from(json) : <String, dynamic>{},
    );

    if (!response.success) {
      throw AppException(
        response.message.isNotEmpty
            ? response.message
            : 'تعذر رفع الصورة الشخصية.',
      );
    }

    return response.data?['profile_picture_path'] as String? ??
        response.data?['user_profile_logo'] as String? ??
        '';
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final response = await _authRemoteDataSource.updatePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );

    if (!response.success) {
      throw AppException(
        response.message.isNotEmpty
            ? response.message
            : 'تعذر تغيير كلمة المرور.',
      );
    }
  }

  @override
  Future<void> requestTwoFactorOtp() async {
    final response = await _authRemoteDataSource.requestTwoFactorOtp();

    if (!response.success) {
      throw AppException(
        response.message.isNotEmpty
            ? response.message
            : 'تعذر إرسال رمز التحقق.',
      );
    }
  }

  @override
  Future<void> toggleTwoFactor({
    required bool enable,
    String? otp,
    String? currentPassword,
  }) async {
    final response = await _authRemoteDataSource.toggleTwoFactor(
      enable: enable,
      otp: otp,
      currentPassword: currentPassword,
    );

    if (!response.success) {
      throw AppException(
        response.message.isNotEmpty
            ? response.message
            : 'تعذر تحديث حالة التحقق بخطوتين.',
      );
    }
  }
}
