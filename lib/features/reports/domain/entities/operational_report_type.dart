/// Stable identifier value for a server-defined operational report.
///
/// Known identifiers expose constants for specialized presentation behavior.
/// Unknown, valid identifiers remain first-class catalog entries and use the
/// generic report presentation path; adding a provider does not require adding
/// a new client enum value, screen, or controller.
final class OperationalReportType {
  const OperationalReportType(this.wireValue);

  final String wireValue;

  static const sales = OperationalReportType('sales');
  static const expenses = OperationalReportType('expenses');
  static const networkWallet =
      OperationalReportType('network_wallet_statement');
  static const posWallet = OperationalReportType('pos_wallet_statement');
  static const repayments = OperationalReportType('repayments');
  static const debtAging = OperationalReportType('debt_aging');
  static const requests = OperationalReportType('requests');

  static const List<OperationalReportType> values = [
    sales,
    expenses,
    networkWallet,
    posWallet,
    repayments,
    debtAging,
    requests,
  ];

  factory OperationalReportType.fromWire(String value) {
    final normalized = value.trim();
    if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(normalized)) {
      throw FormatException('معرف تقرير غير صالح: $value');
    }

    for (final known in values) {
      if (known.wireValue == normalized) return known;
    }

    return OperationalReportType(normalized);
  }

  @override
  bool operator ==(Object other) =>
      other is OperationalReportType && other.wireValue == wireValue;

  @override
  int get hashCode => wireValue.hashCode;

  @override
  String toString() => wireValue;
}
