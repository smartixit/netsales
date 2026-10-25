import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_gradients.dart';
import 'package:netsales/features/auth/presentation/controllers/verify_otp_controller.dart';
import 'package:netsales/features/auth/presentation/widgets/otp/verify_otp_form_card.dart';
import 'package:netsales/features/auth/presentation/widgets/otp/verify_otp_header_section.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';

/// واجهة التحقق من رمز الاستعادة OTP المعتمدة على Pinput (VerifyOtpScreen)
///
/// مبنية وفق نمط الـ Modular Composite View؛ حيث لا تحتوي على أي دوال مساعدة `_build...()`،
/// بل تجمع ودجات مستقلة ومعزولة لإعادة البناء الذري والأداء الأقصى.
class VerifyOtpScreen extends GetView<VerifyOtpController> {
  const VerifyOtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomAppScaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.all(AppSpacing.xs),
          child: CustomButton.icon(
            icon: Icons.arrow_back_ios_new_rounded,
            tooltip: 'رجوع',
            iconSize: 18.r,
            dimension: 40.r,
            foregroundColor: colors.onSurface,
            backgroundColor: Colors.transparent,
            onPressed: controller.goToChangePhone,
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
          ),
        ),
      ),
    );
  }
}
