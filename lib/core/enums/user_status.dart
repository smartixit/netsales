/// حالة حساب المستخدم في النظام (User Account Status)
/// مطابق للقيم السلكية المعتمدة في netsales_api (App\Enums\UserStatus)
enum UserStatus {
  active('ACTIVE'),
  inactive('INACTIVE'),
  pending('PENDING'),
  banned('BANNED'),
  unknown('UNKNOWN');

  final String wireValue;
  const UserStatus(this.wireValue);

  static UserStatus fromWire(String? raw) {
    if (raw == null) return UserStatus.unknown;
    for (final status in UserStatus.values) {
      if (status.wireValue == raw) return status;
    }
    return UserStatus.unknown;
  }

  bool get isKnown => this != UserStatus.unknown;
  bool get isActive => this == UserStatus.active;
}

