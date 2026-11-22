import 'package:netsales/core/enums/request_status.dart';
import 'package:netsales/features/workspace/domain/entities/network_daily_sales_entity.dart';
import 'package:netsales/features/workspace/domain/entities/network_expenses_metrics_entity.dart';
import 'package:netsales/features/workspace/domain/entities/network_packages_metrics_entity.dart';
import 'package:netsales/features/workspace/domain/entities/network_pending_request_entity.dart';
import 'package:netsales/features/workspace/domain/entities/network_points_of_sale_metrics_entity.dart';
import 'package:netsales/features/workspace/domain/entities/network_requests_metrics_entity.dart';
import 'package:netsales/features/workspace/domain/entities/network_sales_metrics_entity.dart';
import 'package:netsales/features/workspace/domain/entities/network_sales_trend_point_entity.dart';
import 'package:netsales/features/workspace/domain/entities/network_wallet_metrics_entity.dart';
import 'package:netsales/features/workspace/domain/entities/network_workspace_overview_entity.dart';

class NetworkWorkspaceOverviewModel extends NetworkWorkspaceOverviewEntity {
  const NetworkWorkspaceOverviewModel({
    required super.networkId,
    required super.networkName,
    required super.generatedAt,
    required super.periodKey,
    required super.timezone,
    required super.periodDays,
    required super.periodFrom,
    required super.periodTo,
    required super.sales,
    required super.pointsOfSale,
    required super.requests,
    required super.packages,
    required super.expenses,
    super.wallet,
    required super.recentPendingRequests,
  });

  factory NetworkWorkspaceOverviewModel.fromJson(dynamic raw) {
    if (raw is! Map<String, dynamic>) {
      throw const FormatException('استجابة ملخص مساحة الشبكة ليست كائناً.');
    }

    final network = raw['network'];
    final period = raw['period'];
    final metrics = raw['metrics'];
    final recent = raw['recent_pending_requests'];
    final timezone = raw['timezone'];

    if (network is! Map<String, dynamic> ||
        period is! Map<String, dynamic> ||
        metrics is! Map<String, dynamic> ||
        recent is! List<dynamic> ||
        timezone is! String ||
        timezone.trim().isEmpty) {
      throw const FormatException('عقد ملخص مساحة الشبكة غير مكتمل.');
    }

    final networkId = network['network_id'];
    final networkName = network['network_name'];
    final generatedAt = raw['generated_at'];
    final periodKey = period['key'];
    final periodDays = period['days'];
    final periodFrom = period['from'];
    final periodTo = period['to'];

    if (networkId is! num ||
        networkName is! String ||
        networkName.trim().isEmpty ||
        generatedAt is! String ||
        generatedAt.isEmpty ||
        periodKey is! String ||
        periodKey.isEmpty ||
        periodDays is! num ||
        !periodDays.isFinite ||
        periodDays <= 0 ||
        periodDays != periodDays.toInt() ||
        periodFrom is! String ||
        periodFrom.isEmpty ||
        periodTo is! String ||
        periodTo.isEmpty) {
      throw const FormatException('حقول تعريف ملخص الشبكة غير صالحة.');
    }

    final pendingRequests = recent
        .map(_parsePendingRequest)
        .toList(growable: false);

    return NetworkWorkspaceOverviewModel(
      networkId: _requiredInt(networkId, 'network.network_id'),
      networkName: networkName,
      generatedAt: generatedAt,
      periodKey: periodKey,
      timezone: timezone,
      periodDays: periodDays.toInt(),
      periodFrom: periodFrom,
      periodTo: periodTo,
      sales: _parseSales(metrics['sales']),
      pointsOfSale: _parsePointsOfSale(metrics['points_of_sale']),
      requests: _parseRequests(metrics['requests']),
      packages: _parsePackages(metrics['packages']),
      expenses: _parseExpenses(metrics['expenses']),
      wallet: _parseWallet(metrics['wallet']),
      recentPendingRequests: List.unmodifiable(pendingRequests),
    );
  }

