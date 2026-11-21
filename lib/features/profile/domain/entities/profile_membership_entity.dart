class ProfileMembershipEntity {
  const ProfileMembershipEntity({
    required this.scope,
    required this.tenantId,
    required this.roleKey,
    required this.roleName,
  });

  final String scope;
  final int tenantId;
  final String roleKey;
  final String roleName;

  String get scopeLabel => switch (scope.toUpperCase()) {
    'NETWORK' => 'عضوية شبكة',
    'POS' => 'عضوية نقطة بيع',
    _ => 'عضوية مساحة عمل',
  };
}
