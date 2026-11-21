class NetworkExpensesMetricsEntity {
  const NetworkExpensesMetricsEntity({
    required this.count,
    required this.totalAmount,
  });

  final int count;

  /// Exact decimal string returned by the API.
  final String totalAmount;
}
