import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/enums/sale_type.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_modification_line_entity.dart';
import 'package:netsales/features/requests/presentation/controllers/network_procurement_review_controller.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_package_option_card.dart';

/// قسم الباقات المقترحة للاعتماد في شيت تعديل الطلب
class NetworkRequestProposedItemsSection
    extends GetView<NetworkProcurementReviewController> {
  const NetworkRequestProposedItemsSection({
    super.key,
    required this.request,
    required this.lines,
  });

  final RequestEntity? request;
  final List<RequestModificationLineEntity> lines;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.inventory_2_rounded,
                size: 16.r,
                color: colors.primary,
              ),
            ),
            AppSpacing.hXs,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الباقات المطلوبة والمعدلة (${lines.length})',
                    style: AppTypography.titleSmall.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'عدّل كمية الكروت عبر الأزرار أو الإدخال المباشر، أو احذف الباقة إذا لزم.',
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        AppSpacing.vSm,
        if (lines.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: .4),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.remove_shopping_cart_rounded,
                  size: 32.r,
                  color: colors.onSurfaceVariant,
                ),
                AppSpacing.vSm,
                Text(
                  'قائمة الباقات فارغة',
                  style: AppTypography.titleSmall.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                AppSpacing.vXxs,
                Text(
                  'يمكنك إضافة باقات جديدة من كتالوج الشبكة أدناه.',
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          )
        else
          ...lines.map((line) {
            final pkg = controller.resolvePackageForModification(line.packageId);
            final isAdded = controller.isItemNewlyAdded(line.packageId);
            final authoritativeTotal =
                controller.authoritativeTotalForModificationLine(line);

            return Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.sm),
              child: ProcurementPackageOptionCard(
                package: pkg,
                quantity: line.voucherCount,
                estimatedLineTotal: authoritativeTotal,
                onSetQuantity: (qty) =>
                    controller.setModificationQuantity(line.packageId, qty),
                isCashSale: request?.saleType == SaleType.cash,
                quantityController: controller.modificationQuantityController(
                  line.packageId,
                  line.voucherCount,
                ),
                onDelete: () =>
                    controller.removeModificationPackage(line.packageId),
                customHeaderTag: isAdded ? 'باقة مضافة' : null,
                customHeaderTagColor: isAdded ? colors.tertiary : null,
              ),
            );
          }),
      ],
    );
  }
}
