import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/core/utils/voucher_sheet_calculator.dart';
import 'package:netsales/features/catalog/domain/entities/effective_package_discount_entity.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/features/requests/domain/entities/procurement_quote_line_entity.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';

/// بطاقة باقة إنترنت: الهوية، التعرفة، المواصفات، والتحكم المباشر بالكمية.
class ProcurementPackageOptionCard extends StatelessWidget {
  const ProcurementPackageOptionCard({
    super.key,
    required this.package,
    required this.quantity,
    required this.onSetQuantity,
    required this.isCashSale,
    required this.quantityController,
    this.customDiscount,
    this.quoteLine,
    this.isPricingLoading = false,
  });

  final PackageEntity package;
  final int quantity;
  final ValueChanged<int> onSetQuantity;
  final bool isCashSale;
  final TextEditingController quantityController;
  final EffectivePackageDiscountEntity? customDiscount;
  final ProcurementQuoteLineEntity? quoteLine;
  final bool isPricingLoading;

  double get _basePrice => customDiscount?.originalPackagePrice ??
      (package.procurementBaseUnitPriceMinor != null
          ? package.procurementBaseUnitPriceMinor! / 100
          : package.packageVoucherPrice);

  double get _cashPrice => customDiscount?.effectiveCashPrice ??
      (package.procurementCashUnitPriceMinor != null
          ? package.procurementCashUnitPriceMinor! / 100
          : package.effectiveCashPrice);

  double get _creditPrice => customDiscount?.effectiveCreditPrice ??
      (package.procurementCreditUnitPriceMinor != null
          ? package.procurementCreditUnitPriceMinor! / 100
          : package.effectiveCreditPrice);

  double get _cashDiscount => customDiscount?.discountCash ??
      (package.procurementCashDiscountBasisPoints != null
          ? package.procurementCashDiscountBasisPoints! / 100
          : package.packageDefaultCashDiscount);

  double get _creditDiscount => customDiscount?.discountCredit ??
      (package.procurementCreditDiscountBasisPoints != null
          ? package.procurementCreditDiscountBasisPoints! / 100
          : package.packageDefaultCreditDiscount);

  String _money(num value) =>
      AmountFormatter.formatValue(value, decimalPlaces: 2);

