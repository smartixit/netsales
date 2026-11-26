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

  ProfileEntity copyWith({
    int? userId,
    String? fullName,
    String? phoneNumber,
    String? email,
    String? avatarUrl,
    UserStatus? status,
    String? statusLabel,
    String? lastLoginAt,
    bool? twoFactorEnabled,
    bool? mustChangePassword,
    RoleKey? primaryRoleKey,
    String? primaryRoleName,
    List<ProfileMembershipEntity>? memberships,
  }) {
    return ProfileEntity(
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      status: status ?? this.status,
      statusLabel: statusLabel ?? this.statusLabel,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
      mustChangePassword: mustChangePassword ?? this.mustChangePassword,
      primaryRoleKey: primaryRoleKey ?? this.primaryRoleKey,
      primaryRoleName: primaryRoleName ?? this.primaryRoleName,
      memberships: memberships ?? this.memberships,
    );
  }

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
