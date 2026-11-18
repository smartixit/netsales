import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/core/utils/voucher_sheet_calculator.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';
import 'package:netsales/widgets/pickers/custom_color_picker.dart';

/// عنصر مواصفات فردي للبطاقة (Domain-Agnostic Specification Item)
class PackageSpecificationItem {
  const PackageSpecificationItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

/// بطاقة الباقة العامة النقية المستقلة (Flat Props / Primitive Contract).
/// لا تعتمد على أي كيانات أعمال (Entities) أو دومين خاص بالمشروع،
/// مما يجعلها قابلة للاستخدام والنقل الفوري إلى أي تطبيق Flutter آخر.
class CustomPackageOptionCard extends StatelessWidget {
  const CustomPackageOptionCard({
    super.key,
    required this.title,
    required this.basePrice,
    required this.cashPrice,
    required this.creditPrice,
    required this.quantity,
    required this.onSetQuantity,
    required this.quantityController,
    this.isCashSale = true,
    this.currency = 'ر.ي',
    this.unitLabel = 'كرت',
    this.sheetCapacity = 100,
    this.accentColor,
    this.accentColorHex,
    this.tagLabel,
    this.tagColor,
    this.cashDiscountPercent,
    this.creditDiscountPercent,
    this.isCustomDiscount = false,
    this.specifications = const [],
    this.paperEquivalentDescription,
    this.estimatedLineTotalMinor,
    this.estimatedLineTotal,
    this.isDiscountLoading = false,
    this.onDelete,
    this.trailingHeaderAction,
    this.showTariffPanel = true,
    this.showSpecificationStrip = true,
    this.showQuantityControls = true,
    this.showPaperEquivalent = true,
    this.showEstimatedTotal = true,
  });

  // الخصائص الأساسية للعنوان والتسعير
  final String title;
  final num basePrice;
  final num cashPrice;
  final num creditPrice;
  final int quantity;
  final ValueChanged<int> onSetQuantity;
  final TextEditingController quantityController;
  final bool isCashSale;

  // إعدادات المسميات والعملات لمرونة الاستخدام في أي نظام
  final String currency;
  final String unitLabel;
  final int sheetCapacity;

  // الهوية البصرية والألوان
  final Color? accentColor;
  final String? accentColorHex;
  final String? tagLabel;
  final Color? tagColor;

  // نسب الخصم والنوع
  final double? cashDiscountPercent;
  final double? creditDiscountPercent;
  final bool isCustomDiscount;

  // المواصفات والحسابات
  final List<PackageSpecificationItem> specifications;
  final String? paperEquivalentDescription;
  final int? estimatedLineTotalMinor;
  final num? estimatedLineTotal;
  final bool isDiscountLoading;

  // الإجراءات والتحكم بالأقسام
  final VoidCallback? onDelete;
  final Widget? trailingHeaderAction;
  final bool showTariffPanel;
  final bool showSpecificationStrip;
  final bool showQuantityControls;
  final bool showPaperEquivalent;
  final bool showEstimatedTotal;

  static const _emerald = Color(0xFF087B61);
  static const _deepEmerald = Color(0xFF064F43);

  double get _cashDiscount => cashDiscountPercent ?? 0;
  double get _creditDiscount => creditDiscountPercent ?? 0;

  String _money(num value) =>
      AmountFormatter.formatValue(value, decimalPlaces: 2);

