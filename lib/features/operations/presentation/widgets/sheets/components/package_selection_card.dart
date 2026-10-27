import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/packages/domain/entities/voucher_package_entity.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// ============================================================================
/// بطاقة اختيار باقة الكروت التفاعلية الذكية (PackageSelectionCard)
/// ============================================================================
/// تتيح تحديد كميات باقات الكروت مع كبسولات كميات سريعة (+20, +50, +100)
/// لتمكين الموزع من الإنجاز السريع بنقرة واحدة وتفادي التكرار اليدوي.
class PackageSelectionCard extends StatelessWidget {
  final VoucherPackageEntity package;
  final int quantity;
  final double discountPercent;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final ValueChanged<int> onAddPreset;

  const PackageSelectionCard({
    super.key,
    required this.package,
    required this.quantity,
    required this.discountPercent,
    required this.onIncrement,
    required this.onDecrement,
    required this.onAddPreset,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isSelected = quantity > 0;
    final unitPrice = package.packageVoucherPrice;
    final unitNet = unitPrice - (unitPrice * (discountPercent / 100));

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
            children: [
              // اسم الباقة وسعرها
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
                  ],
                ),
              ),

              AppSpacing.hSm,

              // عداد الكمية
              if (isSelected)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomInteractiveBounce(
                      onTap: onDecrement,
                      child: Container(
                        width: 32.r,
                        height: 32.r,
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: AppRadius.xsRadius,
                          border: Border.all(
                            color: colors.outlineVariant.withValues(alpha: 0.4),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.remove_rounded,
                          size: 16.r,
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                    Container(
                      constraints: BoxConstraints(minWidth: 38.w),
                      alignment: Alignment.center,
                      child: Text(
                        quantity.toString(),
                        style: AppTypography.titleSmall.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    CustomInteractiveBounce(
                      onTap: onIncrement,
                      child: Container(
                        width: 32.r,
                        height: 32.r,
                        decoration: BoxDecoration(
                          color: colors.primary,
                          borderRadius: AppRadius.xsRadius,
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.add_rounded,
                          size: 16.r,
                          color: colors.onPrimary,
                        ),
                      ),
                    ),
                  ],
                )
              else
                CustomInteractiveBounce(
                  onTap: onIncrement,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: AppRadius.smRadius,
                      border: Border.all(
                        color: colors.outlineVariant.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add_rounded,
                          size: 15.r,
                          color: colors.primary,
                        ),
                        AppSpacing.hXxs,
                        Text(
                          'تحديد كمية',
                          style: AppTypography.labelSmall.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          // كبسولات الكميات السريعة (+20, +50, +100, +200)
          if (isSelected) ...[
            AppSpacing.vXs,
            Wrap(
              spacing: 6.w,
              children: [
                _PresetChip(label: '+20', onSelected: () => onAddPreset(20)),
                _PresetChip(label: '+50', onSelected: () => onAddPreset(50)),
                _PresetChip(label: '+100', onSelected: () => onAddPreset(100)),
                _PresetChip(label: '+200', onSelected: () => onAddPreset(200)),
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
  final VoidCallback onSelected;

  const _PresetChip({required this.label, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomInteractiveBounce(
      onTap: onSelected,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: AppRadius.fullRadius,
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.25),
            width: 0.8.w,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: colors.onSurfaceVariant,
            fontWeight: FontWeight.w700,
            fontSize: 10.sp,
          ),
        ),
      ),
    );
  }
}
