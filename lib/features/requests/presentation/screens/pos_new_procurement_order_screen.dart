import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/requests/presentation/controllers/pos_new_procurement_order_controller.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_checkout_bar.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_edit_mode_banner.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_network_context_section.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_package_selection_section.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_pos_context_section.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_sale_type_selector.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_section_heading.dart';
import 'package:netsales/widgets/cards/custom_page_hero_card.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';

/// مساحة إنشاء طلب التوريد الواحدة: السياق، الباقات، الكميات والإرسال دون شاشة مراجعة منفصلة.
class PosNewProcurementOrderScreen
    extends GetView<PosNewProcurementOrderController> {
  const PosNewProcurementOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Obx(() {
      final isEditMode = controller.isEditing.value;
      final title = controller.screenTitle;
      return CustomAppScaffold(
        appBar: AppBar(
          title: Text(
            title,
            style: AppTypography.titleMedium.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        bottomNavigationBar: const ProcurementCheckoutBar(),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding =
                constraints.maxWidth < AppBreakpoints.mobileSmallMax
                ? AppSpacing.sm
                : AppSpacing.cardPadding;
            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppBreakpoints.maxFormWidth,
                ),
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    AppSpacing.md,
                    horizontalPadding,
                    AppSpacing.xl,
                  ),
                  child: Form(
                    key: controller.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomPageHeroCard(
                          title: isEditMode
                              ? 'تحديث طلب التوريد'
                              : 'مساحة طلب التوريد',
                          subtitle: isEditMode
                              ? 'مراجعة تفاصيل الطلب #${controller.editingRequestId.value ?? ''} وتعديل الكميات قبل حفظ التغييرات.'
                              : 'اختر الشبكة ونقطة البيع، ثم كوّن طلبك مباشرة من الباقات والأسعار المتاحة.',
                          icon: Icons.inventory_2_rounded,
                        ),
                        if (isEditMode) ...[
                          AppSpacing.vSm,
                          const ProcurementEditModeBanner(),
                        ],
                        AppSpacing.vMd,
                        const ProcurementNetworkContextSection(),
                        AppSpacing.vSm,
                        const ProcurementPosContextSection(),
                        AppSpacing.vLg,
                        const ProcurementSectionHeading(
                          title: 'طريقة التسعير',
                          subtitle:
                              'تتغير تعرفة العرض حسب طريقة الدفع المختارة.',
                        ),
                        AppSpacing.vSm,
                        const ProcurementSaleTypeSelector(),
                        AppSpacing.vLg,
                        const ProcurementPackageSelectionSection(),
                        AppSpacing.vLg,
                        CustomTextField(
                          controller: controller.notesController,
                          label: 'ملاحظات للشبكة (اختياري)',
                          hint: 'أضف توضيحاً يساعد الشبكة على معالجة الطلب',
                          maxLines: 3,
                          isRequired: false,
                        ),
                        AppSpacing.vSm,
                        Text(
                          'سيبقى الطلب قيد الانتظار حتى تراجعه الشبكة وتعتمده. لا تُنشأ فاتورة عند الإرسال.',
                          style: AppTypography.bodySmall.copyWith(
                            color: colors.onSurfaceVariant,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }
}