  String _describePaper(int count, int capacity) {
    if (paperEquivalentDescription != null) return paperEquivalentDescription!;
    if (count <= 0) return 'لم تحدد كمية بعد';
    return VoucherSheetCalculator.describe(count, capacity);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final capacity = sheetCapacity > 0 ? sheetCapacity : 1;
    final halfCapacity = (capacity / 2).ceil();
    final selected = quantity > 0;
    final activeDiscount = isCashSale ? _cashDiscount : _creditDiscount;

    final resolvedAccent = accentColor ??
        (accentColorHex != null
            ? CustomColorPicker.parseHex(accentColorHex, fallback: colors.primary)
            : colors.primary);

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
            title: title,
            sheetCapacity: capacity,
            unitLabel: unitLabel,
            packageAccentColor: resolvedAccent,
            isCustomDiscount: isCustomDiscount,
            discount: activeDiscount,
            tagLabel: tagLabel,
            tagColor: tagColor,
            onDelete: onDelete,
            trailingHeaderAction: trailingHeaderAction,
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(11.r, 11.r, 11.r, 11.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (showTariffPanel) ...[
                  _TariffPanel(
                    basePrice: basePrice.toDouble(),
                    cashPrice: cashPrice.toDouble(),
                    creditPrice: creditPrice.toDouble(),
                    cashDiscount: _cashDiscount,
                    creditDiscount: _creditDiscount,
                    isCashSale: isCashSale,
                    isDiscountLoading: isDiscountLoading,
                    money: _money,
                    currency: currency,
                  ),
                  AppSpacing.vSm,
                ],
                if (showSpecificationStrip && specifications.isNotEmpty) ...[
                  _SpecificationStrip(specifications: specifications),
                  AppSpacing.vSm,
                ],
                if (showQuantityControls) ...[
                  _QuantityControls(
                    quantity: quantity,
                    controller: quantityController,
                    sheetCapacity: capacity,
                    halfCapacity: halfCapacity,
                    unitLabel: unitLabel,
                    onChanged: onSetQuantity,
                  ),
                  AppSpacing.vSm,
                ],
                if (showPaperEquivalent) ...[
                  _PaperEquivalent(
                    description: _describePaper(quantity, capacity),
                  ),
                  AppSpacing.vSm,
                ],
                if (showEstimatedTotal) ...[
                  _LineTotal(
                    estimatedLineTotal: estimatedLineTotal,
                    estimatedLineTotalMinor: estimatedLineTotalMinor,
                    currency: currency,
                    selected: selected,
                  ),
                ],
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
    required this.title,
    required this.sheetCapacity,
    required this.unitLabel,
    required this.packageAccentColor,
    required this.isCustomDiscount,
    required this.discount,
    this.tagLabel,
    this.tagColor,
    this.onDelete,
    this.trailingHeaderAction,
  });

