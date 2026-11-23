import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/themes/app_typography.dart';

/// شارة مصغرة لخصائص كرت الإنترنت الرقمي (Package Voucher Mini Badge)
class PackageVoucherMiniBadge extends StatelessWidget {
  const PackageVoucherMiniBadge({
    super.key,
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16.r, color: Colors.white.withValues(alpha: 0.85)),
        SizedBox(width: 5.w),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
