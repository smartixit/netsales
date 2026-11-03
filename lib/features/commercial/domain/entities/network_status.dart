/// حالة مزود الشبكة التجاري (Network Status)
/// مطابق للقيم السلكية المعتمدة في netsales_api (App\Enums\NetworkStatus)
enum NetworkStatus {
  active('ACTIVE'),
  inactive('INACTIVE'),
  pending('PENDING'),
  rejected('REJECTED'),
  banned('BANNED'),
  unknown('UNKNOWN');

  final String wireValue;
  const NetworkStatus(this.wireValue);

  static NetworkStatus fromWire(String? raw) {
    if (raw == null) return NetworkStatus.unknown;
    final trimmed = raw.trim();
    for (final status in NetworkStatus.values) {
      if (status.wireValue == trimmed) return status;
    }
    return NetworkStatus.unknown;
  }

  bool get isKnown => this != NetworkStatus.unknown;
  bool get isActive => this == NetworkStatus.active;
}
