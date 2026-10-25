import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/features/auth/presentation/controllers/two_factor_auth_controller.dart';
import 'package:netsales/features/auth/presentation/widgets/otp/two_factor_device_card.dart';
import 'package:netsales/features/auth/presentation/widgets/otp/two_factor_form_card.dart';
import 'package:netsales/features/auth/presentation/widgets/otp/two_factor_header_section.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';

/// واجهة التحقق بخطوتين وتأكيد الجهاز (TwoFactorAuthScreen)
///
/// مبنية وفق نمط المعمارية المعيارية الموحدة (Modular Composite View)؛ خالية تماماً
/// من دوال `_build...()` المساعدة، وتعتمد على [CustomAppScaffold] الموحد لتوفير التدرج السيادي والمظهر الزجاجي الانسيابي.
class TwoFactorAuthScreen extends GetView<TwoFactorAuthController> {
  const TwoFactorAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomAppScaffold(
      useSurfaceMesh: true,
      showBackButton: true,
      onBackPressed: controller.cancelAndGoBack,
      maxWidth: AppBreakpoints.maxFormWidth,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(
          top: CustomAppScaffold.topBarHeight(context) + AppSpacing.xs,
          bottom: AppSpacing.xl,
          left: context.responsive(
            mobile: AppSpacing.lg,
            tablet: AppSpacing.xl,
          ),
          right: context.responsive(
            mobile: AppSpacing.lg,
            tablet: AppSpacing.xl,
          ),
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
            const TwoFactorFormCard(),

            AppSpacing.vLg,
          ],
        ),
      ),
    );
  }
}
