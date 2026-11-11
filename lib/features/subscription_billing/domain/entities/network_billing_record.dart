class NetworkBillingRecord {
  const NetworkBillingRecord(this.data);
  final Map<String, dynamic> data;

  int get id => ((data['billing_account_id'] ??
          data['invoice_id'] ??
          data['payment_id'] ??
          data['credit_note_id'] ??
          data['refund_id'] ??
          data['billing_subscription_id']) as num?)?.toInt() ?? 0;
  String value(String key, [String fallback = '—']) =>
      data[key]?.toString().trim().isNotEmpty == true
          ? data[key].toString()
          : fallback;
  Map<String, dynamic> get currency =>
      data['currency'] is Map
          ? Map<String, dynamic>.from(data['currency'] as Map)
          : data['default_currency'] is Map
              ? Map<String, dynamic>.from(data['default_currency'] as Map)
              : const {};
  String get currencyCode => currency['code']?.toString() ?? '';
}
