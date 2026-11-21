import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:netsales/features/profile/domain/entities/profile_entity.dart';
import 'package:netsales/features/profile/domain/entities/profile_membership_entity.dart';
import 'package:netsales/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this.remoteDataSource);

  final ProfileRemoteDataSource remoteDataSource;

  @override
  Future<ProfileEntity> getProfile() async {
    final user = await remoteDataSource.getProfile();
    final statusPresentation = EnumPresentationRegistry.resolveUserStatus(
      user.typedStatus,
      serverLabel: user.statusLabel,
    );

    return ProfileEntity(
      userId: user.userId,
      fullName: user.userFullName,
      phoneNumber: user.userPhoneNumber,
      email: user.userEmail,
      avatarUrl: user.userProfileLogo,
      status: user.status,
      statusLabel: statusPresentation.label,
      lastLoginAt: user.lastLoginAt,
      twoFactorEnabled: user.user2faEnabled,
      memberships: user.workspaceMemberships.map((membership) {
        final roleLabel = membership.roleName.trim().isNotEmpty
            ? membership.roleName
            : EnumPresentationRegistry.resolveRoleKey(
                membership.typedRoleKey,
              ).label;

        return ProfileMembershipEntity(
          scope: membership.scope.wireValue,
          tenantId: membership.tenantId,
          roleKey: membership.roleKey,
          roleName: roleLabel,
        );
      }).toList(growable: false),
    );
  }
}
