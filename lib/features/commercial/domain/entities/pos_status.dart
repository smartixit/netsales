/// حالة نقطة البيع التجارية (POS Status)
/// مطابق للقيم السلكية المعتمدة في netsales_api (App\Enums\PosStatus)
enum PosStatus {
  active('ACTIVE'),
  inactive('INACTIVE'),
  pending('PENDING'),
  rejected('REJECTED'),
  banned('BANNED'),
  unknown('UNKNOWN');

  final String wireValue;
  const PosStatus(this.wireValue);

  static PosStatus fromWire(String? raw) {
    if (raw == null) return PosStatus.unknown;
    final trimmed = raw.trim();
    for (final status in PosStatus.values) {
      if (status.wireValue == trimmed) return status;
    }
    return PosStatus.unknown;
  }

  bool get isKnown => this != PosStatus.unknown;
  bool get isActive => this == PosStatus.active;
}

