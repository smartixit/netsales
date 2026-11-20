import 'package:netsales/widgets/charts/charting.dart';
import 'package:netsales/widgets/dashboard_metrics/dashboard_metrics.dart';

typedef NetworkLiquiditySummary = ({
  String balance,
  bool hasWallet,
  bool isWalletActive,
  bool hasSales,
  double growthRate,
  String growthLabel,
  String cashSales,
  String outstandingReceivables,
  String posCoverage,
});

typedef NetworkSalesVelocitySummary = ({
  String totalSales,
  int invoiceCount,
  double growthRate,
});

class NetworkWorkspaceDashboardViewModel {
  const NetworkWorkspaceDashboardViewModel({
    required this.showLiquiditySection,
    required this.showSalesSection,
    required this.pendingRequestsCount,
    required this.liquiditySummary,
    required this.salesVelocitySummary,
    required this.salesChartDefinition,
    required this.kpiMetrics,
  });

  final bool showLiquiditySection;
  final bool showSalesSection;
  final int pendingRequestsCount;
  final NetworkLiquiditySummary liquiditySummary;
  final NetworkSalesVelocitySummary salesVelocitySummary;
  final ChartDefinition salesChartDefinition;
  final List<DashboardMetricData> kpiMetrics;
}
