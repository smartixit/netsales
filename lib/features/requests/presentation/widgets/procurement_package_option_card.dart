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

/// بطاقة الباقة وفق المرجع المرئي المرسل: هوية بصرية، أسعار، مواصفات،
///
/// كمية مباشرة، مكافئ ورقي، وقيمة البند في تسلسل رأسي واحد.
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

  static const _emerald = Color(0xFF087B61);
  static const _deepEmerald = Color(0xFF064F43);

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

  String _paperDescription(int count, int sheetSize) {
    if (count <= 0) return 'لم تحدد كمية بعد';
    return VoucherSheetCalculator.describe(count, sheetSize);
  }

  bool get _hasMatchingQuote =>
      quoteLine != null && quantity > 0 && quoteLine!.voucherCount == quantity;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final sheetSize = package.packageVoucherCount > 0
        ? package.packageVoucherCount
        : 1;
    final halfSheet = (sheetSize / 2).ceil();
    final selected = quantity > 0;
    final discount = isCashSale ? _cashDiscount : _creditDiscount;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 190),
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: selected
              ? _emerald.withValues(alpha: .46)
              : colors.outlineVariant.withValues(alpha: .72),
          width: selected ? 1.35 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _deepEmerald.withValues(alpha: selected ? .105 : .045),
            blurRadius: selected ? 21 : 15,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PackageHero(
            package: package,
            isCustomDiscount: customDiscount?.isCustom == true,
            discount: discount,
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(11.r, 11.r, 11.r, 11.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                AppSpacing.vSm,
                _SpecificationStrip(package: package),
                AppSpacing.vSm,
                _QuantityControls(
                  quantity: quantity,
                  controller: quantityController,
                  sheetSize: sheetSize,
                  halfSheet: halfSheet,
                  onChanged: onSetQuantity,
                ),
                AppSpacing.vSm,
                _PaperEquivalent(
                  description: _paperDescription(quantity, sheetSize),
                ),
                AppSpacing.vSm,
                _LineTotal(
                  line: _hasMatchingQuote ? quoteLine : null,
                  selected: selected,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PackageHero extends StatelessWidget {
  const _PackageHero({
    required this.package,
    required this.isCustomDiscount,
    required this.discount,
  });
  final PackageEntity package;
  final bool isCustomDiscount;
  final double discount;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      height: 124.r,
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(12.r, 9.r, 8.r, 9.r),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.r, vertical: 5.r),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                        colors: [Color(0xFF0BA777), Color(0xFF075C49)],
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      boxShadow: [
                        BoxShadow(
                          color: _emerald.withValues(alpha: .18),
                          blurRadius: 9,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star_rounded, color: Colors.white, size: 14.r),
                        AppSpacing.hXxs,
                        Text(
                          isCustomDiscount
                              ? 'خصم خاص'
                              : discount > 0
                                  ? 'عرض الباقة'
                                  : 'باقة الشبكة',
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.vXs,
                  Text(
                    package.packageName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: AppTypography.titleMedium.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w900,
                      height: 1.3,
                    ),
                  ),
                  AppSpacing.vXxs,
                  Text(
                    'باقة إنترنت متكاملة للمنشآت',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: AppTypography.bodySmall.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const _PackageArtwork(),
        ],
      ),
    );
  }
}

const _emerald = Color(0xFF087B61);

