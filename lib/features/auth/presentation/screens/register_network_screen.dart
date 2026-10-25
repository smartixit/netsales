import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/features/auth/presentation/controllers/register_network_controller.dart';
import 'package:netsales/features/auth/presentation/widgets/register/network_info_card.dart';
import 'package:netsales/features/auth/presentation/widgets/register/network_owner_info_card.dart';
import 'package:netsales/features/auth/presentation/widgets/register/register_network_header_section.dart';
import 'package:netsales/features/auth/presentation/widgets/register/register_network_submit_section.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';

/// واجهة تقديم طلب تسجيل مزود شبكة إنترنت جديد (RegisterNetworkScreen)
///
/// مبنية وفق نمط الـ Modular Composite View؛ حيث لا تحتوي على أي دوال مساعدة `_build...()`،
/// وتعتمد على [CustomAppScaffold] الموحد لتوفير التدرج السيادي والمظهر الزجاجي الانسيابي الخالي من أي قطع حاد.
class RegisterNetworkScreen extends GetView<RegisterNetworkController> {
  const RegisterNetworkScreen({super.key});

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
              // 1. ترويسة الشاشة المستقلة (RegisterNetworkHeaderSection)
              RegisterNetworkHeaderSection(),

              AppSpacing.vLg,

              // 2. بطاقة بيانات الشبكة والشعار والموقع (NetworkInfoCard)
              NetworkInfoCard(),

              AppSpacing.vLg,

              // 3. بطاقة بيانات مالك ومسؤول الشبكة والصورة الشخصية (NetworkOwnerInfoCard)
              NetworkOwnerInfoCard(),

              AppSpacing.vXl,

              // 4. أزرار إرسال الطلب والتوجيه الموحدة (RegisterNetworkSubmitSection)
              RegisterNetworkSubmitSection(),

              AppSpacing.vLg,
            ],
          ),
        ),
      ),
    );
  }
}
