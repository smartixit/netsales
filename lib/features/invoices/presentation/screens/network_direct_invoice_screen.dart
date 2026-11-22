import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/invoices/presentation/controllers/network_direct_invoice_controller.dart';
import 'package:netsales/features/invoices/presentation/widgets/direct_invoice_package_selection_section.dart';
import 'package:netsales/features/invoices/presentation/widgets/direct_invoice_pos_context_section.dart';
import 'package:netsales/features/invoices/presentation/widgets/direct_invoice_sale_type_selector.dart';
import 'package:netsales/widgets/cards/custom_page_hero_card.dart';
import 'package:netsales/widgets/forms/custom_checkout_bar.dart';
import 'package:netsales/widgets/forms/custom_section_heading.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';

/// مساحة إنشاء وإصدار فاتورة بيع مباشرة لنقطة بيع (NetworkDirectInvoiceScreen)
///
/// تجسد المعمارية المؤسسية النظيفة لشاشات النماذج والطلبات:
/// - استهلاك مباشر وموحد للمكونات العامة [CustomPageHeroCard], [CustomCheckoutBar], [CustomSectionHeading].
/// - تفويض كامل لحالة الحقول والإرسال والتحقق للمتحكم [NetworkDirectInvoiceController].
/// - مطابقة تامة 100% لتنظيم وترتيب وتجربة شاشة إنشاء الطلب [PosNewProcurementOrderScreen].
class NetworkDirectInvoiceScreen
    extends GetView<NetworkDirectInvoiceController> {
  const NetworkDirectInvoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      final gross = controller.checkoutGrossAmount;
      final discount = controller.checkoutDiscountAmount;
      final net = controller.checkoutNetAmount;
      final count = controller.checkoutTotalVouchers;

      return CustomAppScaffold(
        appBar: AppBar(
          title: Text(
            'إصدار فاتورة مبيعات مباشرة',
            style: AppTypography.titleMedium.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        bottomNavigationBar: CustomCheckoutBar(
          metrics: [
            CheckoutMetricData(
              label: 'الإجمالي',
              value: AmountFormatter.formatValue(gross),
            ),
            CheckoutMetricData(
              label: 'الخصم',
              value: AmountFormatter.formatValue(discount),
              isDiscount: true,
            ),
            CheckoutMetricData(
              label: 'الصافي التقديري',
              value: AmountFormatter.formatValue(net),
              isNet: true,
            ),
          ],
          itemCount: controller.cartPackagesCount,
          itemCountLabel: 'باقة مختارة',
          unitCount: count,
          unitCountLabel: 'كرت',
          actionLabel: 'إصدار الفاتورة',
          actionIcon: Icons.check_circle_rounded,
          isLoading: controller.isSubmitting.value,
          isActionEnabled: controller.canSubmitInvoice,
          onAction: controller.canSubmitInvoice
              ? controller.submitDirectInvoice
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
                    AppSpacing.md,
                    horizontalPadding,
                    AppSpacing.xl,
                  ),
                  child: Form(
                    key: controller.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. ترويسة الصفحة القيادية (CustomPageHeroCard)
                        const CustomPageHeroCard(
                          title: 'مساحة إصدار الفاتورة المباشرة',
                          subtitle: 'حدد نقطة البيع ثم اختر الباقات والكميات لإصدار فاتورة نقدية فورياً.',
                          icon: Icons.point_of_sale_rounded,
                        ),
                        AppSpacing.vMd,

                        // 2. سياق واختيار نقطة البيع
                        const DirectInvoicePosContextSection(),
                        AppSpacing.vLg,

                        // 3. نوع البيع (نقدي / آجل)
                        const CustomSectionHeading(
                          title: 'التسوية النقدية',
                          subtitle:
                              'يتم إصدار الفواتير المباشرة وفق التسوية النقدية فقط',
                          icon: Icons.payments_rounded,
                        ),
                        AppSpacing.vXs,
                        const DirectInvoiceSaleTypeSelector(),
                        AppSpacing.vLg,

                        // 4. اختيار الباقات والكميات
                        const CustomSectionHeading(
                          title: 'باقات الكروت والكميات',
                          subtitle: 'حدد الباقات وكمية الكروت لكل صنف مع تطبيق تعرفة السعر',
                          icon: Icons.inventory_2_rounded,
                        ),
                        AppSpacing.vXs,
                        const DirectInvoicePackageSelectionSection(),
                        AppSpacing.vXxl,
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