  static NetworkPendingRequestEntity _parsePendingRequest(dynamic raw) {
    if (raw is! Map<String, dynamic>) {
      throw const FormatException('عنصر طلب التوريد غير صالح.');
    }

    final requestId = raw['request_id'];
    final requestUuid = raw['request_uuid'];
    final posId = raw['pos_id'];
    final posName = raw['pos_name'];
    final saleTypeLabel = raw['sale_type_label'];
    final requestDate = raw['request_date'];
    final requestTotalAmount = raw['request_total_amount'];
    final status = raw['status'];
    final statusLabel = raw['status_label'];

    if (requestId is! num ||
        posId is! num ||
        requestUuid is! String ||
        requestUuid.trim().isEmpty ||
        posName is! String ||
        posName.trim().isEmpty ||
        (saleTypeLabel != null && saleTypeLabel is! String) ||
        requestDate is! String ||
        requestDate.isEmpty ||
        requestTotalAmount is! String ||
        !_isAmount(requestTotalAmount) ||
        status is! String ||
        status.isEmpty ||
        statusLabel is! String ||
        statusLabel.trim().isEmpty) {
      throw const FormatException('عقد طلب التوريد المعلق غير مكتمل.');
    }

    if (status != RequestStatus.pending.wireValue) {
      throw const FormatException(
        'قائمة الطلبات المعلقة تحتوي على حالة غير متوقعة.',
      );
    }

    return NetworkPendingRequestEntity(
      requestId: _requiredInt(requestId, 'request_id'),
      requestUuid: requestUuid,
      posId: _requiredInt(posId, 'pos_id'),
      posName: posName,
      saleTypeLabel: saleTypeLabel as String?,
      requestDate: requestDate,
      requestTotalAmount: requestTotalAmount,
      statusRaw: status,
      statusLabel: statusLabel,
    );
  }

  static NetworkSalesMetricsEntity? _parseSales(dynamic raw) {
    if (raw == null) return null;
    final json = _requiredMap(raw, 'sales');
    final trendRaw = json['trend'];
    if (trendRaw != null && trendRaw is! List) {
      throw const FormatException('اتجاه المبيعات غير صالح.');
    }

    final trend = (trendRaw as List? ?? const [])
        .map((dynamic point) {
          if (point is! Map<String, dynamic>) {
            throw const FormatException('نقطة اتجاه المبيعات غير صالحة.');
          }
          final date = point['date'];
          final total = point['total'];
          final count = point['count'];
          if (date is! String ||
              date.isEmpty ||
              total is! num ||
              !total.isFinite ||
              total < 0 ||
              (count != null && count is! num)) {
            throw const FormatException('حقول نقطة اتجاه المبيعات غير صالحة.');
          }
          return NetworkSalesTrendPointEntity(
            date: date,
            totalAmount: total.toDouble(),
            invoiceCount: count == null
                ? null
                : _requiredInt(count, 'sales.trend.count'),
          );
        })
        .toList(growable: false);

    final totalAmount = json['total_amount'];
    final invoiceCount = json['invoice_count'];
    final growthRate = json['growth_rate'];
    if (totalAmount is! String ||
        !_isAmount(totalAmount) ||
        invoiceCount is! num ||
        growthRate is! num ||
        !growthRate.isFinite) {
      throw const FormatException('مؤشرات المبيعات غير مكتملة أو غير صالحة.');
    }

    final todaySalesRaw = json['today_sales'];
    NetworkDailySalesEntity? todaySales;
    if (todaySalesRaw is Map<String, dynamic>) {
      final todayAmount = todaySalesRaw['amount']?.toString() ?? '0.00';
      final todayCount = (todaySalesRaw['invoice_count'] as num?)?.toInt() ?? 0;
      final yestAmount = todaySalesRaw['yesterday_amount']?.toString() ?? '0.00';
      final todayGrowth = (todaySalesRaw['growth_rate'] as num?)?.toDouble() ?? 0.0;
      todaySales = NetworkDailySalesEntity(
        amount: todayAmount,
        invoiceCount: todayCount,
        yesterdayAmount: yestAmount,
        growthRate: todayGrowth,
      );
    }

    final paidAmount = json['paid_amount']?.toString();
    final outstandingAmount = json['outstanding_amount']?.toString();

    return NetworkSalesMetricsEntity(
      totalAmount: totalAmount,
      invoiceCount: _requiredInt(invoiceCount, 'sales.invoice_count'),
      growthRate: growthRate.toDouble(),
      trend: List.unmodifiable(trend),
      paidAmount: paidAmount != null && _isAmount(paidAmount) ? paidAmount : null,
      outstandingAmount: outstandingAmount != null && _isAmount(outstandingAmount) ? outstandingAmount : null,
      todaySales: todaySales,
    );
  }

