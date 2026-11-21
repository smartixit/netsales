class NetworkPackagesMetricsEntity {
  const NetworkPackagesMetricsEntity({
    required this.total,
    required this.active,
    required this.inactive,
  });

  final int total;
  final int active;
  final int inactive;
}
