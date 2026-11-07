import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

/// بطاقة إنهاء وتسجيل الخروج من الجلسات الأخرى (Logout Other Devices Action Card)
class LogoutOtherDevicesCard extends StatelessWidget {
  const LogoutOtherDevicesCard({
    super.key,
    required this.deviceCount,
    required this.isLoading,
    required this.onLogoutOtherDevices,
  });

  final int deviceCount;
  final bool isLoading;
  final VoidCallback onLogoutOtherDevices;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.error.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: colors.error.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: colors.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.phonelink_erase_rounded,
              color: colors.error,
              size: 22.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'أجهزة أخرى متصلة ($deviceCount)',
                  style: AppTypography.titleSmall.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'يمكنك تسجيل الخروج من كافة الجلسات الأخرى بنقرة واحدة.',
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          CustomButton.secondary(
            text: 'إنهاء الجلسات',
            loading: isLoading,
            onPressed: onLogoutOtherDevices,
          ),
        ],
      ),
    );
  }
}

