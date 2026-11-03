/// حالة اعتماد الجهاز المقترن (User Device Status)
/// مطابق للقيم السلكية المعتمدة في netsales_api (App\Enums\UserDeviceStatus)
enum UserDeviceStatus {
  active('ACTIVE'),
  inactive('INACTIVE'),
  pending('PENDING'),
  banned('BANNED'),
  unknown('UNKNOWN');

  final String wireValue;
  const UserDeviceStatus(this.wireValue);

  static UserDeviceStatus fromWire(String? raw) {
    if (raw == null) return UserDeviceStatus.unknown;
    for (final status in UserDeviceStatus.values) {
      if (status.wireValue == raw) return status;
    }
    return UserDeviceStatus.unknown;
  }

  bool get isKnown => this != UserDeviceStatus.unknown;
  bool get isActive => this == UserDeviceStatus.active;
}

