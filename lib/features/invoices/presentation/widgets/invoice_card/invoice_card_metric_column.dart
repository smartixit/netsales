import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';

/// عمود قياس مالي فردي مخصص لسكة قياسات بطاقة الفاتورة
class InvoiceCardMetricColumn extends StatelessWidget {
  const InvoiceCardMetricColumn({
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
            fontSize: 10.5.sp,
          ),
        ),
        SizedBox(height: 3.h),
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
                SizedBox(width: 2.w),
                Text(
                  unit!,
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.onSurfaceVariant,
                    fontSize: 9.sp,
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
