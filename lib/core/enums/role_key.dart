/// مفاتيح الأدوار القياسية المعتمدة بنظام الصلاحيات (Role Key)
/// مطابق للقيم السلكية المعتمدة في netsales_api (App\Enums\RoleKey)
enum RoleKey {
  superAdmin('SUPER_ADMIN'),
  networkOwner('NETWORK_OWNER'),
  networkUser('NETWORK_USER'),
  posAgent('POS_AGENT'),
  posUser('POS_USER'),
  supportAgent('SUPPORT_AGENT'),
  accountant('ACCOUNTANT'),
  networkAccountant('NETWORK_ACCOUNTANT'),
  posAccountant('POS_ACCOUNTANT'),
  unknown('UNKNOWN');

  final String wireValue;
  const RoleKey(this.wireValue);

  static RoleKey fromWire(String? raw) {
    if (raw == null) return RoleKey.unknown;
    for (final role in RoleKey.values) {
      if (role.wireValue == raw) return role;
    }
    return RoleKey.unknown;
  }

  bool get isKnown => this != RoleKey.unknown;
}

