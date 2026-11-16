import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/enums/sale_type.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/requests/domain/entities/procurement_cart_line_entity.dart';
import 'package:netsales/features/requests/presentation/controllers/pos_procurement_controller.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_quantity_editor_sheet.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/pickers/custom_color_picker.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// عرض سلة بنود التوريد وإجراءات تعديل الكمية أو حذف الباقة.
class ProcurementCartSection extends GetView<PosProcurementController> {
  const ProcurementCartSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      final lines = controller.procurementCart.toList(growable: false);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'بنود طلب التوريد',
                style: AppTypography.titleSmall.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${lines.length} باقة',
                style: AppTypography.bodySmall.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          AppSpacing.vSm,
          if (lines.isEmpty)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.shopping_basket_outlined,
                    color: colors.onSurfaceVariant,
                  ),
                  AppSpacing.hSm,
                  Expanded(
                    child: Text(
                      'السلة فارغة. ارجع إلى كتالوج الباقات واستخدم + داخل بطاقة أي باقة لإضافتها مباشرة.',
                      style: AppTypography.bodySmall.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            ...lines.map((line) {
              return _ProcurementCartLineCard(
                line: line,
                saleType: controller.selectedSaleType.value,
                onEdit: () => ProcurementQuantityEditorSheet.show(
                  package: line.package,
                  currentQuantity: line.voucherCount,
                ),
                onDelete: () => controller.removeCartLine(line.package.packageId),
                onIncrement: () => controller.adjustPackageQuantity(line.package, 1),
                onDecrement: () => controller.adjustPackageQuantity(line.package, -1),
              );
            }),
        ],
      );
    });
  }
}

class _ProcurementCartLineCard extends StatelessWidget {
  final ProcurementCartLineEntity line;
  final SaleType saleType;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _ProcurementCartLineCard({
    required this.line,
    required this.saleType,
    required this.onEdit,
    required this.onDelete,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final packageColor = CustomColorPicker.parseHex(line.package.packageColor);

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Container(
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
                // الشريط اللوني الرقيق على حافة البطاقة
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: packageColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(AppRadius.sm),
                              ),
                              child: Icon(
                                Icons.wifi_tethering_rounded,
                                color: packageColor,
                              ),
                            ),
                            AppSpacing.hSm,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    line.package.packageName,
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: colors.onSurface,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  AppSpacing.vXxs,
                                  Text(
                                    line.fullQuantityLabel,
                                    style: AppTypography.bodySmall.copyWith(
                                      color: colors.onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  AppSpacing.vXxs,
                                  _LocalCartPrice(line: line, saleType: saleType),
                                ],
                              ),
                            ),
                          ],
                        ),
                        AppSpacing.vSm,
                        Divider(
                          height: 1,
                          color: colors.outlineVariant.withValues(alpha: 0.3),
                        ),
                        AppSpacing.vXs,
                        Row(
                          children: [
                            CustomButton.icon(
                              icon: Icons.remove_rounded,
                              tooltip: 'إنقاص كرت واحد',
                              size: AppButtonSize.small,
                              onPressed: onDecrement,
                            ),
                            AppSpacing.hXs,
                            Expanded(
                              child: CustomInteractiveBounce(
                                onTap: onEdit,
                                child: Container(
                                  constraints: const BoxConstraints(minHeight: 40),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: colors.primary.withValues(alpha: 0.07),
                                    borderRadius: BorderRadius.circular(AppRadius.sm),
                                  ),
                                  child: Text(
                                    '${line.voucherCount} كرت • تعديل',
                                    style: AppTypography.labelMedium.copyWith(
                                      color: colors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            AppSpacing.hXs,
                            CustomButton.icon(
                              icon: Icons.add_rounded,
                              tooltip: 'إضافة كرت واحد',
                              size: AppButtonSize.small,
                              foregroundColor: colors.primary,
                              onPressed: onIncrement,
                            ),
                            AppSpacing.hXs,
                            CustomButton.icon(
                              icon: Icons.delete_outline_rounded,
                              tooltip: 'حذف ${line.package.packageName} من الطلب',
                              size: AppButtonSize.small,
                              foregroundColor: colors.error,
                              backgroundColor: colors.error.withValues(alpha: 0.08),
                              onPressed: onDelete,
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
      ),
    );
  }
}



class _LocalCartPrice extends StatelessWidget {
  const _LocalCartPrice({required this.line, required this.saleType});
  final ProcurementCartLineEntity line;
  final SaleType saleType;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final package = line.package;
    final unit = saleType == SaleType.cash
        ? package.procurementCashUnitPriceMinor
        : package.procurementCreditUnitPriceMinor;
    final basisPoints = saleType == SaleType.cash
        ? package.procurementCashDiscountBasisPoints
        : package.procurementCreditDiscountBasisPoints;
    final gross = (package.procurementBaseUnitPriceMinor ??
        (package.packageVoucherPrice * 100).round()) * line.voucherCount;
    final discount = basisPoints == null ? 0 : ((gross * basisPoints) + 5000) ~/ 10000;
    final net = gross - discount;

    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.xxs,
      children: [
        Text(
          unit == null ? 'تعرفة غير متاحة' :
            'سعر الكرت: \${AmountFormatter.formatValue(unit / 100)} ر.ي',
          style: AppTypography.labelSmall.copyWith(color: colors.primary, fontWeight: FontWeight.w700),
        ),
        Text(
          'الخصم: \${AmountFormatter.formatValue(discount / 100)} ر.ي',
          style: AppTypography.labelSmall.copyWith(color: colors.onSurfaceVariant),
        ),
        Text(
          'صافي البند: \${AmountFormatter.formatValue(net / 100)} ر.ي',
          style: AppTypography.labelSmall.copyWith(color: colors.onSurface, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}
