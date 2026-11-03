/// نطاقات الأدوار التشغيلية (Role Scope)
/// مطابق للقيم السلكية المعتمدة في netsales_api (App\Enums\RoleScope)
enum RoleScope {
  platform('PLATFORM'),
  network('NETWORK'),
  pos('POS'),
  unknown('UNKNOWN');

  final String wireValue;
  const RoleScope(this.wireValue);

  static RoleScope fromWire(String? raw) {
    if (raw == null) return RoleScope.unknown;
    for (final scope in RoleScope.values) {
      if (scope.wireValue == raw) return scope;
    }
    return RoleScope.unknown;
  }

  bool get isKnown => this != RoleScope.unknown;
}