  static NetworkPointsOfSaleMetricsEntity? _parsePointsOfSale(dynamic raw) {
    if (raw == null) return null;
    final json = _requiredMap(raw, 'points_of_sale');
    return NetworkPointsOfSaleMetricsEntity(
      total: _requiredInt(json['total'], 'points_of_sale.total'),
      active: _requiredInt(json['active'], 'points_of_sale.active'),
      inactive: _requiredInt(json['inactive'], 'points_of_sale.inactive'),
    );
  }

  static NetworkRequestsMetricsEntity? _parseRequests(dynamic raw) {
    if (raw == null) return null;
    final json = _requiredMap(raw, 'requests');
    return NetworkRequestsMetricsEntity(
      total: _requiredInt(json['total'], 'requests.total'),
      pending: _requiredInt(json['pending'], 'requests.pending'),
      approved: _requiredInt(json['approved'], 'requests.approved'),
      rejected: _requiredInt(json['rejected'], 'requests.rejected'),
      cancelled: _requiredInt(json['cancelled'], 'requests.cancelled'),
    );
  }

  static NetworkPackagesMetricsEntity? _parsePackages(dynamic raw) {
    if (raw == null) return null;
    final json = _requiredMap(raw, 'packages');
    return NetworkPackagesMetricsEntity(
      total: _requiredInt(json['total'], 'packages.total'),
      active: _requiredInt(json['active'], 'packages.active'),
      inactive: _requiredInt(json['inactive'], 'packages.inactive'),
    );
  }

  static NetworkExpensesMetricsEntity? _parseExpenses(dynamic raw) {
    if (raw == null) return null;
    final json = _requiredMap(raw, 'expenses');
    final totalAmount = json['total_amount'];
    if (totalAmount is! String || !_isAmount(totalAmount)) {
      throw const FormatException('إجمالي المصروفات غير صالح.');
    }
    return NetworkExpensesMetricsEntity(
      count: _requiredInt(json['count'], 'expenses.count'),
      totalAmount: totalAmount,
    );
  }

  static NetworkWalletMetricsEntity? _parseWallet(dynamic raw) {
    if (raw == null) return null;
    final json = _requiredMap(raw, 'wallet');
    final balance = json['balance'];
    final todayCash = json['today_cash_collected'] ?? '0.00';
    if (balance is! String || !_isAmount(balance)) {
      throw const FormatException('رصيد محفظة الشبكة غير صالح.');
    }
    return NetworkWalletMetricsEntity(
      walletId: _requiredInt(json['wallet_id'], 'wallet.wallet_id'),
      balance: balance,
      isActive: json['is_active'] == true,
      todayCashCollected: todayCash is String && _isAmount(todayCash) ? todayCash : '0.00',
    );
  }

  static Map<String, dynamic> _requiredMap(dynamic raw, String group) {
    if (raw is! Map<String, dynamic>) {
      throw FormatException('مجموعة المؤشرات $group غير صالحة.');
    }
    return raw;
  }

  static int _requiredInt(dynamic value, String field) {
    if (value is! num ||
        !value.isFinite ||
        value < 0 ||
        value != value.toInt()) {
      throw FormatException('قيمة المؤشر $field غير صالحة.');
    }
    return value.toInt();
  }

  static bool _isAmount(String value) {
    if (value.isEmpty) return false;
    final parts = value.split('.');
    if (parts.length > 2 || parts.first.isEmpty) return false;
    if (!_containsOnlyDigits(parts.first)) return false;
    return parts.length == 1 ||
        (parts[1].isNotEmpty && _containsOnlyDigits(parts[1]));
  }

  static bool _containsOnlyDigits(String value) =>
      value.codeUnits.every((unit) => unit >= 48 && unit <= 57);
}
