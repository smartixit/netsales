class MembershipRoleEntity {
  const MembershipRoleEntity({
    required this.roleId,
    required this.roleKey,
    required this.name,
  });

  final int roleId;
  final String roleKey;
  final String name;
}
