import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_gradients.dart';
import 'package:netsales/features/auth/presentation/controllers/login_controller.dart';
import 'package:netsales/features/auth/presentation/widgets/login_footer_links.dart';
import 'package:netsales/features/auth/presentation/widgets/login_form_card.dart';
import 'package:netsales/features/auth/presentation/widgets/login_header_section.dart';

/// واجهة تسجيل الدخول الرئيسية للنظام (Login Screen)
class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.surface,
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
                vertical: AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppSpacing.vMd,

                  // 1. قسم الشعار والعنوان والترحيب
                  const LoginHeaderSection(),

                  AppSpacing.vXl,

                  // 2. بطاقة نموذج تسجيل الدخول
                  const LoginFormCard(),

                  AppSpacing.vXl,

                  // 3. روابط التذييل والأمان
                  const LoginFooterLinks(),

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
