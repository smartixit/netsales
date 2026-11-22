/// المركز المحاسبي لرصيد المحفظة المالية (Accounting Balance Status)
///
/// مطابق للقيم السلكية المعتمدة في netsales_api (PosWallet::getAccountingStatus())
enum AccountingStatus {
  credit('CREDIT'),
  debit('DEBIT'),
  zero('ZERO'),
  unknown('UNKNOWN');

  final String wireValue;
  const AccountingStatus(this.wireValue);

  static AccountingStatus fromWire(String? raw) {
    if (raw == null) return AccountingStatus.unknown;
    final normalized = raw.trim().toUpperCase();
    for (final status in AccountingStatus.values) {
      if (status.wireValue == normalized) return status;
    }
    return AccountingStatus.unknown;
  }

  bool get isKnown => this != AccountingStatus.unknown;
}
