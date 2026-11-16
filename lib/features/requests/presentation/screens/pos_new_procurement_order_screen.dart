import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/enums/sale_type.dart';
import 'package:netsales/core/presentation/enums/semantic_tone.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/requests/presentation/controllers/pos_procurement_controller.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_cart_section.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_pricing_discount_card.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_sheet_quantity_section.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';
import 'package:netsales/widgets/indicators/custom_segmented_bar.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';
import 'package:netsales/widgets/pickers/custom_color_picker.dart';

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
        bottomNavigationBar: _buildStickyCheckoutBar(context),
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
                _buildPosContextSection(context),

                AppSpacing.vLg,

                // 2. بطاقة سياق واختيار الشبكة الموردة
                _buildNetworkContextSection(context),

                AppSpacing.vLg,

                // 3. اختيار باقة الكروت المطلوبة مع بطاقة التسعير المعتمد
                _buildPackageSelectionSection(context),

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

  /// بطاقة سياق نقطة البيع
  Widget _buildPosContextSection(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'نقطة البيع المنفذة للطلب',
          style: AppTypography.titleSmall.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        AppSpacing.vXs,
        Obx(() {
          final posList = controller.myPosList;
          if (posList.isEmpty) {
            return Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: colors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: colors.error.withValues(alpha: 0.28)),
              ),
              child: Text(
                'لا توجد نقاط بيع معتمدة ومصرح بها لحسابك حالياً.',
                style: AppTypography.bodySmall.copyWith(color: colors.error),
              ),
            );
          }

          if (posList.length == 1 || controller.isEditing.value) {
            final pos = controller.activePos ?? posList.first;
            return Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.storefront_rounded,
                      color: colors.primary,
                      size: 20.r,
                    ),
                  ),
                  AppSpacing.hSm,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pos.posName,
                          style: AppTypography.titleSmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.onSurface,
                          ),
                        ),
                        if (pos.posAddress != null &&
                            pos.posAddress!.isNotEmpty)
                          Text(
                            pos.posAddress!,
                            style: AppTypography.labelSmall.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const CustomStatusBadge(
                    label: 'نقطة معتمدة',
                    tone: SemanticTone.success,
                    icon: Icons.verified_rounded,
                    isCompact: true,
                  ),
                ],
              ),
            );
          }

          return CustomDropdown<int>(
            label: 'اختر نقطة البيع للطلب',
            hint: 'حدد نقطة البيع التي تريد التوريد إليها',
            searchEnabled: posList.length > 5,
            rxValue: controller.selectedPosId,
            items: posList
                .map((pos) {
                  return DropdownItem<int>(
                    value: pos.posId,
                    child: Text('${pos.posName} (#${pos.posId})'),
                  );
                })
                .toList(growable: false),
            onChanged: (id) {
              if (id != null) controller.onPosSelected(id);
            },
          );
        }),
      ],
    );
  }

  /// بطاقة سياق الشبكة الموردة
  Widget _buildNetworkContextSection(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الشبكة الموردة للكروت',
          style: AppTypography.titleSmall.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        AppSpacing.vXs,
        Obx(() {
          if (controller.isLoadingNetworks.value) {
            return const LinearProgressIndicator();
          }

          final networks = controller.linkedNetworks;
          if (networks.isEmpty) {
            return Container(
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: colors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Text(
                'لا توجد شبكات موردة نشطة مرتبطة بنقطة البيع حالياً.',
                style: AppTypography.bodySmall.copyWith(color: colors.error),
              ),
            );
          }

          if (networks.length == 1 || controller.isEditing.value) {
            final net = networks.firstWhereOrNull(
                  (n) => n.networkId == controller.selectedNetworkId.value,
                ) ??
                networks.first;
            final netName = net.network?.networkName ?? 'شبكة #${net.networkId}';

            return Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.cell_tower_rounded,
                      color: colors.primary,
                      size: 20.r,
                    ),
                  ),
                  AppSpacing.hSm,
                  Expanded(
                    child: Text(
                      netName,
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                  const CustomStatusBadge(
                    label: 'شبكة موردة',
                    tone: SemanticTone.info,
                    icon: Icons.hub_rounded,
                    isCompact: true,
                  ),
                ],
              ),
            );
          }

          return CustomDropdown<int>(
            label: 'اختر الشبكة الموردة',
            searchEnabled: false,
            rxValue: controller.selectedNetworkId,
            items: networks.map((link) {
              return DropdownItem<int>(
                value: link.networkId,
                child: Text(
                  link.network?.networkName ?? 'شبكة #${link.networkId}',
                ),
              );
            }).toList(),
            onChanged: (id) {
              if (id != null) controller.onNetworkSelected(id);
            },
          );
        }),
      ],
    );
  }

  /// قسم اختيار باقة الكروت والتسعير المعتمد
  Widget _buildPackageSelectionSection(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'باقة الكروت المطلوبة',
          style: AppTypography.titleSmall.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        AppSpacing.vXs,
        Obx(() {
          if (controller.isLoadingPackages.value) {
            return const LinearProgressIndicator();
          }

          final packages = controller.availablePackages;
          if (packages.isEmpty) {
            return Container(
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                'يرجى اختيار شبكة لعرض باقات الكروت المتوفرة لديها.',
                style: AppTypography.bodySmall.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomDropdown<int>(
                label: 'اختر باقة الكروت',
                searchEnabled: true,
                rxValue: controller.selectedPackageId,
                items: packages.map((pkg) {
                  final pkgColor = CustomColorPicker.parseHex(pkg.packageColor);
                  return DropdownItem<int>(
                    value: pkg.packageId,
                    child: Row(
                      children: [
                        Container(
                          width: 10.r,
                          height: 10.r,
                          decoration: BoxDecoration(
                            color: pkgColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        AppSpacing.hSm,
                        Expanded(
                          child: Text(
                            '${pkg.packageName} (أساسي: ${AmountFormatter.format(pkg.packageVoucherPrice.toString())})',
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (id) {
                  if (id != null) {
                    final found = packages.firstWhereOrNull(
                      (p) => p.packageId == id,
                    );
                    if (found != null) controller.onPackageSelected(found);
                  }
                },
              ),
              if (controller.selectedPackage.value != null) ...[
                AppSpacing.vSm,
                ProcurementPricingDiscountCard(
                  package: controller.selectedPackage.value!,
                  discount: controller.effectiveDiscount.value,
                  isLoading: controller.isLoadingDiscount.value,
                  errorMessage: controller.discountError.value,
                  saleType: controller.selectedSaleType.value,
                ),
              ],
            ],
          );
        }),
      ],
    );
  }

  /// شريط الدفع والإتمام المثبت في أسفل الشاشة (Sticky Bottom Checkout Bar)
  Widget _buildStickyCheckoutBar(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      final isEditMode = controller.isEditing.value;
      final cartLines = controller.procurementCart;
      final totalVouchers = cartLines.fold<int>(
        0,
        (sum, item) => sum + item.voucherCount,
      );
      final totalSheets = cartLines.fold<double>(
        0.0,
        (sum, item) => sum + item.sheets,
      );
      final totalAmount = controller.serverQuote.value?.netTotal ?? 0.0;

      return Container(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.cardPadding,
          AppSpacing.sm,
          AppSpacing.cardPadding,
          AppSpacing.cardPadding + MediaQuery.paddingOf(context).bottom,
        ),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.lg),
          ),
          border: Border(
            top: BorderSide(
              color: colors.outlineVariant.withValues(alpha: 0.35),
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            // ملخص الكمية والإجمالي المالي
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    totalVouchers > 0
                        ? '$totalVouchers كرت • ${totalSheets.toStringAsFixed(totalSheets.truncateToDouble() == totalSheets ? 0 : 1)} ورقة'
                        : 'السلة فارغة',
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    AmountFormatter.format(totalAmount.toString()),
                    style: AppTypography.titleMedium.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            AppSpacing.hMd,

            // زر تقديم أو حفظ تعديلات الطلب
            CustomButton(
              text: isEditMode ? 'حفظ تعديلات الطلب' : 'تقديم طلب التوريد',
              icon: isEditMode ? Icons.check_circle_rounded : Icons.send_rounded,
              loading: controller.isSubmitting.value,
              enabled: cartLines.isNotEmpty && !controller.isSubmitting.value,
              onPressed: cartLines.isEmpty
                  ? null
                  : controller.submitOrderAndClose,
            ),
          ],
        ),
      );
    });
  }
}
