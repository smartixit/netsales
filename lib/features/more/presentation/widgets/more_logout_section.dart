import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/more/presentation/controllers/more_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

/// ============================================================================
/// قسم تسجيل الخروج ومعلومات النظام (MoreLogoutSection)
/// ============================================================================
class MoreLogoutSection extends StatelessWidget {
  final MoreController controller;

  const MoreLogoutSection({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      children: [
        CustomButton.danger(
          text: 'تسجيل الخروج من الحساب',
          icon: Icons.logout_rounded,
          height: 48.h,
          onPressed: () => controller.confirmLogout(context),
        ),
        AppSpacing.vMd,
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.18),
              width: 0.6.w,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6.r,
                height: 6.r,
                decoration: BoxDecoration(
                  color: colors.success,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                'منظومة NetSales المؤسسية • v1.0.0',
                style: AppTypography.labelSmall.copyWith(
                  color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w600,
                  fontSize: 10.sp,
                ),
              ),
            ],
          ),
        ),
        AppSpacing.vXl,
      ],
    );
  }
}
