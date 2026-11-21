import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';

/// سطر عرض معلومة موحد داخل تفاصيل البطاقة التجارية
class CommercialDetailRow extends StatelessWidget {
  const CommercialDetailRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 2.w),
        child: Row(
          children: [
            Icon(icon, size: 16.r, color: colors.primary),
            SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: onTap != null ? colors.primary : colors.onSurface,
              ),
            ),
            if (onTap != null) ...[
              SizedBox(width: 4.w),
              Icon(Icons.open_in_new_rounded, size: 13.r, color: colors.primary),
            ],
          ],
        ),
      ),
    );
  }
}
