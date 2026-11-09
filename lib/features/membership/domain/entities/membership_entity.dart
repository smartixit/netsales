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
  });

  final int userId;
  final String fullName;
  final String phoneNumber;
  final int roleId;
  final String roleKey;
  final String roleLabel;
  final String status;
  final String? profileLogo;

  bool get isOwner => roleKey == 'NETWORK_OWNER' || roleKey == 'POS_AGENT';
  bool get isActive => status == 'ACTIVE';
}
