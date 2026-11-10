import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/core/utils/voucher_sheet_calculator.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/features/requests/presentation/controllers/network_procurement_review_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/pickers/custom_color_picker.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';

class NetworkRequestModificationSheet
    extends GetView<NetworkProcurementReviewController> {
  const NetworkRequestModificationSheet({super.key});

  static Future<void> open(RequestEntity request) async {
    final controller = Get.find<NetworkProcurementReviewController>();
    if (!request.isPending) return;
    await controller.beginModification(request);
    if (controller.editingRequestId.value != request.requestId) return;
    await CustomBottomSheet.show<void>(
      title: 'مراجعة طلب #${request.requestUuid}',
      subtitle: 'عدّل الكميات أو أضف واحذف الباقات، ثم اطلب معاينة الأسعار قبل الاعتماد.',
      leadingIcon: Icons.edit_note_rounded,
      scrollable: true,
      maxHeightFactor: 0.94,
      stickyFooter: const _ModificationFooter(),
      child: const NetworkRequestModificationSheet(),
    );
    controller.clearModificationEditor();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Obx(() {
      final lines = controller.modificationLines.toList(growable: false);
      final selectedIds = lines.map((line) => line.packageId).toSet();
      final preview = controller.currentPreview.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('بنود الطلب المقترحة'),
          AppSpacing.vSm,
          if (lines.isEmpty)
            const _InfoPanel('يجب أن يحتوي الطلب على باقة واحدة على الأقل.'),
          ...lines.map((line) {
            final package = controller.availablePackages.firstWhereOrNull(
              (item) => item.packageId == line.packageId,
            );
            final name = package?.packageName ?? 'باقة #${line.packageId}';
            final sheetSize = package?.packageVoucherCount ?? 0;
            final packageColor = CustomColorPicker.parseHex(package?.packageColor);
            final breakdown = sheetSize > 0
                ? VoucherSheetCalculator.describe(line.voucherCount, sheetSize)
                : '';

            return Container(
              margin: EdgeInsets.only(bottom: AppSpacing.sm),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: 0.35),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // الشريط اللوني المميز للباقة
                      Container(
                        width: 5,
                        color: packageColor,
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: packageColor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(AppRadius.sm),
                                    ),
                                    child: Icon(
                                      Icons.wifi_tethering_rounded,
                                      color: packageColor,
                                      size: 18,
                                    ),
                                  ),
                                  AppSpacing.hSm,
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: AppTypography.bodyMedium.copyWith(
                                            color: colors.onSurface,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        if (breakdown.isNotEmpty) ...[
                                          AppSpacing.vXxs,
                                          Text(
                                            breakdown,
                                            style: AppTypography.bodySmall.copyWith(
                                              color: colors.primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  CustomButton.icon(
                                    icon: Icons.delete_outline_rounded,
                                    size: AppButtonSize.small,
                                    foregroundColor: colors.error,
                                    onPressed: () =>
                                        controller.removeModificationPackage(line.packageId),
                                  ),
                                ],
                              ),
                              AppSpacing.vSm,
                              Row(
                                children: [
                                  // زر إنقاص ورقة كاملة
                                  CustomButton.outline(
                                    text: '- ورقة',
                                    size: AppButtonSize.small,
                                    icon: Icons.remove_rounded,
                                    onPressed: line.voucherCount <= 1
                                        ? null
                                        : () => controller.stepModificationSheet(
                                              line.packageId,
                                              isIncrement: false,
                                            ),
                                  ),
                                  AppSpacing.hSm,
                                  Expanded(
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: AppSpacing.sm,
                                        vertical: AppSpacing.xs,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colors.surfaceContainerLowest,
                                        borderRadius: BorderRadius.circular(AppRadius.sm),
                                        border: Border.all(
                                          color: colors.outlineVariant.withValues(alpha: 0.3),
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${line.voucherCount} كرت',
                                          style: AppTypography.titleSmall.copyWith(
                                            color: colors.onSurface,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  AppSpacing.hSm,
                                  // زر زيادة ورقة كاملة
                                  CustomButton.outline(
                                    text: '+ ورقة',
                                    size: AppButtonSize.small,
                                    icon: Icons.add_rounded,
                                    onPressed: line.voucherCount >= 1000000
                                        ? null
                                        : () => controller.stepModificationSheet(
                                              line.packageId,
                                              isIncrement: true,
                                            ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          AppSpacing.vMd,
          const _SectionTitle('إضافة باقة من كتالوج الشبكة'),
          AppSpacing.vSm,
          if (controller.isLoadingPackages.value)
            const Center(child: CircularProgressIndicator.adaptive())
          else
            ...controller.availablePackages
                .where((p) => !selectedIds.contains(p.packageId))
                .map(
                  (package) => Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.xs),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: colors.outlineVariant.withValues(alpha: 0.3),
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              package.packageName,
                              style: AppTypography.bodySmall.copyWith(
                                color: colors.onSurface,
                              ),
                            ),
                          ),
                          CustomButton.icon(
                            icon: Icons.add_rounded,
                            size: AppButtonSize.small,
                            onPressed: () => controller.addModificationPackage(
                              package.packageId,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
          AppSpacing.vMd,
          const _SectionTitle('معاينة الأسعار'),
          AppSpacing.vXs,
          const _InfoPanel(
            'المعاينة لا تغيّر الطلب ولا تنشئ فاتورة. يتم احتساب الأسعار والخصومات والإجماليات وفق قواعد التسعير المعتمدة.',
          ),
          if (preview != null) ...[
            AppSpacing.vMd,
            _TotalRow(
              label: 'الإجمالي الأصلي',
              amount: preview.originalTotalAmount,
            ),
            _TotalRow(
              label: 'الإجمالي قبل الخصم',
              amount: preview.grossTotalAmount,
            ),
            _TotalRow(
              label: 'إجمالي الخصم',
              amount: preview.totalDiscountAmount,
            ),
            Divider(color: colors.outlineVariant.withValues(alpha: 0.4)),
            _TotalRow(
              label: 'الإجمالي المقترح',
              amount: preview.previewTotalAmount,
              emphasize: true,
            ),
            AppSpacing.vSm,
            ...preview.items.map(
              (item) {
                final package = controller.availablePackages.firstWhereOrNull(
                  (p) => p.packageId == item.packageId,
                );
                final sheetSize = package?.packageVoucherCount ?? 0;
                final desc = sheetSize > 0
                    ? VoucherSheetCalculator.describe(item.voucherCount, sheetSize)
                    : null;
                final qtyLabel = desc != null
                    ? '$desc (${item.voucherCount} كرت)'
                    : '${item.voucherCount} كرت';

                return Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Text(
                    '${item.packageName} — $qtyLabel — خصم ${item.itemDiscount}% — ${AmountFormatter.format(item.itemTotalAmount.toString())}',
                    style: AppTypography.bodySmall.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                );
              },
            ),
            if (preview.removedItems.isNotEmpty) ...[
              AppSpacing.vSm,
              Text(
                'الباقات المحذوفة',
                style: AppTypography.labelLarge.copyWith(color: colors.error),
              ),
              ...preview.removedItems.map(
                (item) {
                  final package = controller.availablePackages.firstWhereOrNull(
                    (p) => p.packageId == item.packageId,
                  );
                  final sheetSize = package?.packageVoucherCount ?? 0;
                  final desc = sheetSize > 0
                      ? VoucherSheetCalculator.describe(item.originalVoucherCount, sheetSize)
                      : null;
                  final qtyLabel = desc != null
                      ? '$desc (${item.originalVoucherCount} كرت)'
                      : '${item.originalVoucherCount} كرت';

                  return Text(
                    '${item.packageName} — $qtyLabel',
                    style: AppTypography.bodySmall.copyWith(color: colors.error),
                  );
                },
              ),
            ],
            if (!preview.hasModifications)
              const _InfoPanel('لم يتم اكتشاف أي تغيير عن الطلب الأصلي.'),
          ],
        ],
      );
    });
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTypography.titleSmall.copyWith(
        color: context.colors.onSurface,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  final String text;

  const _InfoPanel(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Text(
        text,
        style: AppTypography.bodySmall.copyWith(
          color: context.colors.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool emphasize;

  const _TotalRow({
    required this.label,
    required this.amount,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          Text(
            AmountFormatter.format(amount.toString()),
            style:
                (emphasize ? AppTypography.titleMedium : AppTypography.bodyMedium)
                    .copyWith(
                      color: emphasize ? colors.primary : colors.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
          ),
        ],
      ),
    );
  }
}

class _ModificationFooter extends GetView<NetworkProcurementReviewController> {
  const _ModificationFooter();

  @override
  Widget build(BuildContext context) => Obx(() {
    final preview = controller.currentPreview.value;
    final canApprove =
        preview != null &&
        preview.hasModifications &&
        !controller.isPreviewingModification.value &&
        !controller.isProcessingDecision.value;
    return Row(
      children: [
        Expanded(
          child: CustomButton.outline(
            text: 'معاينة التعديل',
            icon: Icons.calculate_outlined,
            loading: controller.isPreviewingModification.value,
            onPressed:
                controller.modificationLines.isEmpty ||
                    controller.isPreviewingModification.value
                ? null
                : controller.previewModification,
          ),
        ),
        AppSpacing.hSm,
        Expanded(
          child: CustomButton.primary(
            text: 'اعتماد التعديل',
            icon: Icons.verified_outlined,
            enabled: canApprove,
            onPressed: !canApprove
                ? null
                : controller.confirmAndApproveModification,
          ),
        ),
      ],
    );
  });
}
