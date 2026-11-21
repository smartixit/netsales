import 'package:netsales/features/profile/domain/entities/profile_membership_entity.dart';
class ProfileEntity {
  const ProfileEntity({required this.userId, required this.fullName, required this.phoneNumber, required this.status, required this.twoFactorEnabled, required this.memberships, this.email, this.avatarUrl, this.statusLabel, this.lastLoginAt});
  final int userId;
  final String fullName;
  final String phoneNumber;
  final String status;
  final bool twoFactorEnabled;
  final List<ProfileMembershipEntity> memberships;
  final String? email;
  final String? avatarUrl;
  final String? statusLabel;
  final String? lastLoginAt;
}
