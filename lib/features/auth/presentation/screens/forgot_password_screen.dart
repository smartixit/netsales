import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/features/auth/presentation/controllers/forgot_password_controller.dart';
import 'package:netsales/features/auth/presentation/widgets/forgot_password/forgot_password_form_card.dart';
import 'package:netsales/features/auth/presentation/widgets/forgot_password/forgot_password_header_section.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';

/// واجهة طلب استعادة كلمة المرور (ForgotPasswordScreen)
///
/// مبنية وفق نمط الـ Modular Composite View؛ حيث لا تحتوي على أي دوال مساعدة `_build...()`،
/// وتعتمد على [CustomAppScaffold] الموحد لتوفير التدرج السيادي والمظهر الزجاجي الانسيابي الخالي من أي قطع حاد.
class ForgotPasswordScreen extends GetView<ForgotPasswordController> {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomAppScaffold(
      useSurfaceMesh: true,
      showBackButton: true,
      onBackPressed: controller.goToLogin,
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
            // 1. قسم الشعار والترحيب الإرشادي
            ForgotPasswordHeaderSection(),

            AppSpacing.vXl,

            // 2. بطاقة النموذج المستقلة
            ForgotPasswordFormCard(),

            AppSpacing.vLg,
          ],
        ),
      ),
    );
  }
}
