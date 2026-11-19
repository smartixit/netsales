import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';

/// عمود قياس مالي فردي لسكة قياسات بطاقة المصروف التشغيلي
class ExpenseCardMetricColumn extends StatelessWidget {
  const ExpenseCardMetricColumn({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.accentColor,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  final String label;
  final String value;
  final String? unit;
  final Color? accentColor;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final effectiveColor = accentColor ?? colors.onSurface;

    return Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.labelSmall.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        AppSpacing.vXxs,
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: AppTypography.titleSmall.copyWith(
                  color: effectiveColor,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.2,
                ),
              ),
              if (unit != null) ...[
                AppSpacing.hXxs,
                Text(
                  unit!,
                  style: AppTypography.caption.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
