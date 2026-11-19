import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/themes/app_typography.dart';

class ProcurementDetailsSpecBadge extends StatelessWidget {
  const ProcurementDetailsSpecBadge({
    super.key,
    required this.label,
    required this.icon,
    required this.tintColor,
  });

  final String label;
  final IconData icon;
  final Color tintColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: tintColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(
          color: tintColor.withValues(alpha: 0.22),
          width: 0.7,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11.r, color: tintColor),
          SizedBox(width: 4.w),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: tintColor,
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
