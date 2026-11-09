import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/auth/presentation/controllers/security_settings_controller.dart';
import 'package:netsales/features/auth/presentation/widgets/two_factor_disable_dialog.dart';
import 'package:netsales/features/auth/presentation/widgets/two_factor_enable_sheet.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';
import 'package:netsales/widgets/inputs/custom_switch.dart';

/// شاشة إعدادات الأمان والمصادقة الثنائية (SecuritySettingsScreen)
class SecuritySettingsScreen extends GetView<SecuritySettingsController> {
  const SecuritySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomAppScaffold(
      showBackButton: true,
      appBarTitle: 'إعدادات الأمان والحماية',
      appBarSubtitle: 'إدارة المصادقة الثنائية وحماية حسابك وأجهزتك المقترنة',
      body: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        children: [
          // 1. بطاقة المصادقة الثنائية الأساسية
          Obx(() {
            final isEnabled = controller.is2faEnabled.value;
            final statusColor = isEnabled ? colors.success : colors.warning;

            return Container(
              padding: EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: isEnabled
                      ? colors.success.withValues(alpha: 0.3)
                      : colors.outlineVariant.withValues(alpha: 0.4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.r),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isEnabled
                              ? Icons.shield_rounded
                              : Icons.gpp_maybe_rounded,
                          color: statusColor,
                          size: 28.sp,
                        ),
                      ),
                      AppSpacing.hMd,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'المصادقة الثنائية (2FA)',
                                  style: AppTypography.titleMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                CustomSwitch(
                                  value: isEnabled,
                                  onChanged: (val) {
                                    if (val) {
                                      TwoFactorEnableSheet.show(
                                        context,
                                        controller,
                                      );
                                    } else {
                                      TwoFactorDisableDialog.show(
                                        context,
                                        controller,
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                            AppSpacing.vXxs,
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                isEnabled
                                    ? 'مفعلة ومحمية'
                                    : 'معطلة - الحساب أقل حماية',
                                style: AppTypography.badgeText.copyWith(
                                  color: statusColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.vMd,
                  Text(
                    isEnabled
                        ? 'المصادقة الثنائية مفعلة على حسابك. سيطلب النظام إدخال رمز تحقق مؤقت (OTP) يتم إرساله إلى هاتفك (${controller.maskedPhone}) عند محاولة الدخول من أجهزة جديدة.'
                        : 'عند تفعيل هذه الميزة، سيتطلب تسجيل الدخول إدخال رمز أمان مؤقت (OTP) يصلك عبر SMS، مما يضمن أمان حسابك حتى لو تم كشف كلمة المرور.',
                    style: AppTypography.bodySmall.copyWith(
                      color: colors.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  AppSpacing.vLg,
                  SizedBox(
                    width: double.infinity,
                    child: isEnabled
                        ? CustomButton.outline(
                            text: 'تعطيل الحماية الثنائية',
                            icon: Icons.shield_outlined,
                            foregroundColor: colors.error,
                            onPressed: () => TwoFactorDisableDialog.show(
                              context,
                              controller,
                            ),
                          )
                        : CustomButton.primary(
                            text: 'تفعيل المصادقة الثنائية الآن',
                            icon: Icons.verified_user_rounded,
                            onPressed: () =>
                                TwoFactorEnableSheet.show(context, controller),
                          ),
                  ),
                ],
              ),
            );
          }),

          AppSpacing.vLg,

          // 2. بطاقة الأجهزة والجلسات المقترنة
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.devices_rounded,
                  color: colors.primary,
                  size: 24.sp,
                ),
              ),
              title: Text(
                'الأجهزة والجلسات النشطة',
                style: AppTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                'مراجعة الأجهزة المقترنة بحسابك وإنهاء الجلسات غير المصرح بها',
                style: AppTypography.bodySmall.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16.sp,
                color: colors.onSurfaceVariant,
              ),
              onTap: () => Get.toNamed<dynamic>(AppRoutes.activeSessions),
            ),
          ),

          AppSpacing.vLg,

          // 3. إرشادات أمنية سيادية
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: colors.surfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 20.sp,
                  color: colors.onSurfaceVariant,
                ),
                AppSpacing.hSm,
                Expanded(
                  child: Text(
                    'نصيحة أمنية: لا تشارك رموز التحقق أو كلمات المرور مع أي شخص. موظفو الدعم الفني لن يطلبوا منك رمز الأمان أبداً.',
                    style: AppTypography.bodySmall.copyWith(
                      color: colors.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
