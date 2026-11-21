import 'package:netsales/core/enums/role_key.dart';
import 'package:netsales/core/enums/role_scope.dart';
import 'package:netsales/core/models/workspace_membership_model.dart';
import 'package:netsales/core/models/user_model.dart';
import 'package:netsales/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:netsales/features/profile/domain/entities/profile_entity.dart';
import 'package:netsales/features/profile/domain/entities/profile_membership_entity.dart';
import 'package:netsales/features/profile/domain/repositories/profile_repository.dart';

/// Converts remote user data into the profile domain model.
class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._remoteDataSource);

  final ProfileRemoteDataSource _remoteDataSource;

  @override
  Future<ProfileEntity> getProfile() async {
    final user = await _remoteDataSource.getProfile();

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
      memberships: _mapOperationalMemberships(user.workspaceMemberships),
    );
  }

  String? _primaryRoleName(UserModel user) {
    final roleName = user.role?.roleName.trim();
    if (roleName != null && roleName.isNotEmpty) {
      return roleName;
    }

    final roleLabel = user.role?.roleKeyLabel?.trim();
    if (roleLabel != null && roleLabel.isNotEmpty) {
      return roleLabel;
    }

    return null;
  }

  List<ProfileMembershipEntity> _mapOperationalMemberships(
    List<WorkspaceMembershipModel> memberships,
  ) {
    return memberships
        .where(
          (membership) =>
              membership.tenantId > 0 &&
              (membership.scope == RoleScope.network ||
                  membership.scope == RoleScope.pos),
        )
        .map(
          (membership) => ProfileMembershipEntity(
            scope: membership.scope,
            tenantId: membership.tenantId,
            roleKey: RoleKey.fromWire(membership.roleKey),
            roleName: membership.roleName,
          ),
        )
        .toList(growable: false);
  }
}
