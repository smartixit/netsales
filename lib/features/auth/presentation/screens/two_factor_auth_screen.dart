import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_gradients.dart';
import 'package:netsales/features/auth/presentation/controllers/two_factor_auth_controller.dart';
import 'package:netsales/features/auth/presentation/widgets/otp/two_factor_device_card.dart';
import 'package:netsales/features/auth/presentation/widgets/otp/two_factor_form_card.dart';
import 'package:netsales/features/auth/presentation/widgets/otp/two_factor_header_section.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

/// واجهة التحقق بخطوتين وتأكيد الجهاز (TwoFactorAuthScreen)
///
/// مبنية وفق نمط المعمارية المعيارية الموحدة (Modular Composite View)؛ خالية تماماً
/// من دوال `_build...()` المساعدة، وتجمع حصرياً ودجات ذرية مستقلة ذات كفاءة أداء عليا.
class TwoFactorAuthScreen extends GetView<TwoFactorAuthController> {
  const TwoFactorAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.all(AppSpacing.xs),
          child: CustomButton.icon(
            icon: Icons.arrow_back_ios_new_rounded,
            tooltip: 'إلغاء والعودة',
            iconSize: 18.r,
            dimension: 40.r,
            foregroundColor: colors.onSurface,
            backgroundColor: Colors.transparent,
            onPressed: controller.cancelAndGoBack,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: AppGradients.surfaceMesh(context),
        ),
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. قسم الترويسة والأيقونة الأمنية
                  TwoFactorHeaderSection(
                    maskedPhone: controller.maskedPhone,
                  ),

                  AppSpacing.vLg,

                  // 2. بطاقة معلومات الجهاز المطلوب تأكيده
                  TwoFactorDeviceCard(
                    displayDeviceName: controller.displayDeviceName,
                  ),

                  AppSpacing.vLg,

                  // 3. بطاقة نموذج إدخال رمز التحقق
                  TwoFactorFormCard(
                    controller: controller,
                  ),

                  AppSpacing.vLg,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
