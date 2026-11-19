export 'package:netsales/widgets/cards/custom_package_option_card.dart';

import 'package:flutter/material.dart';
import 'package:netsales/features/catalog/domain/entities/effective_package_discount_entity.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/features/requests/domain/entities/procurement_quote_line_entity.dart';
import 'package:netsales/widgets/cards/custom_package_option_card.dart';

/// محول بطاقة الباقة لربط كيان الباقة (PackageEntity) بالمكوّن العام المستقل (CustomPackageOptionCard).
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
      customDiscount?.originalPackagePrice ?? package.resolvedBasePrice;

  double get _cashPrice =>
      customDiscount?.effectiveCashPrice ?? package.resolvedCashPrice;

  double get _creditPrice =>
      customDiscount?.effectiveCreditPrice ?? package.resolvedCreditPrice;

  double get _cashDiscount =>
      customDiscount?.discountCash ?? package.resolvedCashDiscount;

  double get _creditDiscount =>
      customDiscount?.discountCredit ?? package.resolvedCreditDiscount;

  num? get _lineTotal {
    if (estimatedLineTotal != null) return estimatedLineTotal;
    if (quoteLine != null && quantity > 0 && quoteLine!.voucherCount == quantity) {
      return quoteLine!.lineNetTotal;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final specs = <PackageSpecificationItem>[
      PackageSpecificationItem(
        icon: Icons.data_usage_rounded,
        label: 'الرصيد',
        value: package.balanceDisplay,
      ),
      PackageSpecificationItem(
        icon: Icons.access_time_rounded,
        label: 'الصلاحية',
        value: package.validityDisplay,
      ),
      PackageSpecificationItem(
        icon: Icons.bolt_rounded,
        label: 'المدة',
        value: package.uptimeDisplay,
      ),
    ];

    return CustomPackageOptionCard(
      title: package.packageName,
      basePrice: _basePrice,
      cashPrice: _cashPrice,
      creditPrice: _creditPrice,
      quantity: quantity,
      onSetQuantity: onSetQuantity,
      quantityController: quantityController,
      isCashSale: isCashSale,
      sheetCapacity: package.packageVoucherCount > 0 ? package.packageVoucherCount : 1,
      accentColorHex: package.packageColor,
      isCustomDiscount: package.procurementIsCustomDiscount,
      cashDiscountPercent: _cashDiscount,
      creditDiscountPercent: _creditDiscount,
      specifications: specs,
      estimatedLineTotalMinor: estimatedLineTotalMinor,
      estimatedLineTotal: _lineTotal,
      isDiscountLoading: isDiscountLoading,
      onDelete: onDelete,
      trailingHeaderAction: trailingHeaderAction,
      tagLabel: customHeaderTag,
      tagColor: customHeaderTagColor,
    );
  }
}
