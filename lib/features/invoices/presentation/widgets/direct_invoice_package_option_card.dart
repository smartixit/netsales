import 'package:flutter/material.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/core/utils/voucher_sheet_calculator.dart';
import 'package:netsales/features/catalog/domain/entities/effective_package_discount_entity.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/features/requests/domain/entities/procurement_quote_line_entity.dart';
import 'package:netsales/widgets/cards/custom_package_tariff_card.dart';
import 'package:netsales/widgets/pickers/custom_color_picker.dart';

/// بطاقة باقة الفاتورة المباشرة: تربط كيان الباقة [PackageEntity] بالويدجيت السيادية العامة [CustomPackageTariffCard].
/// مطابقة كلياً وبنيوياً لبطاقة [ProcurementPackageOptionCard] في وحدة الطلبات.
class DirectInvoicePackageOptionCard extends StatelessWidget {
  const DirectInvoicePackageOptionCard({
    super.key,
    required this.package,
    required this.quantity,
    required this.onSetQuantity,
    required this.isCashSale,
    required this.quantityController,
    this.customDiscount,
    this.quoteLine,
    this.estimatedLineTotalMinor,
    this.estimatedLineTotal,
    this.isDiscountLoading = false,
    this.onDelete,
    this.trailingHeaderAction,
    this.customHeaderTag,
    this.customHeaderTagColor,
  });

  final PackageEntity package;
  final int quantity;
  final ValueChanged<int> onSetQuantity;
  final bool isCashSale;
  final TextEditingController quantityController;
  final EffectivePackageDiscountEntity? customDiscount;
  final ProcurementQuoteLineEntity? quoteLine;
  final int? estimatedLineTotalMinor;
  final num? estimatedLineTotal;
  final bool isDiscountLoading;
  final VoidCallback? onDelete;
  final Widget? trailingHeaderAction;
  final String? customHeaderTag;
  final Color? customHeaderTagColor;

  double get _basePrice =>
      customDiscount?.originalPackagePrice ?? package.packageVoucherPrice;

  double get _cashPrice =>
      customDiscount?.effectiveCashPrice ?? package.effectiveCashPrice;

  double get _creditPrice =>
      customDiscount?.effectiveCreditPrice ?? package.effectiveCreditPrice;

  double get _cashDiscount =>
      customDiscount?.discountCash ?? package.cashDiscountAmount;

  double get _creditDiscount =>
      customDiscount?.discountCredit ?? package.creditDiscountAmount;

  String? get _formattedLineTotal {
    if (estimatedLineTotal != null) {
      return AmountFormatter.formatValue(estimatedLineTotal!, decimalPlaces: 2);
    }
    if (estimatedLineTotalMinor != null) {
      return AmountFormatter.format(
        (estimatedLineTotalMinor! / 100).toStringAsFixed(2),
      );
    }
    if (quoteLine != null &&
        quantity > 0 &&
        quoteLine!.voucherCount == quantity) {
      return AmountFormatter.formatValue(
        quoteLine!.lineNetTotal,
        decimalPlaces: 2,
      );
    }
    if (quantity > 0) {
      final unitPrice = isCashSale ? _cashPrice : _creditPrice;
      return AmountFormatter.formatValue(
        unitPrice * quantity,
        decimalPlaces: 2,
      );
    }
    return null;
  }

  String _describePaper(int count, int capacity) {
    if (count <= 0) return 'لم تحدد كمية بعد';
    return VoucherSheetCalculator.describe(count, capacity);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final capacity = package.packageVoucherCount > 0
        ? package.packageVoucherCount
        : 1;

    final resolvedAccent = package.packageColor != null
        ? CustomColorPicker.parseHex(
            package.packageColor!,
            fallback: colors.primary,
          )
        : colors.primary;

    final activeDiscount = isCashSale ? _cashDiscount : _creditDiscount;
    final resolvedTag =
        customHeaderTag ??
        (package.procurementIsCustomDiscount
            ? 'خصم خاص'
            : activeDiscount > 0
            ? 'خصم افتراضي'
            : 'باقة الشبكة');

    final specs = <PackageTariffSpecificationItem>[
      PackageTariffSpecificationItem(
        icon: Icons.data_usage_rounded,
        label: 'الرصيد',
        value: package.balanceParts.displayText,
      ),
      PackageTariffSpecificationItem(
        icon: Icons.access_time_rounded,
        label: 'الصلاحية',
        value: package.validityDisplay,
      ),
      PackageTariffSpecificationItem(
        icon: Icons.bolt_rounded,
        label: 'المدة',
        value: package.uptimeDisplay,
      ),
    ];

    return CustomPackageTariffCard(
      title: package.packageName,
      sheetCapacity: capacity,
      accentColor: resolvedAccent,
      basePrice: _basePrice,
      cashPrice: _cashPrice,
      creditPrice: _creditPrice,
      cashDiscount: _cashDiscount,
      creditDiscount: _creditDiscount,
      isCashSale: isCashSale,
      quantity: quantity,
      quantityController: quantityController,
      onQuantityChanged: onSetQuantity,
      paperEquivalentDescription: _describePaper(quantity, capacity),
      formattedLineTotal: _formattedLineTotal,
      tagLabel: resolvedTag,
      tagColor: customHeaderTagColor,
      isDiscountLoading: isDiscountLoading,
      specifications: specs,
      onDelete: onDelete,
      trailingHeaderAction: trailingHeaderAction,
    );
  }
}
