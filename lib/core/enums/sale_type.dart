/// نوع المعاملة التجارية (Sale Type)
/// مطابق للقيم السلكية المعتمدة في netsales_api (App\Enums\SaleType)
enum SaleType {
  cash('CASH'),
  credit('CREDIT'),
  unknown('UNKNOWN');

  final String wireValue;
  const SaleType(this.wireValue);

  static SaleType fromWire(String? raw) {
    if (raw == null) return SaleType.unknown;
    for (final type in SaleType.values) {
      if (type.wireValue == raw) return type;
    }
    return SaleType.unknown;
  }

  bool get isKnown => this != SaleType.unknown;
}

