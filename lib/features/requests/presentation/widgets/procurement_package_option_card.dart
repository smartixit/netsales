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
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';

/// بطاقة الباقة وفق تسلسل HTML V5: الهوية، التعرفة، المواصفات، ثم الكمية.
class ProcurementPackageOptionCard extends StatelessWidget {
  const ProcurementPackageOptionCard({
    super.key,
    required this.package,
    required this.quantity,
    required this.onSetQuantity,
    required this.isCashSale,
    required this.quantityController,
    this.customDiscount,
    this.isPricingLoading = false,
  });

  final PackageEntity package;
  final int quantity;
  final ValueChanged<int> onSetQuantity;
  final bool isCashSale;
  final TextEditingController quantityController;
  final EffectivePackageDiscountEntity? customDiscount;
  final bool isPricingLoading;

  static const _palette = <({Color accent, Color tint})>[
    (accent: Color(0xFFAA7A2C), tint: Color(0xFFFBF3E4)),
    (accent: Color(0xFF10866A), tint: Color(0xFFE7F6EF)),
    (accent: Color(0xFF237F9A), tint: Color(0xFFE7F3F7)),
    (accent: Color(0xFF5C70B7), tint: Color(0xFFEDF0FB)),
  ];

  ({Color accent, Color tint}) get _packagePalette =>
      _palette[package.packageId.abs() % _palette.length];

  double get _basePrice =>
      customDiscount?.originalPackagePrice ??
      (package.procurementBaseUnitPriceMinor != null
          ? package.procurementBaseUnitPriceMinor! / 100
          : package.packageVoucherPrice);

  double get _cashPrice =>
      customDiscount?.effectiveCashPrice ??
      (package.procurementCashUnitPriceMinor != null
          ? package.procurementCashUnitPriceMinor! / 100
          : package.effectiveCashPrice);

  double get _creditPrice =>
      customDiscount?.effectiveCreditPrice ??
      (package.procurementCreditUnitPriceMinor != null
          ? package.procurementCreditUnitPriceMinor! / 100
          : package.effectiveCreditPrice);

  double get _cashDiscount =>
      customDiscount?.discountCash ??
      (package.procurementCashDiscountBasisPoints != null
          ? package.procurementCashDiscountBasisPoints! / 100
          : package.packageDefaultCashDiscount);

  double get _creditDiscount =>
      customDiscount?.discountCredit ??
      (package.procurementCreditDiscountBasisPoints != null
          ? package.procurementCreditDiscountBasisPoints! / 100
          : package.packageDefaultCreditDiscount);

  String _money(num value) =>
      AmountFormatter.formatValue(value, decimalPlaces: 2);