  final String title;
  final int sheetCapacity;
  final String unitLabel;
  final Color packageAccentColor;
  final bool isCustomDiscount;
  final double discount;
  final String? tagLabel;
  final Color? tagColor;
  final VoidCallback? onDelete;
  final Widget? trailingHeaderAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final resolvedTag = tagLabel ??
        (isCustomDiscount
            ? 'خصم خاص'
            : discount > 0
                ? 'خصم افتراضي'
                : 'باقة الشبكة');

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 340.w;
        final artworkSize = compact ? 104.r : 124.r;
        return ConstrainedBox(
          constraints: BoxConstraints(minHeight: artworkSize),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(
                    compact ? 8.r : 12.r,
                    9.r,
                    8.r,
                    9.r,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: compact ? 7.r : 10.r,
                                vertical: 5.r,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerRight,
                                  end: Alignment.centerLeft,
                                  colors: tagColor != null
                                      ? [tagColor!, tagColor!.withValues(alpha: .75)]
                                      : const [
                                          Color(0xFF0BA777),
                                          Color(0xFF075C49),
                                        ],
                                ),
                                borderRadius: BorderRadius.circular(AppRadius.full),
                                boxShadow: [
                                  BoxShadow(
                                    color: CustomPackageOptionCard._emerald.withValues(alpha: .18),
                                    blurRadius: 9,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    isCustomDiscount
                                        ? Icons.storefront_rounded
                                        : Icons.auto_awesome_rounded,
                                    color: Colors.white,
                                    size: 14.r,
                                  ),
                                  AppSpacing.hXxs,
                                  Flexible(
                                    child: Text(
                                      resolvedTag,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTypography.labelSmall.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        height: 0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (trailingHeaderAction != null) ...[
                            AppSpacing.hXs,
                            trailingHeaderAction!,
                          ] else if (onDelete != null) ...[
                            AppSpacing.hXs,
                            CustomButton.icon(
                              icon: Icons.delete_outline_rounded,
                              tooltip: 'حذف الباقة',
                              dimension: 28.r,
                              size: AppButtonSize.small,
                              backgroundColor: colors.error.withValues(alpha: .12),
                              foregroundColor: colors.error,
                              onPressed: onDelete,
                            ),
                          ],
                        ],
                      ),
                      AppSpacing.vMd,
                      Row(
                        children: [
                          Container(
                            key: const ValueKey('procurement-package-color-accent'),
                            width: 4.r,
                            height: 18.r,
                            decoration: BoxDecoration(
                              color: packageAccentColor,
                              borderRadius: BorderRadius.circular(AppRadius.full),
                            ),
                          ),
                          AppSpacing.hXs,
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.start,
                              style: AppTypography.titleMedium.copyWith(
                                color: packageAccentColor,
                                fontWeight: FontWeight.w700,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.vSm,
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: constraints.maxWidth - artworkSize - 28.r,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 7.r,
                          vertical: 4.r,
                        ),
                        decoration: BoxDecoration(
                          color: packageAccentColor.withValues(alpha: .08),
                          borderRadius: BorderRadius.circular(AppRadius.chip),
                          border: Border.all(
                            color: packageAccentColor.withValues(alpha: .14),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.layers_rounded,
                              size: 13.r,
                              color: packageAccentColor,
                            ),
                            AppSpacing.hXxs,
                            Flexible(
                              child: Text(
                                'سعة الورقة: $sheetCapacity $unitLabel',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.labelSmall.copyWith(
                                  color: packageAccentColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: artworkSize,
                height: artworkSize,
                child: const _PackageArtwork(),
              ),
            ],
          ),
        );
      },
    );
  }
}

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
                  child: CustomPaint(
                    size: Size(61.r, 78.r),
                    painter: _VoucherTicketPainter(),
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

class _VoucherTicketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final ticketRect = Rect.fromLTWH(
      size.width * .06,
      size.height * .035,
      size.width * .88,
      size.height * .93,
    );
    final ticket = Path()
      ..addRRect(
        RRect.fromRectAndRadius(ticketRect, Radius.circular(size.width * .10)),
      );
    final perforationX = size.width * .72;
    final cutouts = Path()
      ..addOval(
        Rect.fromCircle(
          center: Offset(ticketRect.left, size.height * .53),
          radius: size.width * .075,
        ),
      )
      ..addOval(
        Rect.fromCircle(
          center: Offset(ticketRect.right, size.height * .53),
          radius: size.width * .075,
        ),
      );
    final ticketPath = Path.combine(PathOperation.difference, ticket, cutouts);

    canvas.drawShadow(
      ticketPath,
      const Color(0xFF001F18).withValues(alpha: .30),
      5,
      true,
    );
    canvas.drawPath(
      ticketPath,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFFFF), Color(0xFFE7F8F1), Color(0xFFB9E6D7)],
        ).createShader(ticketRect),
    );
    canvas.drawPath(
      ticketPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = const Color(0xFF087B61).withValues(alpha: .48),
    );

    final perforation = Paint()
      ..color = const Color(0xFF087B61).withValues(alpha: .58)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    for (
      var y = size.height * .18;
      y < size.height * .84;
      y += size.height * .09
    ) {
      canvas.drawLine(
        Offset(perforationX, y),
        Offset(perforationX, y + size.height * .035),
        perforation,
      );
    }

    final sealCenter = Offset(size.width * .37, size.height * .30);
    canvas.drawCircle(
      sealCenter,
      size.width * .115,
      Paint()..color = const Color(0xFFD8AA45),
    );
    canvas.drawCircle(
      sealCenter,
      size.width * .082,
      Paint()..color = const Color(0xFFFFF3C8),
    );
    final seal = Path()
      ..moveTo(sealCenter.dx, sealCenter.dy - size.width * .045)
      ..lineTo(
        sealCenter.dx + size.width * .012,
        sealCenter.dy - size.width * .012,
      )
      ..lineTo(sealCenter.dx + size.width * .047, sealCenter.dy)
      ..lineTo(
        sealCenter.dx + size.width * .012,
        sealCenter.dy + size.width * .012,
      )
      ..lineTo(sealCenter.dx, sealCenter.dy + size.width * .047)
      ..lineTo(
        sealCenter.dx - size.width * .012,
        sealCenter.dy + size.width * .012,
      )
      ..lineTo(sealCenter.dx - size.width * .047, sealCenter.dy)
      ..lineTo(
        sealCenter.dx - size.width * .012,
        sealCenter.dy - size.width * .012,
      )
      ..close();
    canvas.drawPath(seal, Paint()..color = const Color(0xFF98702B));

    final barcode = Paint()
      ..color = const Color(0xFF075C49)
      ..strokeCap = StrokeCap.square;
    final bars = <double>[.18, .22, .27, .31, .37, .41, .47, .53, .58, .63];
    for (var i = 0; i < bars.length; i++) {
      barcode.strokeWidth = i.isEven ? 1.8 : 1;
      final x = size.width * bars[i];
      canvas.drawLine(
        Offset(x, size.height * .62),
        Offset(x, size.height * (i % 3 == 0 ? .82 : .77)),
        barcode,
      );
    }

    final captionPaint = Paint()
      ..color = const Color(0xFF087B61).withValues(alpha: .65)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * .19, size.height * .48),
      Offset(size.width * .55, size.height * .48),
      captionPaint,
    );
    canvas.drawLine(
      Offset(size.width * .24, size.height * .54),
      Offset(size.width * .50, size.height * .54),
      captionPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
    required this.isDiscountLoading,
    required this.money,
    required this.currency,
  });

  final double basePrice;
  final double cashPrice;
  final double creditPrice;
  final double cashDiscount;
  final double creditDiscount;
  final bool isCashSale;
  final bool isDiscountLoading;
  final String Function(num) money;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.r, vertical: 8.r),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: .58)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.r, vertical: 6.r),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest.withValues(alpha: .26),
              borderRadius: BorderRadius.circular(AppRadius.chip),
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: .48),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.sell_outlined,
                  size: 13.r,
                  color: colors.onSurfaceVariant,
                ),
                AppSpacing.hXxs,
                Expanded(
                  child: Text(
                    'السعر الأساسي قبل الخصم',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${money(basePrice)} $currency',
                    textDirection: TextDirection.rtl,
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.onSurfaceVariant,
                      decoration: TextDecoration.lineThrough,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.vSm,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _PriceOptionCard(
                  key: const ValueKey('procurement-price-option-cash'),
                  selectedMarkerKey: const ValueKey(
                    'procurement-price-option-cash-selected',
                  ),
                  label: 'السعر النقدي',
                  price: cashPrice,
                  discount: cashDiscount,
                  money: money,
                  currency: currency,
                  selected: isCashSale,
                  isDiscountLoading: isDiscountLoading,
                ),
              ),
              AppSpacing.hXs,
              Expanded(
                child: _PriceOptionCard(
                  key: const ValueKey('procurement-price-option-credit'),
                  selectedMarkerKey: const ValueKey(
                    'procurement-price-option-credit-selected',
                  ),
                  label: 'السعر الآجل',
                  price: creditPrice,
                  discount: creditDiscount,
                  money: money,
                  currency: currency,
                  selected: !isCashSale,
                  isDiscountLoading: isDiscountLoading,
                  isSecond: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PriceOptionCard extends StatelessWidget {
  const _PriceOptionCard({
    super.key,
    required this.selectedMarkerKey,
    required this.label,
    required this.price,
    required this.discount,
    required this.money,
    required this.currency,
    required this.selected,
    required this.isDiscountLoading,
    this.isSecond = false,
  });

  final Key selectedMarkerKey;
  final String label;
  final double price;
  final double discount;
  final String Function(num) money;
  final String currency;
  final bool selected;
  final bool isSecond;
  final bool isDiscountLoading;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      label: label,
      selected: selected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 190),
        curve: Curves.easeOutCubic,
        padding: EdgeInsetsDirectional.fromSTEB(8.r, 8.r, 8.r, 7.r),
        decoration: BoxDecoration(
          color: selected
              ? colors.primary.withValues(alpha: .10)
              : colors.surface,
          borderRadius: !isSecond
              ? BorderRadiusDirectional.only(
                  topStart: Radius.circular(AppRadius.md),
                  bottomStart: Radius.circular(AppRadius.md),
                  topEnd: Radius.circular(AppRadius.xs),
                  bottomEnd: Radius.circular(AppRadius.xs),
                )
              : BorderRadiusDirectional.only(
                  topStart: Radius.circular(AppRadius.xs),
                  bottomStart: Radius.circular(AppRadius.xs),
                  topEnd: Radius.circular(AppRadius.md),
                  bottomEnd: Radius.circular(AppRadius.md),
                ),
          border: Border.all(
            color: selected
                ? colors.primary.withValues(alpha: .72)
                : colors.outlineVariant.withValues(alpha: .58),
            width: 1.25,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: colors.primary.withValues(alpha: .055),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : const [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelSmall.copyWith(
                      color: selected ? colors.primary : colors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                AppSpacing.hXxs,
                SizedBox(
                  width: 37.r,
                  height: 16.r,
                  child: Center(
                    child: selected
                        ? AnimatedOpacity(
                            duration: const Duration(milliseconds: 160),
                            opacity: 1,
                            child: Text(
                              'المحدد',
                              maxLines: 1,
                              style: AppTypography.labelSmall.copyWith(
                                color: colors.primary,
                                fontWeight: FontWeight.w800,
                                fontSize: 9.r,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
                AppSpacing.hXxs,
                SizedBox.square(
                  dimension: 19.r,
                  child: selected
                      ? AnimatedOpacity(
                          duration: const Duration(milliseconds: 160),
                          opacity: 1,
                          child: Tooltip(
                            message: 'نوع البيع المحدد',
                            child: Container(
                              key: selectedMarkerKey,
                              decoration: BoxDecoration(
                                color: colors.primary,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: colors.primary.withValues(
                                      alpha: .20,
                                    ),
                                    blurRadius: 5,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.check_rounded,
                                size: 13.r,
                                color: colors.onPrimary,
                              ),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
            AppSpacing.vXs,
            if (isDiscountLoading)
              const CustomStateView.loading(
                presentation: CustomStatePresentation.skeletonOnly,
                skeleton: CustomStateSkeleton(
                  layout: CustomStateSkeletonLayout.text,
                  lineCount: 2,
                  showCardSurface: false,
                ),
              )
            else if (discount > 0) ...{
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  '${money(price)} $currency',
                  textDirection: TextDirection.rtl,
                  maxLines: 1,
                  style: AppTypography.titleSmall.copyWith(
                    fontSize: 13.sp,
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
              ),
              AppSpacing.vXxs,
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 7.r, vertical: 3.r),
                  decoration: BoxDecoration(
                    color: colors.success.withValues(alpha: .09),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(
                      color: colors.success.withValues(alpha: .18),
                    ),
                  ),
                  child: Text(
                    'خصم ${discount.toStringAsFixed(2)}٪',
                    maxLines: 1,
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.success,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            } else
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  'حسب التعرفة',
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.onSurfaceVariant,
                    fontSize: 10.sp,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SpecificationStrip extends StatelessWidget {
  const _SpecificationStrip({required this.specifications});
  final List<PackageSpecificationItem> specifications;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.r, vertical: 10.r),
      decoration: BoxDecoration(
        color: CustomPackageOptionCard._emerald.withValues(alpha: .075),
        borderRadius: BorderRadius.circular(17.r),
      ),
      child: Row(
        children: [
          for (var i = 0; i < specifications.length; i++) ...[
            Expanded(
              child: _Specification(
                icon: specifications[i].icon,
                label: specifications[i].label,
                value: specifications[i].value,
              ),
            ),
            if (i < specifications.length - 1)
              _SpecificationDivider(color: colors.outlineVariant),
          ],
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
              fontWeight: FontWeight.w700,
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
  Widget build(BuildContext context) =>
      Container(width: 1, height: 49.r, color: color.withValues(alpha: .72));
}

class _QuantityControls extends StatelessWidget {
  const _QuantityControls({
    required this.quantity,
    required this.controller,
    required this.sheetCapacity,
    required this.halfCapacity,
    required this.unitLabel,
    required this.onChanged,
  });

  final int quantity;
  final TextEditingController controller;
  final int sheetCapacity;
  final int halfCapacity;
  final String unitLabel;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الكمية المطلوبة',
          style: AppTypography.labelMedium.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        AppSpacing.vSm,
        Row(
          children: [
            CustomButton.icon(
              icon: Icons.add_rounded,
              tooltip: 'إضافة $unitLabel',
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
                  textStyle: AppTypography.inputText.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w500,
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
              tooltip: 'إنقاص $unitLabel',
              dimension: 36.r,
              size: AppButtonSize.small,
              backgroundColor: colors.surfaceContainerLow,
              foregroundColor: colors.onSurfaceVariant,
              onPressed: quantity > 0 ? () => onChanged(quantity - 1) : null,
            ),
            AppSpacing.hXs,
            Text(
              unitLabel,
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
                text: 'ورقة',
                icon: Icons.note_add_outlined,
                size: AppButtonSize.small,
                foregroundColor: colors.onSurfaceVariant,
                borderColor: colors.outlineVariant,
                onPressed: () =>
                    onChanged((quantity + sheetCapacity).clamp(0, 1000000)),
              ),
            ),
            AppSpacing.hXs,
            Expanded(
              child: CustomButton.outline(
                text: 'نصف',
                icon: Icons.description_outlined,
                size: AppButtonSize.small,
                foregroundColor: colors.onSurfaceVariant,
                borderColor: colors.outlineVariant,
                onPressed: () =>
                    onChanged((quantity + halfCapacity).clamp(0, 1000000)),
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
  const _PaperEquivalent({required this.description});
  final String description;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 11.r, vertical: 10.r),
      decoration: BoxDecoration(
        color: CustomPackageOptionCard._emerald.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.card_giftcard_rounded, size: 19.r, color: colors.primary),
          AppSpacing.hXs,
          Flexible(
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: AppTypography.labelMedium.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LineTotal extends StatelessWidget {
  const _LineTotal({
    required this.estimatedLineTotal,
    required this.estimatedLineTotalMinor,
    required this.currency,
    required this.selected,
  });

  final num? estimatedLineTotal;
  final int? estimatedLineTotalMinor;
  final String currency;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    String? formattedTotal;
    if (estimatedLineTotal != null) {
      formattedTotal = AmountFormatter.formatValue(estimatedLineTotal!, decimalPlaces: 2);
    } else if (estimatedLineTotalMinor != null) {
      formattedTotal = AmountFormatter.format((estimatedLineTotalMinor! / 100).toStringAsFixed(2));
    }

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
            color: CustomPackageOptionCard._emerald.withValues(alpha: .20),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'إجمالي البند',
              style: AppTypography.labelMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (formattedTotal != null)
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '$formattedTotal $currency',
                  textDirection: TextDirection.rtl,
                  style: AppTypography.currencyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            )
          else
            Text(
              selected ? 'حدّث التعرفة' : '0.00',
              style: AppTypography.currencyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
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
