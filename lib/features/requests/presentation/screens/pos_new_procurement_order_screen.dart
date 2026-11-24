import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/requests/presentation/controllers/pos_new_procurement_order_controller.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_edit_mode_banner.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_network_context_section.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_package_selection_section.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_pos_context_section.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_sale_type_selector.dart';
import 'package:netsales/widgets/cards/custom_page_hero_card.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';
import 'package:netsales/widgets/forms/custom_checkout_bar.dart';
import 'package:netsales/widgets/forms/custom_section_heading.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';

/// مساحة إنشاء وتعديل طلب التوريد (PosNewProcurementOrderScreen)
///
/// تجسد المعمارية المؤسسية النظيفة لشاشات النماذج والطلبات:
/// - استهلاك مباشر للمكونات العامة الموحدة [CustomCheckoutBar] و [CustomSectionHeading].
/// - تفويض كامل لحالة الحقول والإرسال والتحقق للمتحكم [PosNewProcurementOrderController].
class PosNewProcurementOrderScreen
    extends GetView<PosNewProcurementOrderController> {
  const PosNewProcurementOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      final isEditMode = controller.isEditing.value;
      final title = controller.screenTitle;
      final gross = controller.checkoutGrossAmount;
      final discount = controller.checkoutDiscountAmount;
      final net = controller.checkoutNetAmount;
      final count = controller.checkoutTotalVouchers;
      final currency = controller.checkoutCurrency;

      return CustomAppScaffold(
      appBarTitle: 
            title,
        bottomNavigationBar: CustomCheckoutBar(
          warningWidget: controller.needsPricingRefresh
              ? CustomStateView.pricingExpired(
                  title: controller.isRefreshingCartPricing.value
                      ? 'جارٍ تحديث التعرفة'
                      : 'انتهت صلاحية التعرفة',
                  subtitle: controller.isRefreshingCartPricing.value
                      ? 'نحدّث أسعار الباقات المختارة مع الحفاظ على كميات السلة.'
                      : controller.cartPricingRefreshError.value ?? 'سيتم تحديث التعرفة تلقائياً عند الإرسال، أو يمكنك التحديث الآن.',
                  actionLabel: controller.isRefreshingCartPricing.value
                      ? 'جارٍ التحديث...'
                      : 'تحديث الآن',
                  presentation: CustomStatePresentation.compact,
                  onAction: controller.isRefreshingCartPricing.value
                      ? null
                      : controller.refreshNetworkPackages,
                )
              : null,
          metrics: [
            CheckoutMetricData(
              label: 'الإجمالي',
              value: AmountFormatter.formatValue(gross),
              currency: currency,
            ),
            CheckoutMetricData(
              label: 'الخصم',
              value: AmountFormatter.formatValue(discount),
              currency: currency,
              isDiscount: true,
            ),
            CheckoutMetricData(
              label: 'الصافي التقديري',
              value: AmountFormatter.formatValue(net),
              currency: currency,
              isNet: true,
            ),
          ],
          itemCount: controller.cartPackagesCount,
          itemCountLabel: 'باقة مختارة',
          unitCount: count,
          unitCountLabel: 'كرت',
          actionLabel: isEditMode ? 'حفظ التعديلات' : 'إرسال طلب التوريد',
          actionIcon: Icons.send_rounded,
          isLoading: controller.isSubmitting.value,
          isActionEnabled: controller.canSubmitOrder,
          onAction: controller.canSubmitOrder
              ? controller.submitOrderAndClose
              : null,
        ),
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
                    AppSpacing.appBarHeight + AppSpacing.md,
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
                        const CustomSectionHeading(
                          title: 'طريقة التسعير',
                          subtitle:
                              'تتغير تعرفة العرض حسب طريقة الدفع المختارة.',
                          icon: Icons.payments_rounded,
                        ),
                        AppSpacing.vSm,
                        const ProcurementSaleTypeSelector(),
                        AppSpacing.vLg,
                        // 4. اختيار الباقات والكميات
                        const CustomSectionHeading(
                          title: 'باقات الكروت والكميات',
                          subtitle: 'حدد الباقات وكمية الكروت لكل صنف مع تطبيق تعرفة السعر',
                          icon: Icons.inventory_2_rounded,
                        ),
                        AppSpacing.vSm,
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
