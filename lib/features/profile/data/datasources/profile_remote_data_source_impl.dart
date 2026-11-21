import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/models/user_model.dart';
import 'package:netsales/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:netsales/features/profile/data/datasources/profile_remote_data_source.dart';
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  const ProfileRemoteDataSourceImpl(this.authRemoteDataSource);
  final AuthRemoteDataSource authRemoteDataSource;
  @override
  Future<UserModel> getProfile() async {
    final response = await authRemoteDataSource.getProfile();
    if (!response.success || response.data == null) {
      throw AppException(response.message.isEmpty ? 'تعذر تحميل بيانات الحساب.' : response.message);
    }
    final payload = response.data!;
    final rawUser = payload['user'];
    if (rawUser is! Map) throw const AppException('استجابة الملف الشخصي لا تحتوي بيانات مستخدم صالحة.');
    final userData = Map<String, dynamic>.from(rawUser);
    final memberships = payload['workspace_roles'] ?? payload['workspace_memberships'] ??
        userData['workspace_roles'] ?? userData['workspace_memberships'] ?? const <dynamic>[];
    final user = UserModel.fromJson({
      ...userData,
      'workspace_roles': memberships,
      'workspace_memberships': memberships,
      'is_super_admin': payload['is_super_admin'],
      'role_key': payload['role_key'],
    });
    if (user.userId <= 0) throw const AppException('معرّف المستخدم غير صالح.');
    return user;
  }
}
