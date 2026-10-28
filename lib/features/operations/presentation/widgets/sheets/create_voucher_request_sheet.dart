import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/operations/domain/entities/voucher_request_entity.dart';
import 'package:netsales/features/operations/presentation/controllers/create_voucher_request_controller.dart';
import 'package:netsales/features/operations/presentation/widgets/sheets/components/operations_sale_type_bar.dart';
import 'package:netsales/features/operations/presentation/widgets/sheets/components/package_selection_card.dart';
import 'package:netsales/features/operations/presentation/widgets/sheets/components/request_financial_summary_card.dart';
import 'package:netsales/features/operations/presentation/widgets/sheets/components/sheet_action_dock.dart';
import 'package:netsales/features/partners/domain/entities/network_pos_entity.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_feed.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';

/// ============================================================================
/// نافذة إنشاء وإرسال طلب توريد كروت سياقية (CreateVoucherRequestSheet)
/// ============================================================================
/// ويدجت عرض تركيبي رشيق ومجرد تماماً من أي منطق أعمال أو حالات محلية،
/// مرتبط مباشرة بمتحكم GetX المعتمد (CreateVoucherRequestController).
class CreateVoucherRequestSheet extends StatelessWidget {
  final int? networkId;
  final int? posId;
  final String? networkName;

  const CreateVoucherRequestSheet({
    super.key,
    this.networkId,
    this.posId,
    this.networkName,
  });

  /// إظهار النافذة السفلية المنبثقة
  static Future<VoucherRequestEntity?> show(
    BuildContext context, {
    int? networkId,
    int? posId,
    String? networkName,
  }) {
    final controller = Get.find<CreateVoucherRequestController>();
    controller.init(
      networkId: networkId,
      posId: posId,
      networkNameArg: networkName,
    );

    final titleSubtitle = networkName != null
        ? 'شبكة: $networkName'
        : 'طلب توريد من الشبكة المعتمدة';

    return CustomBottomSheet.show<VoucherRequestEntity>(
      title: 'طلب توريد باقات كروت',
      subtitle: titleSubtitle,
      leadingIcon: Icons.add_shopping_cart_rounded,
      scrollable: true,
      child: CreateVoucherRequestSheet(
        networkId: networkId,
        posId: posId,
        networkName: networkName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final controller = Get.find<CreateVoucherRequestController>();

    return Obx(() {
      final isLoading = controller.isLoading.value;
      final loadError = controller.loadError.value;
      final linkedNetworks = controller.linkedNetworks;
      final saleType = controller.saleType.value;
      final packages = controller.packages;
      final quantities = controller.packageQuantities;
      final totalVouchers = controller.totalVoucherCount;
      final grossAmount = controller.totalGrossAmount;
      final discountAmount = controller.totalDiscountAmount;
      final netAmount = controller.totalNetAmount;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 0. اختيار الشبكة الموردة (في حال تعدد الشبكات المرتبطة)
          if (networkId == null && linkedNetworks.length > 1) ...[
            CustomDropdown<int>(
              label: 'الشبكة الموردة للكروت',
              hint: 'اختر الشبكة',
              prefixIcon: Icons.cell_tower_rounded,
              valueListenable: controller.selectedNetworkId,
              items: linkedNetworks
                  .map(
                    (net) => DropdownItem<int>(
                      value: net.networkId,
                      child: Text(net.networkName ?? 'شبكة #${net.networkId}'),
                    ),
                  )
                  .toList(),
              itemSearchText: (id) =>
                  linkedNetworks
                      .cast<NetworkPosEntity?>()
                      .firstWhere((n) => n?.networkId == id, orElse: () => null)
                      ?.networkName ??
                  '',
              onChanged: controller.onNetworkChanged,
            ),
            AppSpacing.vMd,
          ],

          // 1. مفتاح نوع الشراء (نقداً أو آجل)
          OperationsSaleTypeBar(
            selectedSaleType: saleType,
            onChanged: (newType) => controller.saleType.value = newType,
          ),
          AppSpacing.vMd,

          // 2. قائمة الباقات والكميات
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
                  'لا توجد باقات كروت مفعلة حالياً لهذه الشبكة',
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
                  'باقات الكروت المتاحة',
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
                    onSetQuantity: (qty) => controller.setExactQuantity(
                      packages[index].packageId,
                      qty,
                    ),
                  ),
                ],
              ],
            ),
          ],

          AppSpacing.vMd,

          // 3. حقل الملاحظات الاختياري
          CustomTextField(
            label: 'ملاحظات وتوجيهات التوريد',
            hint: 'أضف أي تفاصيل أو ملاحظات خاصة بالطلب (اختياري)...',
            controller: controller.notesController,
            maxLines: 2,
          ),
          AppSpacing.vLg,

          // 4. السند التلخيصي المباشر
          if (totalVouchers > 0) ...[
            RequestFinancialSummaryCard(
              voucherCount: totalVouchers,
              grossAmount: grossAmount,
              discountAmount: discountAmount,
              netAmount: netAmount,
              saleType: saleType,
            ),
            AppSpacing.vLg,
          ],

          // 5. رصيف الإجراء والاعتماد
          SheetActionDock(
            totalCount: totalVouchers,
            netAmount: netAmount,
            actionLabel: 'إرسال طلب التوريد',
            actionIcon: Icons.send_rounded,
            onAction: totalVouchers > 0
                ? () async {
                    final result = await controller.submitRequest();
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
