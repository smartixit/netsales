import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/models/user_model.dart';
import 'package:netsales/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:netsales/features/profile/data/datasources/profile_remote_data_source.dart';

/// Maps the authenticated profile response into the shared user data model.
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
      throw const AppException('معرّف الحساب المستلم من الخادم غير صالح.');
    }

    return user;
  }
}
