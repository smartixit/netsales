import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/enums/sale_type.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/widgets/badges/custom_chip.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';
import 'package:netsales/widgets/pickers/custom_color_picker.dart';

/// بطاقة باقة مستقلة: مواصفاتها والتحكم بكمية طلبها في موضع واحد.
class ProcurementPackageOptionCard extends StatelessWidget {
  const ProcurementPackageOptionCard({
    super.key,
    required this.package,
    required this.quantity,
    required this.saleType,
    required this.onIncrement,
    required this.onDecrement,
    required this.onEditQuantity,
  });

  final PackageEntity package;
  final int quantity;
  final SaleType saleType;
  final VoidCallback onIncrement;
  final VoidCallback? onDecrement;
  final VoidCallback onEditQuantity;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final packageColor = CustomColorPicker.parseHex(package.packageColor);
    final isInOrder = quantity > 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isInOrder
            ? colors.primary.withValues(alpha: 0.055)
            : colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: isInOrder
              ? colors.primary.withValues(alpha: 0.60)
              : colors.outlineVariant.withValues(alpha: 0.40),
          width: isInOrder ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: packageColor.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  Icons.wifi_tethering_rounded,
                  color: packageColor,
                  size: 22,
                ),
              ),
              AppSpacing.hSm,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      package.packageName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.titleSmall.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    AppSpacing.vXxs,
                    Text(
                      'مواصفات الباقة',
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isInOrder)
                const CustomChip(
                  label: 'في الطلب',
                  icon: Icons.check_circle_rounded,
                  isCompact: true,
                ),
            ],
          ),
          AppSpacing.vSm,
          Row(
            children: [
              Icon(Icons.layers_outlined, size: 16, color: colors.primary),
              AppSpacing.hXs,
              Expanded(
                child: Text(
                  'الورقة الواحدة تحتوي ${package.packageVoucherCount} كرت',
                  style: AppTypography.labelMedium.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.vSm,
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.xs,
            children: [
              _PackageSpec(icon: Icons.data_usage_outlined, label: package.balanceDisplay),
              _PackageSpec(icon: Icons.timer_outlined, label: package.uptimeDisplay),
              _PackageSpec(icon: Icons.event_available_outlined, label: package.validityDisplay),
            ],
          ),
          AppSpacing.vSm,
          _LivePackagePrice(package: package, saleType: saleType),
          AppSpacing.vSm,
          Divider(height: 1, color: colors.outlineVariant.withValues(alpha: 0.35)),
          AppSpacing.vXs,
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الكمية المطلوبة',
                      style: AppTypography.labelMedium.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'يمكنك طلب أي عدد من الكروت',
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              CustomButton.icon(
                icon: Icons.remove_rounded,
                tooltip: 'إنقاص كرت واحد',
                size: AppButtonSize.small,
                dimension: 38,
                onPressed: onDecrement,
              ),
              AppSpacing.hXs,
              CustomInteractiveBounce(
                onTap: onEditQuantity,
                child: Container(
                  constraints: const BoxConstraints(minWidth: 58, minHeight: 38),
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: colors.primary.withValues(alpha: 0.20)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$quantity',
                        style: AppTypography.titleSmall.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AppSpacing.hXxs,
                      Icon(Icons.edit_outlined, size: 14, color: colors.primary),
                    ],
                  ),
                ),
              ),
              AppSpacing.hXs,
              CustomButton.icon(
                icon: Icons.add_rounded,
                tooltip: 'إضافة كرت واحد',
                size: AppButtonSize.small,
                dimension: 38,
                foregroundColor: colors.primary,
                backgroundColor: colors.primary.withValues(alpha: 0.10),
                onPressed: onIncrement,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PackageSpec extends StatelessWidget {
  const _PackageSpec({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: colors.onSurfaceVariant),
        AppSpacing.hXxs,
        Text(label, style: AppTypography.labelSmall.copyWith(color: colors.onSurfaceVariant)),
      ],
    );
  }
}


class _LivePackagePrice extends StatelessWidget {
  const _LivePackagePrice({required this.package, required this.saleType});
  final PackageEntity package;
  final SaleType saleType;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final cash = package.procurementCashUnitPriceMinor;
    final credit = package.procurementCreditUnitPriceMinor;
    final active = saleType == SaleType.cash ? cash : credit;
    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('تعرفة نقطة البيع', style: AppTypography.labelSmall.copyWith(
            color: colors.onSurfaceVariant, fontWeight: FontWeight.w700,
          )),
          AppSpacing.vXs,
          Row(
            children: [
              Expanded(child: _PriceValue(label: 'نقدي', value: cash, active: saleType == SaleType.cash)),
              Expanded(child: _PriceValue(label: 'آجل', value: credit, active: saleType == SaleType.credit)),
            ],
          ),
          AppSpacing.vXs,
          Text(
            active == null ? 'السعر الحالي غير متاح' :
              'سعر الكرت: ${AmountFormatter.formatValue(active / 100)} ر.ي',
            style: AppTypography.labelMedium.copyWith(
              color: colors.primary, fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceValue extends StatelessWidget {
  const _PriceValue({required this.label, required this.value, required this.active});
  final String label;
  final int? value;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.labelSmall.copyWith(
          color: active ? colors.primary : colors.onSurfaceVariant,
        )),
        Text(
          value == null ? '—' : '${AmountFormatter.formatValue(value! / 100)} ر.ي',
          style: AppTypography.titleSmall.copyWith(
            color: active ? colors.primary : colors.onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
