import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/features/auth/presentation/controllers/login_controller.dart';
import 'package:netsales/features/auth/presentation/widgets/login/login_footer_links.dart';
import 'package:netsales/features/auth/presentation/widgets/login/login_form_card.dart';
import 'package:netsales/features/auth/presentation/widgets/login/login_header_section.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';

/// واجهة تسجيل الدخول الرئيسية للنظام (Login Screen)
///
/// مبنية وفق نمط المعمارية المعيارية الموحدة (Modular Composite View)، وتعتمد على
/// [CustomAppScaffold] الموحد لتوفير التدرج السيادي والمظهر المتجاوب دون تكرار للأكواد.
class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomAppScaffold(
      useSurfaceMesh: true,
      maxWidth: AppBreakpoints.maxFormWidth,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: context.responsive(
            mobile: AppSpacing.lg,
            tablet: AppSpacing.xl,
          ),
          vertical: AppSpacing.lg,
        ),
        child:  Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppSpacing.vMd,

            // 1. قسم الشعار والعنوان والترحيب
            LoginHeaderSection(),

            AppSpacing.vXl,

            // 2. بطاقة نموذج تسجيل الدخول
            LoginFormCard(),

            AppSpacing.vXl,

            // 3. روابط التذييل والأمان
            LoginFooterLinks(),

            AppSpacing.vMd,
          ],
        ),
      ),
    );
  }
}
