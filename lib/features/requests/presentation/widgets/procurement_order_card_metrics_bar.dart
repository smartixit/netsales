import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';

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
            child: _MetricColumn(
              label: 'الباقات',
              value: '$itemCount',
              textColor: colors.onSurface,
            ),
          ),
          _MetricDivider(color: colors.outlineVariant.withValues(alpha: .5)),

          // 2. عدد الكروت
          Expanded(
            child: _MetricColumn(
              label: 'عدد الكروت',
              value: '$totalQuantity',
              textColor: colors.onSurface,
            ),
          ),
          _MetricDivider(color: colors.outlineVariant.withValues(alpha: .5)),

          // 3. إجمالي الطلب الصافي
          Expanded(
            flex: 2,
            child: _MetricColumn(
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

class _MetricColumn extends StatelessWidget {
  const _MetricColumn({
    required this.label,
    required this.value,
    required this.textColor,
    this.isEmphasized = false,
  });

  final String label;
  final String value;
  final Color textColor;
  final bool isEmphasized;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.caption.copyWith(
            color: colors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        AppSpacing.vXxs,
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: isEmphasized
                ? AppTypography.titleMedium.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.2,
                  )
                : AppTypography.titleSmall.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w800,
                  ),
          ),
        ),
      ],
    );
  }
}

class _MetricDivider extends StatelessWidget {
  const _MetricDivider({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.0,
      height: 28.h,
      color: color,
      margin: EdgeInsets.symmetric(horizontal: 4.r),
    );
  }
}
