import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_gradients.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/auth/presentation/controllers/reset_password_controller.dart';
import 'package:netsales/features/auth/presentation/widgets/forgot_password/reset_password_form_card.dart';
import 'package:netsales/features/auth/presentation/widgets/forgot_password/reset_password_security_banner.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';

/// واجهة تعيين وتغيير كلمة المرور الإلزامية والاختيارية والمباشرة (ResetPasswordScreen)
///
/// مبنية وفق نمط الـ Modular Composite View؛ حيث لا تحتوي على أي دوال مساعدة `_build...()`،
/// بل تجمع ودجات مستقلة ومعزولة لإعادة البناء الذري والأداء الأقصى.
class ResetPasswordScreen extends GetView<ResetPasswordController> {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isForcedNonDirect = !controller.isDirectReset && controller.isForced;

    return PopScope(
      canPop: !isForcedNonDirect,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          controller.abortOrLogout();
        }
      },
      child: CustomAppScaffold(
        backgroundColor: colors.surface,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Padding(
            padding: EdgeInsets.all(AppSpacing.xs),
            child: CustomButton.icon(
              icon: isForcedNonDirect
                  ? Icons.logout_rounded
                  : Icons.arrow_back_ios_new_rounded,
              tooltip: isForcedNonDirect ? 'تسجيل الخروج' : 'رجوع',
              iconSize: 18.r,
              dimension: 40.r,
              foregroundColor: colors.onSurface,
              backgroundColor: Colors.transparent,
              onPressed: controller.abortOrLogout,
            ),
          ),
          title: Text(
            controller.isDirectReset
                ? 'تعيين كلمة المرور'
                : (controller.isForced ? 'تأمين الحساب' : 'تغيير كلمة المرور'),
            style: AppTypography.titleMedium.copyWith(color: colors.onSurface),
          ),
          centerTitle: true,
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
                    // 1. شارة التنبيه الأمني المؤسسي
                    ResetPasswordSecurityBanner(
                      isForced: controller.isForced,
                      isDirectReset: controller.isDirectReset,
                    ),

                    AppSpacing.vLg,

                    // 2. بطاقة النموذج المستقلة
                    const ResetPasswordFormCard(),

                    AppSpacing.vLg,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
