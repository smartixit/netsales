import 'package:netsales/features/workspace/domain/entities/network_expenses_metrics_entity.dart';
import 'package:netsales/features/workspace/domain/entities/network_packages_metrics_entity.dart';
import 'package:netsales/features/workspace/domain/entities/network_pending_request_entity.dart';
import 'package:netsales/features/workspace/domain/entities/network_points_of_sale_metrics_entity.dart';
import 'package:netsales/features/workspace/domain/entities/network_requests_metrics_entity.dart';
import 'package:netsales/features/workspace/domain/entities/network_sales_metrics_entity.dart';

/// Typed operational overview for one authorized network.
class NetworkWorkspaceOverviewEntity {
  const NetworkWorkspaceOverviewEntity({
    required this.networkId,
    required this.networkName,
    required this.generatedAt,
    required this.periodKey,
    required this.timezone,
    required this.periodDays,
    required this.periodFrom,
    required this.periodTo,
    required this.sales,
    required this.pointsOfSale,
    required this.requests,
    required this.packages,
    required this.expenses,
    required this.recentPendingRequests,
  });

  final int networkId;
  final String networkName;
  final String generatedAt;
  final String periodKey;
  final String timezone;
  final int periodDays;
  final String periodFrom;
  final String periodTo;
  final NetworkSalesMetricsEntity? sales;
  final NetworkPointsOfSaleMetricsEntity? pointsOfSale;
  final NetworkRequestsMetricsEntity? requests;
  final NetworkPackagesMetricsEntity? packages;
  final NetworkExpensesMetricsEntity? expenses;
  final List<NetworkPendingRequestEntity> recentPendingRequests;
}
