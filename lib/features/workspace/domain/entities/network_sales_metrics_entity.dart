import 'package:netsales/features/workspace/domain/entities/network_sales_trend_point_entity.dart';

class NetworkSalesMetricsEntity {
  const NetworkSalesMetricsEntity({
    required this.totalAmount,
    required this.invoiceCount,
    required this.growthRate,
    required this.trend,
  });

  /// Exact decimal string returned by the API; never converted to double.
  final String totalAmount;
  final int invoiceCount;
  final double growthRate;
  final List<NetworkSalesTrendPointEntity> trend;
}
