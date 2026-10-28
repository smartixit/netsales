import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/operations/domain/entities/voucher_request_entity.dart';
import 'package:netsales/features/operations/presentation/controllers/edit_voucher_request_controller.dart';
import 'package:netsales/features/operations/presentation/widgets/sheets/components/operations_sale_type_bar.dart';
import 'package:netsales/features/operations/presentation/widgets/sheets/components/package_selection_card.dart';
import 'package:netsales/features/operations/presentation/widgets/sheets/components/request_financial_summary_card.dart';
import 'package:netsales/features/operations/presentation/widgets/sheets/components/sheet_action_dock.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_feed.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';

/// ============================================================================
/// نافذة تعديل طلب توريد كروت سياقية (EditVoucherRequestSheet)
/// ============================================================================
/// ويدجت تركيبي رشيق ومجرد تماماً من أي منطق أعمال أو حالات محلية،
/// مرتبط مباشرة بمتحكم GetX المعتمد (EditVoucherRequestController).
class EditVoucherRequestSheet extends StatelessWidget {
  final VoucherRequestEntity request;

  const EditVoucherRequestSheet({
    super.key,
    required this.request,
  });

  /// إظهار النافذة السفلية المنبثقة للتعديل
  static Future<VoucherRequestEntity?> show(
    BuildContext context, {
    required VoucherRequestEntity request,
  }) {
    final controller = Get.find<EditVoucherRequestController>();
    controller.init(request);

    final subtitle = request.networkName != null
        ? 'شبكة: ${request.networkName} • طلب #${request.requestUuid}'
        : 'طلب توريد رقم #${request.requestUuid}';

    return CustomBottomSheet.show<VoucherRequestEntity>(
      title: 'تعديل طلب توريد الكروت',
      subtitle: subtitle,
      leadingIcon: Icons.edit_note_rounded,
      scrollable: true,
      child: EditVoucherRequestSheet(request: request),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final controller = Get.find<EditVoucherRequestController>();

    return Obx(() {
      final isLoading = controller.isLoading.value;
      final loadError = controller.loadError.value;
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
          // 1. مفتاح نوع الشراء (نقداً أو آجل)
          OperationsSaleTypeBar(
            selectedSaleType: saleType,
            onChanged: (newType) => controller.setSaleType(newType),
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
                  'باقات الكروت المطلوبة',
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
            actionLabel: 'حفظ التعديلات',
            actionIcon: Icons.save_rounded,
            onAction: totalVouchers > 0
                ? () async {
                    await controller.submit();
                  }
                : null,
            onCancel: () => Get.back(),
          ),
        ],
      );
    });
  }
}
