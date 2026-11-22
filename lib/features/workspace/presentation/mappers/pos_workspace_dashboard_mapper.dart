import 'package:flutter/material.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/features/wallet/domain/entities/pos_wallet_entity.dart';
import 'package:netsales/widgets/dashboard_metrics/dashboard_metrics.dart';

/// مواءم مؤشرات الأداء التنفيذية للوحة تحكم نقطة البيع (POS Executive KPI Mapper)
class PosWorkspaceDashboardMapper {
  const PosWorkspaceDashboardMapper._();

  static List<DashboardMetricData> map({
    required PosWalletEntity? wallet,
    required List<InvoiceEntity> recentInvoices,
    required List<RequestEntity> recentRequests,
    DateTime? now,
  }) {
    final items = <DashboardMetricData>[];
    final referenceDate = now ?? DateTime.now();

    // 1. مشتريات اليوم (Daily Procurement Trend vs Yesterday)
    final todayInvoices = recentInvoices.where((inv) {
      final date = inv.parsedInvoiceDate;
      if (date == null) return false;
      return date.year == referenceDate.year &&
          date.month == referenceDate.month &&
          date.day == referenceDate.day;
    }).toList(growable: false);

    final yesterday = referenceDate.subtract(const Duration(days: 1));
    final yesterdayInvoices = recentInvoices.where((inv) {
      final date = inv.parsedInvoiceDate;
      if (date == null) return false;
      return date.year == yesterday.year &&
          date.month == yesterday.month &&
          date.day == yesterday.day;
    }).toList(growable: false);

    final todayTotal = todayInvoices.fold<double>(
      0.0,
      (sum, inv) => sum + inv.invoiceTotalAmount,
    );
    final yesterdayTotal = yesterdayInvoices.fold<double>(
      0.0,
      (sum, inv) => sum + inv.invoiceTotalAmount,
    );

    final double growthRate;
    if (yesterdayTotal > 0) {
      growthRate = ((todayTotal - yesterdayTotal) / yesterdayTotal) * 100.0;
    } else {
      growthRate = todayTotal > 0 ? 100.0 : 0.0;
    }

    final isPositive = growthRate >= 0;
    final growthSign = isPositive ? '+' : '';

    items.add(
      DashboardMetricData(
        id: 'today_procurement',
        title: 'مشتريات اليوم',
        value: AmountFormatter.format(todayTotal.toStringAsFixed(2)),
        unit: 'ر.ي',
        icon: Icons.shopping_bag_rounded,
        tone: isPositive ? DashboardMetricTone.success : DashboardMetricTone.warning,
        variant: DashboardMetricVariant.trend,
        trend: DashboardMetricTrend(
          direction: growthRate > 0
              ? DashboardMetricDirection.increase
              : (growthRate < 0
                  ? DashboardMetricDirection.decrease
                  : DashboardMetricDirection.unchanged),
          tone: isPositive ? DashboardMetricTone.success : DashboardMetricTone.danger,
          valueLabel: '$growthSign${growthRate.toStringAsFixed(1)}%',
          comparisonLabel: '',
        ),
        description: '${todayInvoices.length} فاتورة مشتريات',
        tooltip: 'مقارنة بالأمس (${AmountFormatter.format(yesterdayTotal.toStringAsFixed(2))})',
      ),
    );

    // 2. رصيد المحفظة المعتمد (Authoritative POS Wallet Balance & Purchasing Power)
    if (wallet != null) {
      final String walletDesc;
      if (wallet.isDebit) {
        walletDesc = 'مديونية مسحوبة';
      } else if (wallet.hasCreditFacility) {
        walletDesc =
            'سقف ائتماني: ${AmountFormatter.format((wallet.creditLimit ?? 0).toStringAsFixed(2))}';
      } else {
        walletDesc = wallet.isCredit ? 'رصيد دائن متاح للشراء' : 'الرصيد متزن (0.00)';
      }

      items.add(
        DashboardMetricData(
          id: 'wallet',
          title: 'رصيد المحفظة',
          value: AmountFormatter.format(wallet.walletBalance.toStringAsFixed(2)),
          unit: 'ر.ي',
          icon: Icons.account_balance_wallet_rounded,
          tone: wallet.isDebit
              ? DashboardMetricTone.danger
              : (wallet.isCredit
                  ? DashboardMetricTone.success
                  : DashboardMetricTone.neutral),
          variant: DashboardMetricVariant.standard,
          description: walletDesc,
        ),
      );
    }

    // 4. طلبات التوريد النشطة (Active Supply Orders)
    final activeOrdersCount = recentRequests
        .where((req) => req.isPending || req.isApproved)
        .length;

    items.add(
      DashboardMetricData(
        id: 'active_orders',
        title: 'الطلبات النشطة',
        value: activeOrdersCount.toString(),
        unit: 'طلب',
        icon: Icons.local_shipping_rounded,
        tone: DashboardMetricTone.warning,
        variant: DashboardMetricVariant.standard,
        description: 'قيد المعالجة والتوريد',
      ),
    );

    return List.unmodifiable(items);
  }
}