  String _paperDescription(int count, int sheetSize) {
    if (count <= 0) return 'لم تحدد كمية بعد';
    if (sheetSize <= 0) return '$count كرت';
    return VoucherSheetCalculator.describe(count, sheetSize);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final palette = _packagePalette;
    final accent = palette.accent;
    final tint = palette.tint;
    final sheetSize = package.packageVoucherCount > 0
        ? package.packageVoucherCount
        : 1;
    final halfSheet = (sheetSize / 2).ceil();
    final isSelected = quantity > 0;
    final activePrice = isCashSale ? _cashPrice : _creditPrice;
    final activeDiscount = isCashSale ? _cashDiscount : _creditDiscount;
    final netTotal = activePrice * quantity;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(13.r, 13.r, 13.r, 12.r),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(19.r),
        border: Border.all(
          color: isSelected
              ? accent.withValues(alpha: .48)
              : colors.outlineVariant.withValues(alpha: .65),
          width: isSelected ? 1.35 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? accent.withValues(alpha: .10)
                : colors.shadow.withValues(alpha: .035),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          PositionedDirectional(
            end: -13.r,
            top: -13.r,
            child: IgnorePointer(
              child: Container(
                width: 112.r,
                height: 112.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? tint.withValues(alpha: .55) : Colors.transparent,
                ),
              ),
            ),
          ),
          PositionedDirectional(
            end: -13.r,
            top: -13.r,
            bottom: -12.r,
            child: Container(
              width: 3.r,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: .88),
                borderRadius: BorderRadiusDirectional.only(
                  topEnd: Radius.circular(19.r),
                  bottomEnd: Radius.circular(19.r),
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPackageHeader(
                context,
                accent: accent,
                tint: tint,
                isSelected: isSelected,
              ),
              AppSpacing.vSm,
              _buildTariffBlock(
                context,
                accent: accent,
                tint: tint,
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 11.r),
                child: _buildSpecifications(context),
              ),
              _buildQuantityBlock(
                context,
                accent: accent,
                tint: tint,
                sheetSize: sheetSize,
                halfSheet: halfSheet,
                activeDiscount: activeDiscount,
                netTotal: netTotal,
                isSelected: isSelected,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPackageHeader(
    BuildContext context, {
    required Color accent,
    required Color tint,
    required bool isSelected,
  }) {
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
            border: Border.all(color: accent.withValues(alpha: .10)),
          ),
          child: Icon(
            Icons.wifi_tethering_rounded,
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
                      customDiscount?.isCustom == true
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
              color: tint,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_rounded, size: 11.r, color: accent),
                AppSpacing.hXxs,
                Text(
                  'ضمن الطلب',
                  style: AppTypography.labelSmall.copyWith(
                    color: accent,
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

  Widget _buildTariffBlock(
    BuildContext context, {
    required Color accent,
    required Color tint,
  }) {
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
                child: _TariffOption(
                  label: 'نقدي',
                  price: _cashPrice,
                  discount: _cashDiscount,
                  selected: isCashSale,
                  accent: accent,
                  tint: tint,
                ),
              ),
              AppSpacing.hXs,
              Expanded(
                child: _TariffOption(
                  label: 'آجل',
                  price: _creditPrice,
                  discount: _creditDiscount,
                  selected: !isCashSale,
                  accent: accent,
                  tint: tint,
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
                _money(_basePrice) + ' ر.ي',
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
                backgroundColor: accent.withValues(alpha: .10),
                color: accent,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSpecifications(BuildContext context) {
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

  Widget _buildQuantityBlock(
    BuildContext context, {
    required Color accent,
    required Color tint,
    required int sheetSize,
    required int halfSheet,
    required double activeDiscount,
    required double netTotal,
    required bool isSelected,
  }) {
    final colors = context.colors;
    return Container(
      padding: EdgeInsets.only(top: 10.r),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: colors.outlineVariant.withValues(alpha: .55)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
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
                'سعة الورقة الواحدة: $sheetSize كرت',
                style: AppTypography.labelSmall.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          AppSpacing.vSm,
          _buildQuantityStepper(context, accent: accent),
          AppSpacing.vSm,
          Row(
            children: [
              Expanded(
                child: CustomButton.outline(
                  text: '− ورقة',
                  icon: Icons.remove_circle_outline_rounded,
                  size: AppButtonSize.small,
                  foregroundColor: colors.onSurfaceVariant,
                  onPressed: quantity > 0
                      ? () => onSetQuantity(
                            (quantity - sheetSize).clamp(0, 1000000),
                          )
                      : null,
                ),
              ),
              AppSpacing.hXs,
              Expanded(
                child: CustomButton.outline(
                  text: '½ ورقة',
                  size: AppButtonSize.small,
                  foregroundColor: colors.onSurfaceVariant,
                  onPressed: () => onSetQuantity(
                    (quantity + halfSheet).clamp(0, 1000000),
                  ),
                ),
              ),
              AppSpacing.hXs,
              Expanded(
                child: CustomButton.outline(
                  text: '+ ورقة',
                  icon: Icons.add_circle_outline_rounded,
                  size: AppButtonSize.small,
                  foregroundColor: accent,
                  borderColor: accent.withValues(alpha: .32),
                  onPressed: () => onSetQuantity(
                    (quantity + sheetSize).clamp(0, 1000000),
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.vXs,
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: CustomButton.text(
              text: 'تصفير الكمية',
              icon: Icons.restart_alt_rounded,
              size: AppButtonSize.small,
              foregroundColor: colors.error,
              onPressed: quantity > 0 ? () => onSetQuantity(0) : null,
            ),
          ),
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(top: 3.r),
            padding: EdgeInsets.symmetric(horizontal: 9.r, vertical: 7.r),
            decoration: BoxDecoration(
              color: tint.withValues(alpha: .52),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: accent.withValues(alpha: .16)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'المكافئ الورقي للكمية',
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  _paperDescription(quantity, sheetSize),
                  style: AppTypography.labelSmall.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          if (isSelected) ...[
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(top: 9.r),
              padding: EdgeInsets.symmetric(horizontal: 9.r, vertical: 8.r),
              decoration: BoxDecoration(
                color: tint.withValues(alpha: .55),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: accent.withValues(alpha: .16)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$quantity كرت • ' + _paperDescription(quantity, sheetSize),
                          style: AppTypography.labelSmall.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        AppSpacing.vXxs,
                        Text(
                          'خصم ' + activeDiscount.toStringAsFixed(2) + '٪ على إجمالي البند',
                          style: AppTypography.labelSmall.copyWith(
                            color: colors.success,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.hSm,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'قيمة البند التقديرية',
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        _money(netTotal) + ' ر.ي',
                        textDirection: TextDirection.ltr,
                        style: AppTypography.titleSmall.copyWith(
                          color: accent,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuantityStepper(
    BuildContext context, {
    required Color accent,
  }) {
    final colors = context.colors;
    return Row(
      children: [
        CustomButton.icon(
          icon: Icons.remove_rounded,
          tooltip: 'إنقاص كرت واحد',
          dimension: 29.r,
          size: AppButtonSize.small,
          foregroundColor: colors.onSurfaceVariant,
          backgroundColor: colors.surface,
          onPressed: quantity > 0
              ? () => onSetQuantity((quantity - 1).clamp(0, 1000000))
              : null,
        ),
        AppSpacing.hXs,
        SizedBox(
          width: 53.r,
          height: 36.r,
          child: CustomTextField(
            controller: quantityController,
            label: '',
            hint: '0',
            isRequired: false,
            isDense: true,
            textAlign: TextAlign.center,
            textStyle: AppTypography.labelLarge.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w900,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 4.r,
              vertical: 7.r,
            ),
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            inputFormatters: const [
              FilteringTextInputFormatter.digitsOnly,
              _MaximumQuantityInputFormatter(1000000),
            ],
            onChanged: (value) {
              final parsed = int.tryParse(value) ?? 0;
              onSetQuantity(parsed.clamp(0, 1000000));
            },
          ),
        ),
        AppSpacing.hXs,
        CustomButton.icon(
          icon: Icons.add_rounded,
          tooltip: 'إضافة كرت واحد',
          dimension: 29.r,
          size: AppButtonSize.small,
          foregroundColor: Colors.white,
          backgroundColor: accent,
          onPressed: () => onSetQuantity(
            (quantity + 1).clamp(0, 1000000),
          ),
        ),
        AppSpacing.hXs,
        Text(
          'كرت',
          style: AppTypography.labelSmall.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _TariffOption extends StatelessWidget {
  const _TariffOption({
    required this.label,
    required this.price,
    required this.discount,
    required this.selected,
    required this.accent,
    required this.tint,
  });

  final String label;
  final double price;
  final double discount;
  final bool selected;
  final Color accent;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      constraints: BoxConstraints(minHeight: 91.r),
      padding: EdgeInsets.symmetric(horizontal: 9.r, vertical: 8.r),
      decoration: BoxDecoration(
        color: selected
            ? Color.alphaBlend(tint.withValues(alpha: .48), colors.surface)
            : colors.surface,
        borderRadius: BorderRadius.circular(11.r),
        border: Border.all(
          color: selected
              ? accent.withValues(alpha: .45)
              : colors.outlineVariant.withValues(alpha: .42),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: selected ? accent : colors.onSurfaceVariant,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              if (selected)
                Text(
                  'المحدد الآن',
                  style: AppTypography.labelSmall.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w900,
                  ),
                ),
            ],
          ),
          AppSpacing.vXs,
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerEnd,
              child: Text(
                AmountFormatter.formatValue(price, decimalPlaces: 2) + ' ر.ي',
                textDirection: TextDirection.ltr,
                maxLines: 1,
                style: AppTypography.titleSmall.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w900,
                ),
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
                discount.toStringAsFixed(2) + '٪',
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
