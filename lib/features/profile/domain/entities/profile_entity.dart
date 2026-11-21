import 'package:equatable/equatable.dart';
import 'package:netsales/core/enums/role_key.dart';
import 'package:netsales/core/enums/user_status.dart';
import 'package:netsales/features/profile/domain/entities/profile_membership_entity.dart';

/// Domain representation of the authenticated account profile.
class ProfileEntity extends Equatable {
  const ProfileEntity({
    required this.userId,
    required this.fullName,
    required this.phoneNumber,
    required this.status,
    required this.twoFactorEnabled,
    required this.mustChangePassword,
    required this.memberships,
    this.email,
    this.avatarUrl,
    this.statusLabel,
    this.lastLoginAt,
    this.primaryRoleKey = RoleKey.unknown,
    this.primaryRoleName,
  });

  final int userId;
  final String fullName;
  final String phoneNumber;
  final String? email;
  final String? avatarUrl;
  final UserStatus status;
  final String? statusLabel;
  final String? lastLoginAt;
  final bool twoFactorEnabled;
  final bool mustChangePassword;
  final RoleKey primaryRoleKey;
  final String? primaryRoleName;
  final List<ProfileMembershipEntity> memberships;

  bool get hasEmail => email != null && email!.trim().isNotEmpty;

  bool get hasOperationalMemberships => memberships.isNotEmpty;

  @override
  List<Object?> get props => [
        userId,
        fullName,
        phoneNumber,
        email,
        avatarUrl,
        status,
        statusLabel,
        lastLoginAt,
        twoFactorEnabled,
        mustChangePassword,
        primaryRoleKey,
        primaryRoleName,
        memberships,
      ];
}
