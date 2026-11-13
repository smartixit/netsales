enum OperationalReportType {
  sales('sales'),
  expenses('expenses'),
  networkWallet('network_wallet_statement'),
  posWallet('pos_wallet_statement'),
  repayments('repayments'),
  debtAging('debt_aging'),
  requests('requests');

  const OperationalReportType(this.wireValue);

  final String wireValue;
}
