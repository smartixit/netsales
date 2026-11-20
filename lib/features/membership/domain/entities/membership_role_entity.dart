/// كيان الدور التشغيلي القابل للإسناد للعضو (Domain Entity)
class MembershipRoleEntity {
  const MembershipRoleEntity({
    required this.roleId,
    required this.roleKey,
    required this.name,
  });

  final int roleId;
  final String roleKey;
  final String name;

  String get displayName => name;
}
