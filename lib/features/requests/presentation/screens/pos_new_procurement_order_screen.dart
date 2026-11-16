import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/enums/sale_type.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/requests/presentation/controllers/pos_procurement_controller.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_cart_section.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_sheet_quantity_section.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_pos_context_section.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_network_context_section.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_package_selection_section.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_checkout_bar.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_financial_quote_card.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';
import 'package:netsales/widgets/indicators/custom_segmented_bar.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';

/// شاشة إنشاء وتعديل طلب توريد كروت لنقطة البيع (Procurement Order Wizard)
/// مصممة وفق أحدث معايير FinTech:
/// 1. سياق مؤسسي ذكي (Context Cards) لنقطة البيع والشبكة دون تكدس القوائم المنسدلة.
/// 2. حاسبة كميات تفاعلية مزدوجة (كروت وأوراق) مدمجة مع الأسعار المعتمدة.
/// 3. دعم سلس لوضعي الإنشاء (Create) والتعديل (Edit Mode) للطلبات المعلقة.
/// 4. شريط إتمام محاسبي مثبت في الأسفل (Sticky Bottom Checkout Bar).
class PosNewProcurementOrderScreen extends GetView<PosProcurementController> {
  const PosNewProcurementOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      final isEditMode = controller.isEditing.value;
      final screenTitle = isEditMode
          ? 'تعديل طلب التوريد #${controller.editingRequestId.value}'
          : 'طلب توريد كروت جديد';

      return CustomAppScaffold(
        appBar: AppBar(
          title: Text(
            screenTitle,
            style: AppTypography.titleMedium.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        bottomNavigationBar: const ProcurementCheckoutBar(),
        body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.cardPadding,
            AppSpacing.cardPadding,
            AppSpacing.cardPadding,
            AppSpacing.xl,
          ),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. بطاقة سياق نقطة البيع المنفذة للطلب
                const ProcurementPosContextSection(),

                AppSpacing.vLg,

                // 2. بطاقة سياق واختيار الشبكة الموردة
                const ProcurementNetworkContextSection(),

                AppSpacing.vLg,

                // 3. اختيار باقة الكروت المطلوبة مع بطاقة التسعير المعتمد
                const ProcurementPackageSelectionSection(),

                AppSpacing.vLg,

                // 4. حاسبة الكمية بالأوراق والكروت
                const ProcurementSheetQuantitySection(),

                AppSpacing.vMd,

                // زر إضافة / تحديث الباقة في السلة
                Obx(() {
                  return SizedBox(
                    width: double.infinity,
                    child: CustomButton.secondary(
                      text: controller.isSelectedPackageInCart
                          ? 'تحديث كمية الباقة في السلة'
                          : 'إضافة الباقة إلى سلة الطلب',
                      icon: controller.isSelectedPackageInCart
                          ? Icons.check_circle_outline_rounded
                          : Icons.add_shopping_cart_rounded,
                      onPressed: controller.selectedPackage.value == null
                          ? null
                          : controller.addOrUpdateCartLine,
                    ),
                  );
                }),

                AppSpacing.vLg,

                // 5. سلة بنود الطلب
                const ProcurementCartSection(),

                AppSpacing.vLg,

                // 6. طريقة الدفع المقترحة (نقدي / آجل)
                Text(
                  'طريقة الدفع المقترحة',
                  style: AppTypography.titleSmall.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AppSpacing.vXs,
                Obx(() {
                  final isCash =
                      controller.selectedSaleType.value == SaleType.cash;
                  return CustomSegmentedBar(
                    selectedIndex: isCash ? 0 : 1,
                    onSegmentChanged: (idx) {
                      controller.selectedSaleType.value =
                          idx == 0 ? SaleType.cash : SaleType.credit;
                      controller.fetchServerQuote();
                    },
                    items: const [
                      CustomSegmentItem(
                        label: 'دفع نقدي (CASH)',
                        icon: Icons.payments_outlined,
                      ),
                      CustomSegmentItem(
                        label: 'دفع آجل (CREDIT)',
                        icon: Icons.credit_card_outlined,
                      ),
                    ],
                  );
                }),

                AppSpacing.vLg,

                // عرض الأسعار النهائي المعتمد من الخادم قبل تقديم الطلب
                const ProcurementFinancialQuoteCard(),

                AppSpacing.vLg,

                // 7. ملاحظات إضافية للطلب
                CustomTextField(
                  controller: controller.notesController,
                  label: 'ملاحظات الطلب (اختياري)',
                  hint: 'أضف أي تفاصيل خاصة لمزود الشبكة...',
                  maxLines: 2,
                  isRequired: false,
                ),

                AppSpacing.vMd,

                // 8. إشعار الأمان المالي والسيادة السعرية
                Container(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: colors.primary.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        size: 20.r,
                        color: colors.primary,
                      ),
                      AppSpacing.hSm,
                      Expanded(
                        child: Text(
                          'يتم احتساب الخصومات التعاقدية والتسوية المالية تلقائياً فور اعتماد الطلب من الشبكة.',
                          style: AppTypography.labelSmall.copyWith(
                            color: colors.onSurfaceVariant,
                            fontSize: 10.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                AppSpacing.vLg,
              ],
            ),
          ),
        ),
      );
    });
  }


}
