class NetworkPointsOfSaleMetricsEntity {
  const NetworkPointsOfSaleMetricsEntity({
    required this.total,
    required this.active,
    required this.inactive,
  });

  final int total;
  final int active;
  final int inactive;
}
