import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';

class ProcurementDetailsAuditRow extends StatelessWidget {
  const ProcurementDetailsAuditRow({
    super.key,
    required this.label,
    required this.amount,
    this.formula,
    this.isDiscount = false,
    this.isTotal = false,
  });

  final String label;
  final String amount;
  final String? formula;
  final bool isDiscount;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final Color valueColor = isTotal
        ? colors.primary
        : (isDiscount ? colors.success : colors.onSurface);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: isTotal ? colors.onSurface : colors.onSurfaceVariant,
                  fontWeight: isTotal ? FontWeight.w800 : FontWeight.w500,
                  fontSize: 10.5.sp,
                ),
              ),
              if (formula != null) ...[
                SizedBox(height: 1.h),
                Text(
                  formula!,
                  style: AppTypography.caption.copyWith(
                    color: colors.onSurfaceVariant.withValues(alpha: 0.8),
                    fontSize: 9.sp,
                  ),
                ),
              ],
            ],
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          amount,
          style:
              (isTotal ? AppTypography.labelLarge : AppTypography.labelMedium)
                  .copyWith(
                    fontWeight: isTotal ? FontWeight.w900 : FontWeight.w700,
                    color: valueColor,
                  ),
        ),
      ],
    );
  }
}
