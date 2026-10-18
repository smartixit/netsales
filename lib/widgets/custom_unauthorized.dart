import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

/// ============================================================================
/// شاشة الرفض والتنبيه الأمني (Custom Unauthorized Screen)
/// ============================================================================
/// تظهر عند محاولة الوصول المباشر (Deep Links) إلى مسار غير مصرح به للمستخدم.
class CustomUnauthorized extends StatelessWidget {
  const CustomUnauthorized({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(AppSpacing.xxl),
                  decoration: BoxDecoration(
                    color: colors.warning.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.security_rounded,
                    size: 64.r,
                    color: colors.warning,
                  ),
                ),
                AppSpacing.vLg,
                Text(
                  'غير مصرح بالوصول',
                  style: AppTypography.titleLarge.copyWith(
                    color: colors.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                AppSpacing.vSm,
                Text(
                  'ليس لديك الصلاحية الكافية للوصول إلى هذا المسار أو تنفيذ هذا الإجراء.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                AppSpacing.vXl,
                CustomButton.primary(
                  text: 'العودة للرئيسية',
                  icon: Icons.home_rounded,
                  onPressed: () {
                    Get.offAllNamed(AppRoutes.dashboard);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
