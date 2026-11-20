import 'package:netsales/widgets/charts/charting.dart';
import 'package:netsales/widgets/dashboard_metrics/dashboard_metrics.dart';

typedef NetworkSalesTrendSummary = ({
  String totalSales,
  int invoiceCount,
  double growthRate,
});

class NetworkWorkspaceDashboardViewModel {
  const NetworkWorkspaceDashboardViewModel({
    required this.showSalesSection,
    required this.pendingRequestsCount,
    required this.salesTrendSummary,
    required this.salesChartDefinition,
    required this.kpiMetrics,
  });

  final bool showSalesSection;
  final int? pendingRequestsCount;
  final NetworkSalesTrendSummary salesTrendSummary;
  final ChartDefinition salesChartDefinition;
  final List<DashboardMetricData> kpiMetrics;
}
