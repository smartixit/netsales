import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_order_card_metric_column.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_order_card_metric_divider.dart';

/// شريط المقاييس الثلاثية لبطاقة طلب التوريد (Order Card Metrics Bar)
///
/// يعرض عدد الباقات، عدد الكروت، وإجمالي الطلب الصافي المطلوب
/// مع حماية FittedBox لمنع أي انقطاع أو تجاوز في أرقام المبالغ.
class ProcurementOrderCardMetricsBar extends StatelessWidget {
  const ProcurementOrderCardMetricsBar({
    super.key,
    required this.itemCount,
    required this.totalQuantity,
    required this.totalAmount,
  });

  final int itemCount;
  final int totalQuantity;
  final double totalAmount;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.r, vertical: 10.r),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow.withValues(alpha: .35),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: .4)),
      ),
      child: Row(
        children: [
          // 1. عدد الباقات
          Expanded(
            child: ProcurementOrderCardMetricColumn(
              label: 'الباقات',
              value: '$itemCount',
              textColor: colors.onSurface,
            ),
          ),
          ProcurementOrderCardMetricDivider(
            color: colors.outlineVariant.withValues(alpha: .5),
          ),

          // 2. عدد الكروت
          Expanded(
            child: ProcurementOrderCardMetricColumn(
              label: 'عدد الكروت',
              value: '$totalQuantity',
              textColor: colors.onSurface,
            ),
          ),
          ProcurementOrderCardMetricDivider(
            color: colors.outlineVariant.withValues(alpha: .5),
          ),

          // 3. إجمالي الطلب الصافي
          Expanded(
            flex: 2,
            child: ProcurementOrderCardMetricColumn(
              label: 'إجمالي الطلب',
              value: AmountFormatter.formatValue(totalAmount),
              textColor: colors.primary,
              isEmphasized: true,
            ),
          ),
        ],
      ),
    );
  }
}