  bool get _hasMatchingQuote =>
      quoteLine != null && quantity > 0 && quoteLine!.voucherCount == quantity;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final accent = _packageAccent(package.packageColor, colors.primary);
    final tint = Color.alphaBlend(
      accent.withValues(alpha: .11),
      colors.surface,
    );
    final sheetSize =
        package.packageVoucherCount > 0 ? package.packageVoucherCount : 1;
    final selected = quantity > 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(19.r),
        border: Border.all(
          color: selected
              ? accent.withValues(alpha: .52)
              : colors.outlineVariant.withValues(alpha: .68),
          width: selected ? 1.35 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: selected ? .075 : .035),
            blurRadius: selected ? 19 : 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(13.r, 13.r, 13.r, 12.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _PackageHeader(
                  package: package,
                  accent: accent,
                  tint: tint,
                  isSelected: selected,
                  isCustomDiscount: customDiscount?.isCustom == true,
                ),
                AppSpacing.vSm,
                _TariffPanel(
                  basePrice: _basePrice,
                  cashPrice: _cashPrice,
                  creditPrice: _creditPrice,
                  cashDiscount: _cashDiscount,
                  creditDiscount: _creditDiscount,
                  isCashSale: isCashSale,
                  isPricingLoading: isPricingLoading,
                  money: _money,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 11.r),
                  child: _SpecificationStrip(package: package),
                ),
                _QuantityControls(
                  quantity: quantity,
                  controller: quantityController,
                  sheetSize: sheetSize,
                  halfSheet: (sheetSize / 2).ceil(),
                  onChanged: onSetQuantity,
                ),
                if (selected) ...[
                  AppSpacing.vSm,
                  _PaperEquivalent(quantity: quantity, sheetSize: sheetSize),
                  AppSpacing.vSm,
                  _LinePreview(
                    line: _hasMatchingQuote ? quoteLine : null,
                    accent: accent,
                  ),
                ],
              ],
            ),
          ),
          PositionedDirectional(
            end: 0,
            top: 0,
            bottom: 0,
            child: IgnorePointer(
              child: Container(
                width: 3.r,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: .92),
                  borderRadius: BorderRadiusDirectional.only(
                    topEnd: Radius.circular(19.r),
                    bottomEnd: Radius.circular(19.r),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Color _packageAccent(String? value, Color fallback) {
  final normalized = value?.trim().replaceFirst('#', '');
  if (normalized == null ||
      (normalized.length != 6 && normalized.length != 8)) {
    return fallback;
  }

  final parsed = int.tryParse(normalized, radix: 16);
  if (parsed == null) return fallback;
  return normalized.length == 6
      ? Color(0xFF000000 | parsed)
      : Color(parsed);
}

class _PackageHeader extends StatelessWidget {
  const _PackageHeader({
    required this.package,
    required this.accent,
    required this.tint,
    required this.isSelected,
    required this.isCustomDiscount,
  });

  final PackageEntity package;
  final Color accent;
  final Color tint;
  final bool isSelected;
  final bool isCustomDiscount;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 43.r,
          height: 43.r,
          decoration: BoxDecoration(
            color: tint,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: accent.withValues(alpha: .13)),
          ),
          child: Icon(
            Icons.signal_cellular_alt_rounded,
            color: accent,
            size: 22.r,
          ),
        ),
        AppSpacing.hSm,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 4.r,
                    height: 4.r,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  AppSpacing.hXxs,
                  Flexible(
                    child: Text(
                      isCustomDiscount
                          ? 'اتفاق تعاقدي مخصص'
                          : 'تعرفة الشبكة الأساسية',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.labelSmall.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              AppSpacing.vXxs,
              Text(
                package.packageName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.titleSmall.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w900,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        if (isSelected) ...[
          AppSpacing.hXs,
          Container(
            padding: EdgeInsets.symmetric(horizontal: 7.r, vertical: 5.r),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: .7),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_rounded, size: 11.r, color: colors.success),
                AppSpacing.hXxs,
                Text(
                  'ضمن الطلب',
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _TariffPanel extends StatelessWidget {
  const _TariffPanel({
    required this.basePrice,
    required this.cashPrice,
    required this.creditPrice,
    required this.cashDiscount,
    required this.creditDiscount,
    required this.isCashSale,
    required this.isPricingLoading,
    required this.money,
  });

  final double basePrice;
  final double cashPrice;
  final double creditPrice;
  final double cashDiscount;
  final double creditDiscount;
  final bool isCashSale;
  final bool isPricingLoading;
  final String Function(num) money;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: .65),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'تعرفة هذه الباقة',
                style: AppTypography.labelMedium.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              Text(
                'السعر لكل كرت',
                style: AppTypography.labelSmall.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          AppSpacing.vSm,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _PriceOption(
                  label: 'نقدي',
                  price: cashPrice,
                  discount: cashDiscount,
                  selected: isCashSale,
                  money: money,
                ),
              ),
              AppSpacing.hXs,
              Expanded(
                child: _PriceOption(
                  label: 'آجل',
                  price: creditPrice,
                  discount: creditDiscount,
                  selected: !isCashSale,
                  money: money,
                ),
              ),
            ],
          ),
          AppSpacing.vXs,
          Row(
            children: [
              Expanded(
                child: Text(
                  'سعر الوحدة قبل الخصم',
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
              Text(
                '${money(basePrice)} ر.ي',
                textDirection: TextDirection.ltr,
                style: AppTypography.labelSmall.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w800,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ],
          ),
          if (isPricingLoading) ...[
            AppSpacing.vXs,
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: LinearProgressIndicator(
                minHeight: 2.r,
                color: colors.primary,
                backgroundColor: colors.surfaceContainerHighest,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PriceOption extends StatelessWidget {
  const _PriceOption({
    required this.label,
    required this.price,
    required this.discount,
    required this.selected,
    required this.money,
  });

  final String label;
  final double price;
  final double discount;
  final bool selected;
  final String Function(num) money;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      constraints: BoxConstraints(minHeight: 82.r),
      padding: EdgeInsets.symmetric(horizontal: 9.r, vertical: 8.r),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(11.r),
        border: Border.all(
          color: selected ? colors.primary : Colors.transparent,
          width: selected ? 1.2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (selected)
                Text(
                  'المحدد الآن',
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
            ],
          ),
          AppSpacing.vXxs,
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerEnd,
            child: Text(
              '${money(price)} ر.ي',
              textDirection: TextDirection.ltr,
              maxLines: 1,
              style: AppTypography.titleSmall.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          AppSpacing.vXxs,
          Row(
            children: [
              Text(
                'خصم تعاقدي',
                style: AppTypography.labelSmall.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Text(
                '${discount.toStringAsFixed(2)}٪',
                style: AppTypography.labelSmall.copyWith(
                  color: colors.success,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SpecificationStrip extends StatelessWidget {
  const _SpecificationStrip({required this.package});

  final PackageEntity package;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _PackageSpec(
            icon: Icons.data_usage_rounded,
            label: 'السعة',
            value: package.balanceDisplay,
          ),
        ),
        _SpecDivider(color: colors.outlineVariant),
        Expanded(
          child: _PackageSpec(
            icon: Icons.timer_outlined,
            label: 'وقت الاستخدام',
            value: package.uptimeDisplay,
          ),
        ),
        _SpecDivider(color: colors.outlineVariant),
        Expanded(
          child: _PackageSpec(
            icon: Icons.event_available_outlined,
            label: 'الصلاحية',
            value: package.validityDisplay,
          ),
        ),
      ],
    );
  }
}

class _PackageSpec extends StatelessWidget {
  const _PackageSpec({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 7.r),
      child: Row(
        children: [
          Container(
            width: 25.r,
            height: 25.r,
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              icon,
              size: 13.r,
              color: colors.onSurfaceVariant,
            ),
          ),
          AppSpacing.hXxs,
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                AppSpacing.vXxs,
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecDivider extends StatelessWidget {
  const _SpecDivider({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 34.r,
        margin: EdgeInsets.symmetric(horizontal: 2.r),
        color: color.withValues(alpha: .65),
      );
}

class _QuantityControls extends StatelessWidget {
  const _QuantityControls({
    required this.quantity,
    required this.controller,
    required this.sheetSize,
    required this.halfSheet,
    required this.onChanged,
  });

  final int quantity;
  final TextEditingController controller;
  final int sheetSize;
  final int halfSheet;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'الكمية المطلوبة',
                style: AppTypography.labelLarge.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Text(
              'سعة الورقة: $sheetSize كرت',
              style: AppTypography.labelSmall.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        AppSpacing.vSm,
        Row(
          children: [
            CustomButton.icon(
              icon: Icons.add_rounded,
              tooltip: 'إضافة كرت',
              dimension: 36.r,
              size: AppButtonSize.small,
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
              onPressed: () => onChanged((quantity + 1).clamp(0, 1000000)),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 7.r),
                child: CustomTextField(
                  controller: controller,
                  label: '',
                  hint: '0',
                  isRequired: false,
                  isDense: true,
                  textAlign: TextAlign.center,
                  textStyle: AppTypography.titleMedium.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w900,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 3.r,
                    vertical: 6.r,
                  ),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    const _MaximumQuantityInputFormatter(1000000),
                  ],
                  onChanged: (value) {
                    final parsed = int.tryParse(value) ?? 0;
                    onChanged(parsed.clamp(0, 1000000));
                  },
                ),
              ),
            ),
            CustomButton.icon(
              icon: Icons.remove_rounded,
              tooltip: 'إنقاص كرت',
              dimension: 36.r,
              size: AppButtonSize.small,
              backgroundColor: colors.surfaceContainerLow,
              foregroundColor: colors.onSurfaceVariant,
              onPressed: quantity > 0 ? () => onChanged(quantity - 1) : null,
            ),
            AppSpacing.hXs,
            Text(
              'كرت',
              style: AppTypography.labelSmall.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        AppSpacing.vSm,
        Row(
          children: [
            Expanded(
              child: CustomButton.outline(
                text: '+ ورقة',
                icon: Icons.note_add_outlined,
                size: AppButtonSize.small,
                foregroundColor: colors.onSurfaceVariant,
                borderColor: colors.outlineVariant,
                onPressed: () =>
                    onChanged((quantity + sheetSize).clamp(0, 1000000)),
              ),
            ),
            AppSpacing.hXs,
            Expanded(
              child: CustomButton.outline(
                text: '½ ورقة',
                icon: Icons.description_outlined,
                size: AppButtonSize.small,
                foregroundColor: colors.onSurfaceVariant,
                borderColor: colors.outlineVariant,
                onPressed: () =>
                    onChanged((quantity + halfSheet).clamp(0, 1000000)),
              ),
            ),
            AppSpacing.hXs,
            Expanded(
              child: CustomButton.outline(
                text: 'تصفير',
                icon: Icons.refresh_rounded,
                size: AppButtonSize.small,
                foregroundColor: colors.error,
                borderColor: colors.error.withValues(alpha: .55),
                onPressed: quantity > 0 ? () => onChanged(0) : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PaperEquivalent extends StatelessWidget {
  const _PaperEquivalent({
    required this.quantity,
    required this.sheetSize,
  });

  final int quantity;
  final int sheetSize;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final description = VoucherSheetCalculator.describe(quantity, sheetSize);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.r, vertical: 8.r),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: .65),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.layers_outlined,
            size: 16.r,
            color: colors.onSurfaceVariant,
          ),
          AppSpacing.hXs,
          Expanded(
            child: Text(
              'المكافئ الورقي للكمية',
              style: AppTypography.labelSmall.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            description,
            textAlign: TextAlign.end,
            style: AppTypography.labelSmall.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _LinePreview extends StatelessWidget {
  const _LinePreview({
    required this.line,
    required this.accent,
  });

  final ProcurementQuoteLineEntity? line;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.r, vertical: 8.r),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          accent.withValues(alpha: .045),
          colors.surface,
        ),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: accent.withValues(alpha: .15)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line == null ? 'حالة التسعير' : 'عرض السعر المعتمد للبند',
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                AppSpacing.vXxs,
                Text(
                  line == null ? 'بانتظار عرض سعر مطابق للكمية' : 'قيمة البند',
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          if (line != null)
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '${AmountFormatter.formatValue(line!.lineNetTotal, decimalPlaces: 2)} ر.ي',
                textDirection: TextDirection.ltr,
                style: AppTypography.titleSmall.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MaximumQuantityInputFormatter extends TextInputFormatter {
  const _MaximumQuantityInputFormatter(this.maximum);

  final int maximum;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final value = int.tryParse(newValue.text);
    if (value == null || value <= maximum) return newValue;
    return oldValue;
  }
}
