import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/cards/custom_surface_card.dart';

/// كرت تسجيل الخروج التنفيذي المباشر من مركز الحساب
class ProfileLogoutTile extends StatelessWidget {
  const ProfileLogoutTile({super.key, required this.onLogout});

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomSurfaceCard(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      backgroundColor: colors.error.withValues(alpha: 0.08),
      borderColor: colors.error.withValues(alpha: 0.28),
      onTap: onLogout,
      child: Row(
        children: [
          Container(
            width: 42.r,
            height: 42.r,
            decoration: BoxDecoration(
              color: colors.error.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(Icons.logout_rounded, color: colors.error, size: 22.r),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تسجيل الخروج من الحساب',
                  style: AppTypography.titleSmall.copyWith(
                    color: colors.error,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'إنهاء الجلسة والعودة لشاشة تسجيل الدخول',
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.error.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 15.r,
            color: colors.error.withValues(alpha: 0.7),
          ),
        ],
      ),
    );
  }
}
