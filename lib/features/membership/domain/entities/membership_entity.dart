class MembershipEntity {
  const MembershipEntity({
    required this.userId,
    required this.fullName,
    required this.phoneNumber,
    required this.roleId,
    required this.roleKey,
    required this.roleLabel,
    required this.status,
    this.profileLogo,
    this.isOwner = false,
  });

  final int userId;
  final String fullName;
  final String phoneNumber;
  final int roleId;
  final String roleKey;
  final String roleLabel;
  final String status;
  final String? profileLogo;
  final bool isOwner;

  bool get isActive => status == 'ACTIVE';
}
