import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/core/utils/voucher_sheet_calculator.dart';
import 'package:netsales/features/operations/presentation/widgets/sheets/components/package_quantity_input_sheet.dart';
import 'package:netsales/features/packages/domain/entities/voucher_package_entity.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// ============================================================================
/// بطاقة اختيار باقة الكروت التفاعلية الذكية (PackageSelectionCard)
/// ============================================================================
/// تتيح تحديد كميات باقات الكروت بدقة وسرعة مع التوافق التام مع نظام الأوراق
/// (نصف ورقة، ورقة، ورقة ونصف، ورقتين) ومحاذاة فورية مع قاعدة القص الفردية (51 -> 26).
class PackageSelectionCard extends StatelessWidget {
  final VoucherPackageEntity package;
  final int quantity;
  final double discountPercent;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final ValueChanged<int> onAddPreset;
  final ValueChanged<int>? onSetQuantity;

  const PackageSelectionCard({
    super.key,
    required this.package,
    required this.quantity,
    required this.discountPercent,
    required this.onIncrement,
    required this.onDecrement,
    required this.onAddPreset,
    this.onSetQuantity,
  });

  void _openQuantityModal(BuildContext context) {
    PackageQuantityInputSheet.show(
      context: context,
      package: package,
      initialQuantity: quantity,
      discountPercent: discountPercent,
      onConfirm: (newQty) {
        if (onSetQuantity != null) {
          onSetQuantity!(newQty);
        } else {
          final diff = newQty - quantity;
          if (diff > 0) {
            onAddPreset(diff);
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isSelected = quantity > 0;
    final unitPrice = package.packageVoucherPrice;
    // DISPLAY-ONLY (UI-only, non-authoritative): select the backend-provided
    // effective price that corresponds to the discount percent in effect,
    // instead of recomputing money on the client.
    final effectiveUnitPrice = discountPercent == package.packageDefaultCashDiscount
        ? package.effectiveCashPrice
        : (discountPercent == package.packageDefaultCreditDiscount
            ? package.effectiveCreditPrice
            : unitPrice);
    final unitNet = effectiveUnitPrice > 0 ? effectiveUnitPrice : unitPrice;
    final sheetSize = package.packageVoucherCount;
    final halfSheet = VoucherSheetCalculator.halfSheetCards(sheetSize);
    final presets = VoucherSheetCalculator.getPresets(sheetSize);

    return Container(
      padding: EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: isSelected
            ? colors.primary.withValues(alpha: 0.04)
            : colors.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: AppRadius.mdRadius,
        border: Border.all(
          color: isSelected
              ? colors.primary.withValues(alpha: 0.5)
              : colors.outlineVariant.withValues(alpha: 0.25),
          width: isSelected ? 1.4.w : 1.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // اسم الباقة ومعيار الورقة والأسعار
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      package.packageName,
                      style: AppTypography.titleSmall.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    AppSpacing.vXxs,
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      child: Row(
                        children: [
                          Text(
                            '${AmountFormatter.formatValue(unitPrice)} ر.ي',
                            style: AppTypography.labelSmall.copyWith(
                              color: colors.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (discountPercent > 0) ...[
                            AppSpacing.hXs,
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 5.w,
                                vertical: 1.h,
                              ),
                              decoration: BoxDecoration(
                                color: colors.primary.withValues(alpha: 0.1),
                                borderRadius: AppRadius.fullRadius,
                              ),
                              child: Text(
                                'خصم ${discountPercent.toInt()}% (${AmountFormatter.formatValue(unitNet)})',
                                style: AppTypography.labelSmall.copyWith(
                                  color: colors.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 9.sp,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    AppSpacing.vXxs,
                    // شارة معيار الورقة المعتمد
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 1.5.h,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHighest.withValues(
                          alpha: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(4.r),
                        border: Border.all(
                          color: colors.outlineVariant.withValues(alpha: 0.2),
                          width: 0.6.w,
                        ),
                      ),
                      child: Text(
                        'الورقة = $sheetSize كرت • النصف = $halfSheet كرت',
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                          fontSize: 8.5.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              AppSpacing.hSm,

              // عداد الكمية التفاعلي المزدوج (كروت + أوراق)
              if (isSelected)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomButton.icon(
                      icon: Icons.remove_rounded,
                      dimension: 32.r,
                      iconSize: 16.r,
                      backgroundColor: colors.surface,
                      foregroundColor: colors.onSurface,
                      borderColor: colors.outlineVariant.withValues(alpha: 0.4),
                      borderWidth: 1.w,
                      shape: AppButtonShape.rounded,
                      onPressed: onDecrement,
                    ),
                    // رقم الكمية قابل للنقر لفتح حوار الإدخال المباشر
                    CustomInteractiveBounce(
                      onTap: () => _openQuantityModal(context),
                      child: Container(
                        constraints: BoxConstraints(minWidth: 46.w),
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              quantity.toString(),
                              style: AppTypography.titleSmall.copyWith(
                                color: colors.onSurface,
                                fontWeight: FontWeight.w900,
                                fontSize: 13.5.sp,
                              ),
                            ),
                            Text(
                              VoucherSheetCalculator.describe(
                                quantity,
                                package.packageVoucherCount,
                              ),
                              style: AppTypography.labelSmall.copyWith(
                                color: colors.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 8.5.sp,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                    CustomButton.icon(
                      icon: Icons.add_rounded,
                      dimension: 32.r,
                      iconSize: 16.r,
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
                      shape: AppButtonShape.rounded,
                      onPressed: onIncrement,
                    ),
                  ],
                )
              else
                CustomButton.outline(
                  text: 'تحديد كمية',
                  icon: Icons.add_rounded,
                  size: AppButtonSize.small,
                  iconSize: 14.r,
                  height: 32.h,
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                  onPressed: () {
                    if (onSetQuantity != null) {
                      onSetQuantity!(1);
                    } else {
                      onIncrement();
                    }
                  },
                ),
            ],
          ),

          // كبسولات الأوراق السريعة الذكية
          if (isSelected) ...[
            AppSpacing.vXs,
            Wrap(
              spacing: 6.w,
              runSpacing: 4.h,
              children: [
                ...presets.map((p) {
                  final isCurrent = quantity == p.cards;
                  return _PresetChip(
                    label: p.label,
                    isSelected: isCurrent,
                    onSelected: () {
                      if (onSetQuantity != null) {
                        onSetQuantity!(p.cards);
                      } else {
                        onAddPreset(p.cards);
                      }
                    },
                  );
                }),
                // كبسولة زيادة ورقة إضافية
                _PresetChip(
                  label: '+ورقة (+$sheetSize)',
                  isSelected: false,
                  onSelected: () => onAddPreset(sheetSize),
                ),
                // زر التخصيص السريع
                _PresetChip(
                  label: 'تخصيص ✍️',
                  isSelected: false,
                  onSelected: () => _openQuantityModal(context),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _PresetChip({
    required this.label,
    this.isSelected = false,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomInteractiveBounce(
      onTap: onSelected,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primary.withValues(alpha: 0.15)
              : colors.surfaceContainerHighest,
          borderRadius: AppRadius.fullRadius,
          border: Border.all(
            color: isSelected
                ? colors.primary
                : colors.outlineVariant.withValues(alpha: 0.25),
            width: isSelected ? 1.2.w : 0.8.w,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: isSelected ? colors.primary : colors.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
            fontSize: 9.5.sp,
          ),
        ),
      ),
    );
  }
}