/// لون الباقة محصور في مساحة الهوية؛ لا ينتقل إلى نصوص أو أزرار المحتوى.
class _PackageArtwork extends StatelessWidget {
  const _PackageArtwork();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 124.r,
      height: 124.r,
      child: ClipRRect(
        borderRadius: BorderRadiusDirectional.only(
          bottomStart: Radius.circular(25.r),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF12B88A),
                    Color(0xFF087B61),
                    Color(0xFF03483E),
                  ],
                ),
              ),
            ),
            CustomPaint(painter: _NetworkArtworkPainter()),
            Positioned(
              top: 10.r,
              left: 10.r,
              child: Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white.withValues(alpha: .9),
                size: 15.r,
              ),
            ),
            Center(
              child: Transform.rotate(
                angle: -.20,
                child: Container(
                  width: 61.r,
                  height: 78.r,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFFFFFFF), Color(0xFFBCE9D9)],
                    ),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: Colors.white, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .27),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.sim_card_rounded,
                    size: 49.r,
                    color: const Color(0xFF087B61),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NetworkArtworkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final points = <Offset>[
      Offset(size.width * .10, size.height * .16),
      Offset(size.width * .40, size.height * .11),
      Offset(size.width * .78, size.height * .19),
      Offset(size.width * .19, size.height * .46),
      Offset(size.width * .72, size.height * .52),
      Offset(size.width * .12, size.height * .82),
      Offset(size.width * .86, size.height * .83),
    ];
    final links = Paint()
      ..color = Colors.white.withValues(alpha: .24)
      ..strokeWidth = .8;
    for (var i = 0; i < points.length; i++) {
      for (var j = i + 1; j < points.length; j++) {
        if ((points[i] - points[j]).distance < size.width * .58) {
          canvas.drawLine(points[i], points[j], links);
        }
      }
    }
    final globe = Paint()
      ..color = Colors.white.withValues(alpha: .20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final center = Offset(size.width * .49, size.height * .49);
    canvas.drawCircle(center, size.width * .41, globe);
    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: size.width * .30,
        height: size.height * .80,
      ),
      globe,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: size.width * .76,
        height: size.height * .25,
      ),
      globe,
    );
    final node = Paint()..color = const Color(0xFF8CFFE0);
    for (final point in points) {
      canvas.drawCircle(point, 2, node);
      canvas.drawCircle(
        point,
        5,
        Paint()
          ..color = const Color(0xFF8CFFE0).withValues(alpha: .24)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
      padding: EdgeInsets.symmetric(horizontal: 11.r, vertical: 10.r),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: .58)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _PriceColumn(
                  label: 'السعر النقدي',
                  price: cashPrice,
                  discount: cashDiscount,
                  money: money,
                  selected: isCashSale,
                ),
              ),
              Container(
                width: 1,
                height: 70.r,
                margin: EdgeInsets.symmetric(horizontal: 10.r),
                color: colors.outlineVariant,
              ),
              Expanded(
                child: _PriceColumn(
                  label: 'السعر الآجل',
                  price: creditPrice,
                  discount: creditDiscount,
                  money: money,
                  selected: !isCashSale,
                ),
              ),
            ],
          ),
          AppSpacing.vXs,
          Row(
            children: [
              Expanded(
                child: Text(
                  'السعر الأساسي قبل الخصم',
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
                  decoration: TextDecoration.lineThrough,
                  fontWeight: FontWeight.w800,
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

class _PriceColumn extends StatelessWidget {
  const _PriceColumn({
    required this.label,
    required this.price,
    required this.discount,
    required this.money,
    required this.selected,
  });
  final String label;
  final double price;
  final double discount;
  final String Function(num) money;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.end,
                style: AppTypography.labelMedium.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (selected)
              Container(
                width: 6.r,
                height: 6.r,
                decoration: BoxDecoration(
                  color: colors.primary,
                  shape: BoxShape.circle,
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
            style: AppTypography.titleLarge.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ),
        AppSpacing.vXxs,
        if (discount > 0)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 9.r, vertical: 4.r),
            decoration: BoxDecoration(
              color: colors.success.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(AppRadius.full),
              border: Border.all(color: colors.success.withValues(alpha: .22)),
            ),
            child: Text(
              'خصم ${discount.toStringAsFixed(2)}٪',
              style: AppTypography.labelSmall.copyWith(
                color: colors.success,
                fontWeight: FontWeight.w900,
              ),
            ),
          )
        else
          Text(
            'حسب التعرفة',
            style: AppTypography.labelSmall.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}

class _SpecificationStrip extends StatelessWidget {
  const _SpecificationStrip({required this.package});
  final PackageEntity package;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.r, vertical: 10.r),
      decoration: BoxDecoration(
        color: _emerald.withValues(alpha: .075),
        borderRadius: BorderRadius.circular(17.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: _Specification(
              icon: Icons.inventory_2_rounded,
              label: 'السعة',
              value: '${package.packageVoucherCount} كرت',
            ),
          ),
          _SpecificationDivider(color: colors.outlineVariant),
          Expanded(
            child: _Specification(
              icon: Icons.access_time_rounded,
              label: 'الصلاحية',
              value: package.validityDisplay,
            ),
          ),
          _SpecificationDivider(color: colors.outlineVariant),
          Expanded(
            child: _Specification(
              icon: Icons.bolt_rounded,
              label: 'المدة',
              value: package.uptimeDisplay,
            ),
          ),
        ],
      ),
    );
  }
}

