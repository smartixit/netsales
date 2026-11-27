/// حالة جلسة تسجيل الدخول (User Session Status)
/// مطابق للقيم السلكية المعتمدة في netsales_api (App\Enums\UserSessionStatus)
enum UserSessionStatus {
  active('ACTIVE'),
  expired('EXPIRED'),
  revoked('REVOKED'),
  unknown('UNKNOWN');

  final String wireValue;
  const UserSessionStatus(this.wireValue);

  static UserSessionStatus fromWire(String? raw) {
    if (raw == null) return UserSessionStatus.unknown;
    for (final status in UserSessionStatus.values) {
      if (status.wireValue == raw) return status;
    }
    return UserSessionStatus.unknown;
  }

  bool get isKnown => this != UserSessionStatus.unknown;
  bool get isActive => this == UserSessionStatus.active;
}
