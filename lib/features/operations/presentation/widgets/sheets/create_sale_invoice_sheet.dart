import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/operations/domain/entities/sale_invoice_entity.dart';
import 'package:netsales/features/operations/presentation/controllers/create_sale_invoice_controller.dart';
import 'package:netsales/features/operations/presentation/widgets/sheets/components/invoice_financial_summary_card.dart';
import 'package:netsales/features/operations/presentation/widgets/sheets/components/operations_sale_type_bar.dart';
import 'package:netsales/features/operations/presentation/widgets/sheets/components/package_selection_card.dart';
import 'package:netsales/features/operations/presentation/widgets/sheets/components/pos_agent_selector_card.dart';
import 'package:netsales/features/operations/presentation/widgets/sheets/components/sheet_action_dock.dart';
import 'package:netsales/features/partners/domain/entities/network_entity.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_feed.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';

/// ============================================================================
/// نافذة إصدار فاتورة مبيعات مباشرة سياقية (CreateSaleInvoiceSheet)
/// ============================================================================
/// ويدجت عرض تركيبي رشيق ومجرد تماماً من أي منطق أعمال أو حالات محلية،
/// مرتبط مباشرة بمتحكم GetX المعتمد (CreateSaleInvoiceController).
class CreateSaleInvoiceSheet extends StatelessWidget {
  final int? networkId;
  final int? preselectedPosId;
  final String? preselectedPosName;

  const CreateSaleInvoiceSheet({
    super.key,
    this.networkId,
    this.preselectedPosId,
    this.preselectedPosName,
  });

