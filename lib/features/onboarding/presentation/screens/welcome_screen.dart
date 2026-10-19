import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_gradients.dart';
import 'package:netsales/core/themes/app_motion.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/onboarding/presentation/controllers/welcome_controller.dart';
import 'package:netsales/widgets/brand/custom_brand_logo.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/cards/custom_action_card.dart';
import 'package:netsales/widgets/dividers/custom_labeled_divider.dart';

/// واجهة الترحيب واختيار الصفة (Welcome Screen)
/// واجهة عرض نقية (Lean View) تعتمد حصرياً على الودجات المركزية ورموز الـ Core والتصميم التكيفي.
class WelcomeScreen extends GetView<WelcomeController> {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.surface,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: AppGradients.surfaceMesh(context)),
        child: SafeArea(
          child: ResponsiveContentWrapper(
            maxWidth: AppBreakpoints.maxFormWidth,
            alignment: Alignment.center,
            padding: EdgeInsets.zero,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: context.responsive(
                  mobile: AppSpacing.lg,
                  tablet: AppSpacing.xl,
                ),
                vertical: AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                AppSpacing.vLg,

                // 1. الشعار المركزي الموحد (CustomBrandLogo)
                const CustomBrandLogo.md()
                    .animate()
                    .scale(
                      begin: const Offset(0.85, 0.85),
                      end: const Offset(1.0, 1.0),
                      duration: AppMotion.slow,
                      curve: AppMotion.springy,
                    )
                    .fadeIn(duration: AppMotion.normal),

                AppSpacing.vMd,

                // 2. العنوان الترحيبي الرئيسي
                Text(
                      'مرحباً بك في NetSales',
                      style: AppTypography.headlineMedium.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    )
                    .animate()
                    .fadeIn(duration: AppMotion.normal)
                    .slideY(
                      begin: 0.15,
                      end: 0,
                      duration: AppMotion.normal,
                      curve: AppMotion.emphasized,
                    ),

                AppSpacing.vXs,

                // 3. النص الفرعي الإرشادي
                Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      child: Text(
                        'المنظومة الذكية لإدارة مبيعات الشبكات ونقاط البيع. اختر صفة حسابك وابدأ رحلة التحول الرقمي.',
                        style: AppTypography.bodyMedium.copyWith(
                          color: colors.onSurfaceVariant,
                          height: 1.45,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                    .animate()
                    .fadeIn(duration: AppMotion.normal)
                    .slideY(
                      begin: 0.15,
                      end: 0,
                      duration: AppMotion.normal,
                      curve: AppMotion.emphasized,
                    ),

                AppSpacing.vXl,

                // 4. بطاقات اختيار الدور الموحدة (CustomActionCard)
                CustomActionCard(
                      title: 'مزود شبكة',
                      description:
                          'تحكم متكامل في مبيعات الشبكة، باقات الخدمة، ربط نقاط البيع، وإدارة الأرصدة والتقارير المالية.',
                      icon: Icons.router_rounded,
                      accentColor: colors.primary,
                      onTap: controller.goToRegisterNetwork,
                    )
                    .animate()
                    .fadeIn(duration: AppMotion.normal)
                    .slideY(
                      begin: 0.15,
                      end: 0,
                      duration: AppMotion.normal,
                      curve: AppMotion.emphasized,
                    ),

                AppSpacing.vMd,

                CustomActionCard(
                      title: 'وكيل نقطة بيع',
                      description:
                          'إدارة ذكية لمبيعات النقطة، إرسال طلبات التزويد، إصدار الفواتير وطباعة كشوفات الحساب بكل سهولة.',
                      icon: Icons.storefront_rounded,
                      accentColor: colors.secondary,
                      onTap: controller.goToRegisterPos,
                    )
                    .animate()
                    .fadeIn(duration: AppMotion.normal)
                    .slideY(
                      begin: 0.15,
                      end: 0,
                      duration: AppMotion.normal,
                      curve: AppMotion.emphasized,
                    ),

                AppSpacing.vLg,

                // 5. الفاصل الأنيق الموحد (CustomLabeledDivider)
                const CustomLabeledDivider(
                  label: 'أو إذا كان لديك حساب بالفعل',
                ),

                AppSpacing.vMd,

                // 6. زر تسجيل الدخول الرئيسي
                CustomButton.primary(
                  text: 'تسجيل الدخول إلى حسابك',
                  icon: Icons.login_rounded,
                  onPressed: controller.goToLogin,
                ),

                AppSpacing.vMd,
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
}
