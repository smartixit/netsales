import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/features/auth/presentation/controllers/verify_otp_controller.dart';
import 'package:netsales/features/auth/presentation/widgets/otp/verify_otp_form_card.dart';
import 'package:netsales/features/auth/presentation/widgets/otp/verify_otp_header_section.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';

/// واجهة التحقق من رمز الاستعادة OTP المعتمدة على Pinput (VerifyOtpScreen)
///
/// مبنية وفق نمط الـ Modular Composite View؛ حيث لا تحتوي على أي دوال مساعدة `_build...()`،
/// وتعتمد على [CustomAppScaffold] الموحد لتوفير التدرج السيادي والمظهر الزجاجي الانسيابي الخالي من أي قطع حاد.
class VerifyOtpScreen extends GetView<VerifyOtpController> {
  const VerifyOtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomAppScaffold(
      useSurfaceMesh: true,
      showBackButton: true,
      onBackPressed: controller.goToChangePhone,
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
            // 1. قسم الترويسة ورقم الهاتف المقنع
            VerifyOtpHeaderSection(
              maskedPhone: controller.maskedPhone,
              onChangePhone: controller.goToChangePhone,
            ),

            AppSpacing.vXl,

            // 2. بطاقة نموذج إدخال الرمز
            const VerifyOtpFormCard(),

            AppSpacing.vLg,
          ],
        ),
      ),
    );
  }
}
