import 'package:netsales/core/enums/role_key.dart';
import 'package:netsales/core/enums/role_scope.dart';
import 'package:netsales/core/models/workspace_membership_model.dart';
import 'package:netsales/core/models/user_model.dart';
import 'package:netsales/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:netsales/features/profile/data/models/update_profile_request_model.dart';
import 'package:netsales/features/profile/domain/entities/profile_entity.dart';
import 'package:netsales/features/profile/domain/entities/profile_membership_entity.dart';
import 'package:netsales/features/profile/domain/entities/profile_security_params.dart';
import 'package:netsales/features/profile/domain/entities/update_profile_params.dart';
import 'package:netsales/features/profile/domain/repositories/profile_repository.dart';

/// تحويل بيانات المستخدم البعيدة إلى نموذج المجال للملف الشخصي.
class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._remoteDataSource);

  final ProfileRemoteDataSource _remoteDataSource;

  @override
  Future<ProfileEntity> getProfile() async {
    final user = await _remoteDataSource.getProfile();
    return _toEntity(user);
  }

  @override
  Future<ProfileEntity> updateProfile(UpdateProfileParams params) async {
    final user = await _remoteDataSource.updateProfile(
      userId: params.userId,
      body: UpdateProfileRequestModel(
        fullName: params.fullName,
        phoneNumber: params.phoneNumber,
        email: params.email,
      ),
    );
    return _toEntity(user);
  }

  @override
  Future<String> updateAvatar(UpdateAvatarParams params) {
    return _remoteDataSource.updateAvatar(
      userId: params.userId,
      filePath: params.avatar.path,
    );
  }

  @override
  Future<void> changePassword(ChangePasswordParams params) {
    return _remoteDataSource.changePassword(
      currentPassword: params.currentPassword,
      newPassword: params.newPassword,
      confirmPassword: params.confirmPassword,
    );
  }

  @override
  Future<void> requestTwoFactorOtp() {
    return _remoteDataSource.requestTwoFactorOtp();
  }

  @override
  Future<void> toggleTwoFactor(ToggleTwoFactorParams params) {
    return _remoteDataSource.toggleTwoFactor(
      enable: params.enable,
      otp: params.otp,
      currentPassword: params.currentPassword,
    );
  }

  ProfileEntity _toEntity(UserModel user) {
    return ProfileEntity(
      userId: user.userId,
      fullName: user.userFullName,
      phoneNumber: user.userPhoneNumber,
      email: user.userEmail,
      avatarUrl: user.userProfileLogo,
      status: user.typedStatus,
      statusLabel: user.statusLabel,
      lastLoginAt: user.lastLoginAt,
      twoFactorEnabled: user.user2faEnabled,
      mustChangePassword: user.mustChangePassword,
      primaryRoleKey: RoleKey.fromWire(
        user.role?.roleKey ?? user.generalRoleKey,
      ),
      primaryRoleName: _primaryRoleName(user),
      memberships: _mapMemberships(user.workspaceMemberships),
    );
  }

  String? _primaryRoleName(UserModel user) {
    final roleName = user.role?.roleName.trim();
    if (roleName != null && roleName.isNotEmpty) return roleName;
    final roleLabel = user.role?.roleKeyLabel?.trim();
    if (roleLabel != null && roleLabel.isNotEmpty) return roleLabel;
    return null;
  }

  List<ProfileMembershipEntity> _mapMemberships(
    List<WorkspaceMembershipModel> memberships,
  ) {
    return memberships
        .where(
          (m) =>
              m.tenantId > 0 &&
              (m.scope == RoleScope.network || m.scope == RoleScope.pos),
        )
        .map(
          (m) => ProfileMembershipEntity(
            scope: m.scope,
            tenantId: m.tenantId,
            roleKey: RoleKey.fromWire(m.roleKey),
            roleName: m.roleName,
          ),
        )
        .toList(growable: false);
  }
}