class _Specification extends StatelessWidget {
  const _Specification({
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
      padding: EdgeInsets.symmetric(horizontal: 4.r),
      child: Column(
        children: [
          Icon(icon, size: 21.r, color: colors.primary),
          AppSpacing.vXxs,
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
            textAlign: TextAlign.center,
            style: AppTypography.labelMedium.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecificationDivider extends StatelessWidget {
  const _SpecificationDivider({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 49.r,
        color: color.withValues(alpha: .72),
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'الكمية',
                style: AppTypography.titleSmall.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            SizedBox(
              width: 180.r,
              child: Container(
                height: 48.r,
                padding: EdgeInsets.all(4.r),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: colors.outlineVariant.withValues(alpha: .85)),
                ),
                child: Row(
                  children: [
                    CustomButton.icon(
                      icon: Icons.remove_rounded,
                      tooltip: 'إنقاص كرت',
                      dimension: 38.r,
                      size: AppButtonSize.small,
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
                      onPressed: quantity > 0 ? () => onChanged(quantity - 1) : null,
                    ),
                    Expanded(
                      child: CustomTextField(
                        controller: controller,
                        label: '',
                        hint: '0',
                        isRequired: false,
                        isDense: true,
                        textAlign: TextAlign.center,
                        textStyle: AppTypography.titleLarge.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w900,
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 2.r, vertical: 5.r),
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
                    CustomButton.icon(
                      icon: Icons.add_rounded,
                      tooltip: 'إضافة كرت',
                      dimension: 38.r,
                      size: AppButtonSize.small,
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
                      onPressed: () => onChanged((quantity + 1).clamp(0, 1000000)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        AppSpacing.vSm,
        Row(
          children: [
            Expanded(
              child: CustomButton.outline(
                text: 'إضافة ورقة',
                icon: Icons.note_add_outlined,
                size: AppButtonSize.small,
                height: 43.r,
                borderRadius: 13.r,
                foregroundColor: colors.primary,
                borderColor: colors.primary.withValues(alpha: .72),
                textStyle: AppTypography.labelMedium.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w900,
                ),
                onPressed: () => onChanged((quantity + sheetSize).clamp(0, 1000000)),
              ),
            ),
            AppSpacing.hXs,
            Expanded(
              child: CustomButton.outline(
                text: 'نصف ورقة',
                icon: Icons.description_outlined,
                size: AppButtonSize.small,
                height: 43.r,
                borderRadius: 13.r,
                foregroundColor: colors.primary,
                borderColor: colors.primary.withValues(alpha: .52),
                textStyle: AppTypography.labelMedium.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w900,
                ),
                onPressed: () => onChanged((quantity + halfSheet).clamp(0, 1000000)),
              ),
            ),
            AppSpacing.hXs,
            Expanded(
              child: CustomButton.outline(
                text: 'تصفير الكمية',
                icon: Icons.refresh_rounded,
                size: AppButtonSize.small,
                height: 43.r,
                borderRadius: 13.r,
                foregroundColor: colors.error,
                borderColor: colors.error.withValues(alpha: .75),
                textStyle: AppTypography.labelMedium.copyWith(
                  color: colors.error,
                  fontWeight: FontWeight.w900,
                ),
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
  const _PaperEquivalent({required this.description});
  final String description;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 11.r, vertical: 10.r),
      decoration: BoxDecoration(
        color: _emerald.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.card_giftcard_rounded, size: 19.r, color: colors.primary),
          AppSpacing.hXs,
          Flexible(
            child: Text(
              'المكافئ الورقي: $description',
              textAlign: TextAlign.center,
              style: AppTypography.labelLarge.copyWith(
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

class _LineTotal extends StatelessWidget {
  const _LineTotal({required this.line, required this.selected});
  final ProcurementQuoteLineEntity? line;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.r, vertical: 14.r),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [Color(0xFF075D50), Color(0xFF033F38)],
        ),
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: _emerald.withValues(alpha: .20),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'قيمة البند التقديرية',
              style: AppTypography.titleSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          if (line != null)
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '${AmountFormatter.formatValue(line!.lineNetTotal, decimalPlaces: 2)} ر.ي',
                textDirection: TextDirection.ltr,
                style: AppTypography.titleLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            )
          else
            Text(
              selected ? 'بانتظار عرض السعر' : '—',
              style: AppTypography.labelMedium.copyWith(
                color: Colors.white.withValues(alpha: .86),
                fontWeight: FontWeight.w800,
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
