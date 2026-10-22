import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_gradients.dart';
import 'package:netsales/features/auth/presentation/controllers/register_pos_controller.dart';
import 'package:netsales/features/auth/presentation/widgets/register/pos_agent_info_card.dart';
import 'package:netsales/features/auth/presentation/widgets/register/pos_info_card.dart';
import 'package:netsales/features/auth/presentation/widgets/register/register_pos_header_section.dart';
import 'package:netsales/features/auth/presentation/widgets/register/register_pos_submit_section.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

/// واجهة تقديم طلب تسجيل نقطة بيع / وكيل جديد (RegisterPosScreen)
///
/// مبنية وفق نمط الـ Modular Composite View؛ حيث لا تحتوي على أي دوال مساعدة `_build...()`،
/// بل تجمع ودجات مستقلة ومعزولة لإعادة البناء الذري والأداء الأقصى.
class RegisterPosScreen extends GetView<RegisterPosController> {
  const RegisterPosScreen({super.key});

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
            tooltip: 'رجوع',
            iconSize: 18.r,
            dimension: 40.r,
            foregroundColor: colors.onSurface,
            backgroundColor: Colors.transparent,
            onPressed: controller.goToLogin,
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
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. ترويسة الشاشة المستقلة (RegisterPosHeaderSection)
                    const RegisterPosHeaderSection(),

                    AppSpacing.vLg,

                    // 2. بطاقة بيانات نقطة البيع والشعار والموقع (PosInfoCard)
                    PosInfoCard(controller: controller),

                    AppSpacing.vLg,

                    // 3. بطاقة بيانات وكيل ومسؤول نقطة البيع والصورة الشخصية (PosAgentInfoCard)
                    PosAgentInfoCard(controller: controller),

                    AppSpacing.vXl,

                    // 4. أزرار إرسال الطلب والتوجيه الموحدة (RegisterPosSubmitSection)
                    RegisterPosSubmitSection(controller: controller),

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
