import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_motion.dart';
import 'package:netsales/core/themes/app_typography.dart';

/// بطاقة معلومات الجهاز المطلوب تأكيده في التحقق بخطوتين (TwoFactorDeviceCard)
class TwoFactorDeviceCard extends StatelessWidget {
  const TwoFactorDeviceCard({
    super.key,
    required this.displayDeviceName,
  });

  final String displayDeviceName;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              color: colors.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              Icons.phonelink_lock_rounded,
              color: colors.primary,
              size: 20.r,
            ),
          ),
          AppSpacing.hMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'محاولة دخول من جهاز جديد',
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                AppSpacing.vXxs,
                Text(
                  displayDeviceName,
                  style: AppTypography.titleSmall.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          AppSpacing.hSm,
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xxs,
            ),
            decoration: BoxDecoration(
              color: colors.warning.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.full),
              border: Border.all(
                color: colors.warning.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.shield_outlined,
                  size: 13.r,
                  color: colors.warning,
                ),
                AppSpacing.hXxs,
                Text(
                  'يتطلب التوثيق',
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.warning,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: AppMotion.normal)
        .slideY(
          begin: 0.1,
          end: 0,
          duration: AppMotion.normal,
          curve: AppMotion.emphasized,
        );
  }
}
