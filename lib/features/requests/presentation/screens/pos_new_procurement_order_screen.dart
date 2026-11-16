import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/enums/sale_type.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/requests/presentation/controllers/pos_procurement_controller.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_cart_section.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_checkout_bar.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_financial_quote_card.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_network_context_section.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_package_selection_section.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_pos_context_section.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_sheet_quantity_section.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';
import 'package:netsales/widgets/indicators/custom_segmented_bar.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';

/// إنشاء الطلب على مرحلتين: اختيار الباقات والكميات، ثم مراجعة الطلب وإرساله.
class PosNewProcurementOrderScreen extends GetView<PosProcurementController> {
  const PosNewProcurementOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      final isReviewStep = controller.currentOrderStep.value == 1;
      final isEditMode = controller.isEditing.value;
      final title = isEditMode
          ? 'تعديل طلب التوريد #${controller.editingRequestId.value}'
          : 'طلب توريد جديد';

      return CustomAppScaffold(
        appBar: AppBar(
          title: Text(title, style: AppTypography.titleMedium.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.bold,
          )),
          centerTitle: true,
          elevation: 0,
          leading: isReviewStep
              ? IconButton(
                  tooltip: 'العودة لاختيار الباقات',
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: controller.returnToOrderItems,
                )
              : null,
        ),
        bottomNavigationBar: const ProcurementCheckoutBar(),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth < AppBreakpoints.mobileSmallMax
                ? AppSpacing.sm
                : AppSpacing.cardPadding;
            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: AppBreakpoints.maxFormWidth),
                child: SingleChildScrollView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                        _ProcurementStepIndicator(
                          isReviewStep: isReviewStep,
                          colors: colors,
                        ),
                        AppSpacing.vLg,
                        if (!isReviewStep) ...[
                          const ProcurementPosContextSection(),
                          AppSpacing.vMd,
                          const ProcurementNetworkContextSection(),
                          AppSpacing.vLg,
                          const ProcurementPackageSelectionSection(),
                          if (controller.selectedPackage.value != null) ...[
                            AppSpacing.vLg,
                            const ProcurementSheetQuantitySection(),
                          ],
                        ] else ...[
                          const ProcurementCartSection(),
                          AppSpacing.vLg,
                          Text(
                            'طريقة الدفع',
                            style: AppTypography.titleSmall.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          AppSpacing.vXs,
                          CustomSegmentedBar(
                            selectedIndex: controller.selectedSaleType.value == SaleType.cash ? 0 : 1,
                            onSegmentChanged: (index) {
                              controller.selectedSaleType.value =
                                  index == 0 ? SaleType.cash : SaleType.credit;
                              controller.fetchServerQuote();
                            },
                            items: const [
                              CustomSegmentItem(label: 'نقدي', icon: Icons.payments_outlined),
                              CustomSegmentItem(label: 'آجل', icon: Icons.credit_card_outlined),
                            ],
                          ),
                          AppSpacing.vLg,
                          const ProcurementFinancialQuoteCard(),
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

class _ProcurementStepIndicator extends StatelessWidget {
  const _ProcurementStepIndicator({
    required this.isReviewStep,
    required this.colors,
  });

  final bool isReviewStep;
  final dynamic colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StepMarker(number: '1', label: 'اختيار الباقات', active: !isReviewStep),
        Expanded(
          child: Container(
            height: 1,
            margin: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            color: colors.outlineVariant,
          ),
        ),
        _StepMarker(number: '2', label: 'مراجعة وإرسال', active: isReviewStep),
      ],
    );
  }
}

class _StepMarker extends StatelessWidget {
  const _StepMarker({
    required this.number,
    required this.label,
    required this.active,
  });

  final String number;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 13,
          backgroundColor: active ? colors.primary : colors.surfaceContainerHighest,
          child: Text(
            number,
            style: AppTypography.labelSmall.copyWith(
              color: active ? colors.onPrimary : colors.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        AppSpacing.hXs,
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: active ? colors.primary : colors.onSurfaceVariant,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
