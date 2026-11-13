enum OperationalReportType {
  sales('sales', 'المبيعات والفواتير', 'receipt_long_rounded'),
  expenses('expenses', 'المصروفات التشغيلية', 'request_quote_rounded'),
  networkWallet('network_wallet_statement', 'كشف محفظة الشبكة', 'account_balance_rounded'),
  posWallet('pos_wallet_statement', 'كشف محفظة نقطة البيع', 'account_balance_wallet_rounded'),
  repayments('repayments', 'سندات السداد', 'payments_rounded'),
  debtAging('debt_aging', 'أعمار الديون', 'hourglass_bottom_rounded'),
  requests('requests', 'حركة الطلبات', 'inventory_2_rounded');

  const OperationalReportType(this.wireValue, this.label, this.iconName);

  final String wireValue;
  final String label;
  final String iconName;
}
