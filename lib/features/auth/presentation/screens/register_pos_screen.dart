import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/features/auth/presentation/controllers/register_pos_controller.dart';
import 'package:netsales/features/auth/presentation/widgets/register/pos_agent_info_card.dart';
import 'package:netsales/features/auth/presentation/widgets/register/pos_info_card.dart';
import 'package:netsales/features/auth/presentation/widgets/register/register_pos_header_section.dart';
import 'package:netsales/features/auth/presentation/widgets/register/register_pos_submit_section.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';

/// واجهة تقديم طلب تسجيل نقطة بيع / وكيل جديد (RegisterPosScreen)
///
/// مبنية وفق نمط الـ Modular Composite View؛ حيث لا تحتوي على أي دوال مساعدة `_build...()`،
/// وتعتمد على [CustomAppScaffold] الموحد لتوفير التدرج السيادي والمظهر الزجاجي الانسيابي الخالي من أي قطع حاد.
class RegisterPosScreen extends GetView<RegisterPosController> {
  const RegisterPosScreen({super.key});

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
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. ترويسة الشاشة المستقلة (RegisterPosHeaderSection)
              RegisterPosHeaderSection(),

              AppSpacing.vLg,

              // 2. بطاقة بيانات نقطة البيع والشعار والموقع (PosInfoCard)
              PosInfoCard(),

              AppSpacing.vLg,

              // 3. بطاقة بيانات وكيل ومسؤول نقطة البيع والصورة الشخصية (PosAgentInfoCard)
              PosAgentInfoCard(),

              AppSpacing.vXl,

              // 4. أزرار إرسال الطلب والتوجيه الموحدة (RegisterPosSubmitSection)
              RegisterPosSubmitSection(),

              AppSpacing.vLg,
            ],
          ),
        ),
      ),
    );
  }
}