  /// عرض النافذة السفلية المنبثقة
  static Future<SaleInvoiceEntity?> show(
    BuildContext context, {
    int? networkId,
    int? preselectedPosId,
    String? preselectedPosName,
  }) {
    final controller = Get.find<CreateSaleInvoiceController>();
    controller.init(
      networkId: networkId,
      preselectedPosId: preselectedPosId,
      preselectedPosName: preselectedPosName,
    );

    return CustomBottomSheet.show<SaleInvoiceEntity>(
      title: 'إصدار فاتورة مبيعات مباشرة',
      subtitle: 'توزيع وتوريد كروت مع التسوية المالية الفورية',
      leadingIcon: Icons.receipt_long_rounded,
      scrollable: true,
      child: CreateSaleInvoiceSheet(
        networkId: networkId,
        preselectedPosId: preselectedPosId,
        preselectedPosName: preselectedPosName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final controller = Get.find<CreateSaleInvoiceController>();

    return Obx(() {
      final isLoading = controller.isLoading.value;
      final loadError = controller.loadError.value;
      final networks = controller.networks;
      final selectedPosId = controller.selectedPosId.value;
      final selectedPosName = controller.selectedPosName.value;
      final linkedPosList = controller.linkedPosList;
      final saleType = controller.saleType.value;
      final packages = controller.packages;
      final quantities = controller.packageQuantities;
      final totalVouchers = controller.totalVoucherCount;
      final grossAmount = controller.totalGrossAmount;
      final discountAmount = controller.totalDiscountAmount;
      final netAmount = controller.totalNetAmount;
      final paidAmount = controller.paidAmount;
      final remainingDebt = controller.remainingDebtAmount;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 0. اختيار الشبكة (في حال تعدد شبكات المزود وعدم التحديد المسبق)
          if (networkId == null && networks.length > 1) ...[
            CustomDropdown<int>(
              label: 'الشبكة الموردة للكروت',
              hint: 'اختر الشبكة',
              prefixIcon: Icons.cell_tower_rounded,
              valueListenable: controller.selectedNetworkId,
              items: networks
                  .map(
                    (net) => DropdownItem<int>(
                      value: net.networkId,
                      child: Text(net.networkName),
                    ),
                  )
                  .toList(),
              itemSearchText: (id) =>
                  networks
                      .cast<NetworkEntity?>()
                      .firstWhere((n) => n?.networkId == id, orElse: () => null)
                      ?.networkName ??
                  '',
              onChanged: controller.onNetworkChanged,
            ),
            AppSpacing.vMd,
          ],

          // 1. اختيار أو عرض نقطة البيع
          PosAgentSelectorCard(
            posIdNotifier: controller.selectedPosId,
            selectedPosName: selectedPosName,
            linkedPosList: linkedPosList,
            isPreselected: preselectedPosId != null,
            onPosSelected: (pos) => controller.onPosChanged(pos.posId),
          ),
          AppSpacing.vMd,

          // 2. مفتاح نمط البيع (كاش أو آجل)
          OperationsSaleTypeBar(
            selectedSaleType: saleType,
            onChanged: controller.setSaleType,
          ),
          AppSpacing.vMd,

          // 3. باقات الكروت المتاحة
          if (isLoading) ...[
            const CustomSkeletonFeed(
              itemCount: 2,
              cardHeight: 70,
              padding: EdgeInsets.zero,
              shrinkWrap: true,
            ),
          ] else if (loadError.isNotEmpty) ...[
            Container(
              padding: EdgeInsets.all(AppSpacing.cardPadding),
              decoration: BoxDecoration(
                color: colors.error.withValues(alpha: 0.08),
                borderRadius: AppRadius.mdRadius,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    color: colors.error,
                    size: 20.r,
                  ),
                  AppSpacing.hSm,
                  Expanded(
                    child: Text(
                      loadError,
                      style: AppTypography.bodySmall.copyWith(
                        color: colors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (packages.isEmpty) ...[
            Container(
              padding: EdgeInsets.all(AppSpacing.cardPadding),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: AppRadius.mdRadius,
              ),
              child: Center(
                child: Text(
                  'لا توجد باقات كروت نشطة مسجلة لهذه الشبكة',
                  style: AppTypography.bodyMedium.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'باقات الكروت المراد إصدارها',
                  style: AppTypography.labelLarge.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (totalVouchers > 0)
                  Text(
                    '$totalVouchers كرت محدد',
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
            AppSpacing.vXs,
            Column(
              children: [
                for (int index = 0; index < packages.length; index++) ...[
                  if (index > 0) AppSpacing.vSm,
                  PackageSelectionCard(
                    package: packages[index],
                    quantity: quantities[packages[index].packageId] ?? 0,
                    discountPercent: saleType == 'CASH'
                        ? packages[index].packageDefaultCashDiscount
                        : packages[index].packageDefaultCreditDiscount,
                    onIncrement: () =>
                        controller.incrementQuantity(packages[index].packageId),
                    onDecrement: () =>
                        controller.decrementQuantity(packages[index].packageId),
                    onAddPreset: (preset) => controller.addPresetQuantity(
                      packages[index].packageId,
                      preset,
                    ),
                    onSetQuantity: (newQty) => controller.setExactQuantity(
                      packages[index].packageId,
                      newQty,
                    ),
                  ),
                ],
              ],
            ),
          ],

          AppSpacing.vMd,

          // 4. حقل المبلغ المدفوع نقداً في حالة البيع الآجل
          if (saleType == 'CREDIT' && netAmount > 0) ...[
            CustomTextField(
              label: 'المبلغ المسدد نقداً الآن (إن وجد)',
              hint: '0.00',
              controller: controller.paidAmountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: const [AmountTextInputFormatter()],
              prefixIcon: Icon(
                Icons.paid_outlined,
                color: colors.primary,
                size: 20.r,
              ),
              onChanged: (_) => controller.syncPaidAmount(),
            ),
            AppSpacing.vMd,
          ],

          // 5. السند المالي الرقمي اللحظي
          if (totalVouchers > 0) ...[
            InvoiceFinancialSummaryCard(
              voucherCount: totalVouchers,
              grossAmount: grossAmount,
              discountAmount: discountAmount,
              netAmount: netAmount,
              paidAmount: paidAmount,
              remainingDebt: remainingDebt,
              saleType: saleType,
            ),
            AppSpacing.vLg,
          ],

          // 6. رصيف الإجراء والاعتماد
          SheetActionDock(
            totalCount: totalVouchers,
            netAmount: netAmount,
            actionLabel: 'إصدار الفاتورة والتسوية',
            actionIcon: Icons.check_circle_rounded,
            onAction: totalVouchers > 0 && selectedPosId != null
                ? () async {
                    final result = await controller.submitInvoice();
                    if (result != null) {
                      Get.back(result: result);
                    }
                  }
                : null,
            onCancel: () => Get.back(),
          ),
        ],
      );
    });
  }
}
