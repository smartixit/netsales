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

  String get requiredPermission => switch (this) {
    sales || debtAging => 'sales.report',
    expenses => 'expenses.report',
    networkWallet => 'network_wallets.report',
    posWallet || repayments => 'pos_wallets.report',
    requests => 'requests.report',
  };

  String get exportPermission => switch (this) {
    sales || debtAging => 'sales.export',
    expenses => 'expenses.export',
    networkWallet => 'network_wallets.export',
    posWallet || repayments => 'pos_wallets.export',
    requests => 'requests.export',
  };

  bool get availableForPos => switch (this) {
    sales || posWallet || repayments || debtAging || requests => true,
    expenses || networkWallet => false,
  };

  List<String> get statusOptions => switch (this) {
    sales || debtAging => const ['PAID', 'PARTIALLY_PAID', 'UNPAID'],
    networkWallet || posWallet => const ['DEPOSIT', 'WITHDRAW'],
    repayments => const ['COMPLETED', 'REVERSED'],
    requests => const ['PENDING', 'APPROVED', 'REJECTED'],
    expenses => const [],
  };
}
