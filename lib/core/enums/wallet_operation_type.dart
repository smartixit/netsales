/// نوع حركة المحفظة المالية (Wallet Operation Type)
/// مطابق للقيم السلكية المعتمدة في netsales_api (App\Enums\WalletOperationType)
enum WalletOperationType {
  deposit('DEPOSIT'),
  withdraw('WITHDRAW'),
  unknown('UNKNOWN');

  final String wireValue;
  const WalletOperationType(this.wireValue);

  static WalletOperationType fromWire(String? raw) {
    if (raw == null) return WalletOperationType.unknown;
    for (final op in WalletOperationType.values) {
      if (op.wireValue == raw) return op;
    }
    return WalletOperationType.unknown;
  }

  bool get isKnown => this != WalletOperationType.unknown;
}
