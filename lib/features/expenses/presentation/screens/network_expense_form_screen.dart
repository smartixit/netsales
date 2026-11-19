import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/features/expenses/presentation/controllers/network_expense_form_controller.dart';
import 'package:netsales/features/expenses/presentation/widgets/expense_form/expense_form_attachments_section.dart';
import 'package:netsales/features/expenses/presentation/widgets/expense_form/expense_form_checkout_bar.dart';
import 'package:netsales/features/expenses/presentation/widgets/expense_form/expense_form_header_section.dart';
import 'package:netsales/features/expenses/presentation/widgets/expense_form/expense_form_items_section.dart';
import 'package:netsales/widgets/cards/custom_page_hero_card.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';

/// شاشة تسجيل أو تعديل مصروف تشغيلي لمشغل الشبكة
class NetworkExpenseFormScreen extends GetView<NetworkExpenseFormController> {
  const NetworkExpenseFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = AppBreakpoints.screenMargin(context);

    return Obx(() {
      final isEdit = controller.isEditMode.value;

      if (controller.isLoading.value) {
        return CustomAppScaffold(
          appBarTitle: isEdit ? 'تعديل المصروف التشغيلي' : 'مصروف تشغيلي جديد',
          body: Padding(
            padding: EdgeInsets.all(AppSpacing.cardPadding),
            child: const CustomStateView.loading(
              presentation: CustomStatePresentation.skeletonOnly,
              skeleton: CustomStateSkeleton(
                layout: CustomStateSkeletonLayout.list,
                itemCount: 4,
                cardHeight: 90,
              ),
            ),
          ),
        );
      }

      return CustomAppScaffold(
        appBarTitle: isEdit ? 'تعديل المصروف التشغيلي' : 'مصروف تشغيلي جديد',
        showBackButton: true,
        bottomNavigationBar: ExpenseFormCheckoutBar(controller: controller),
        body: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            AppSpacing.md,
            horizontalPadding,
            AppSpacing.xl,
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. الترويسة القيادية للنموذج
                  CustomPageHeroCard(
                    title: isEdit
                        ? 'تعديل بيانات المصروف'
                        : 'سند صرف مصروفات تشغيلية',
                    subtitle: isEdit
                        ? 'تعديل بنود المصروف أو المرفقات مع إعادة التسوية التلقائية لمحفظة الشبكة.'
                        : 'تسجيل المصروفات التشغيلية المباشرة مع الخصم السيادي الفوري من محفظة الشبكة.',
                    icon: Icons.payments_outlined,
                  ),
                  AppSpacing.vMd,

                  // 2. قسم الترويسة (الشبكة والتاريخ)
                  ExpenseFormHeaderSection(controller: controller),
                  AppSpacing.vLg,

                  // 3. قسم البنود المالية
                  ExpenseFormItemsSection(controller: controller),
                  AppSpacing.vLg,

                  // 4. قسم المرفقات والوثائق
                  ExpenseFormAttachmentsSection(controller: controller),
                  AppSpacing.vXl,
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
