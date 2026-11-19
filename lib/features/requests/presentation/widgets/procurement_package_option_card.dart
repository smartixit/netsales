import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/core/utils/voucher_sheet_calculator.dart';
import 'package:netsales/features/catalog/domain/entities/effective_package_discount_entity.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/features/requests/domain/entities/procurement_quote_line_entity.dart';
import 'package:netsales/features/requests/presentation/widgets/package_option_card/procurement_package_hero.dart';
import 'package:netsales/features/requests/presentation/widgets/package_option_card/procurement_package_line_total.dart';
import 'package:netsales/features/requests/presentation/widgets/package_option_card/procurement_package_paper_equivalent.dart';
import 'package:netsales/features/requests/presentation/widgets/package_option_card/procurement_package_quantity_controls.dart';
import 'package:netsales/features/requests/presentation/widgets/package_option_card/procurement_package_specification_item.dart';
import 'package:netsales/features/requests/presentation/widgets/package_option_card/procurement_package_specification_strip.dart';
import 'package:netsales/features/requests/presentation/widgets/package_option_card/procurement_package_tariff_panel.dart';
import 'package:netsales/widgets/pickers/custom_color_picker.dart';

/// بطاقة باقة التوريد لعرض تفاصيل الأسعار، المواصفات، والتحكم بالكميات
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
    if (quoteLine != null &&
        quantity > 0 &&
        quoteLine!.voucherCount == quantity) {
      return quoteLine!.lineNetTotal;
    }
    return null;
  }

  String _money(num value) =>
      AmountFormatter.formatValue(value, decimalPlaces: 2);

  String _describePaper(int count, int capacity) {
    if (count <= 0) return 'لم تحدد كمية بعد';
    return VoucherSheetCalculator.describe(count, capacity);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final capacity =
        package.packageVoucherCount > 0 ? package.packageVoucherCount : 1;
    final halfCapacity = (capacity / 2).ceil();
    final selected = quantity > 0;
    final activeDiscount = isCashSale ? _cashDiscount : _creditDiscount;

    final resolvedAccent = package.packageColor != null
        ? CustomColorPicker.parseHex(
            package.packageColor!,
            fallback: colors.primary,
          )
        : colors.primary;

    final specs = <ProcurementPackageSpecificationItem>[
      ProcurementPackageSpecificationItem(
        icon: Icons.data_usage_rounded,
        label: 'الرصيد',
        value: package.balanceDisplay,
      ),
      ProcurementPackageSpecificationItem(
        icon: Icons.access_time_rounded,
        label: 'الصلاحية',
        value: package.validityDisplay,
      ),
      ProcurementPackageSpecificationItem(
        icon: Icons.bolt_rounded,
        label: 'المدة',
        value: package.uptimeDisplay,
      ),
    ];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 190),
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: selected
              ? colors.emeraldDark.withValues(alpha: .46)
              : colors.outlineVariant.withValues(alpha: .72),
          width: selected ? 1.35 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.emeraldDeep.withValues(alpha: selected ? .105 : .045),
            blurRadius: selected ? 21 : 15,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProcurementPackageHero(
            title: package.packageName,
            sheetCapacity: capacity,
            unitLabel: 'كرت',
            packageAccentColor: resolvedAccent,
            isCustomDiscount: package.procurementIsCustomDiscount,
            discount: activeDiscount,
            tagLabel: customHeaderTag,
            tagColor: customHeaderTagColor,
            onDelete: onDelete,
            trailingHeaderAction: trailingHeaderAction,
          ),
          Padding(
            padding: EdgeInsets.all(11.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ProcurementPackageTariffPanel(
                  basePrice: _basePrice,
                  cashPrice: _cashPrice,
                  creditPrice: _creditPrice,
                  cashDiscount: _cashDiscount,
                  creditDiscount: _creditDiscount,
                  isCashSale: isCashSale,
                  isDiscountLoading: isDiscountLoading,
                  money: _money,
                  currency: 'ر.ي',
                ),
                SizedBox(height: 8.h),
                ProcurementPackageSpecificationStrip(specifications: specs),
                SizedBox(height: 8.h),
                ProcurementPackageQuantityControls(
                  quantity: quantity,
                  controller: quantityController,
                  sheetCapacity: capacity,
                  halfCapacity: halfCapacity,
                  unitLabel: 'كرت',
                  onChanged: onSetQuantity,
                ),
                SizedBox(height: 8.h),
                ProcurementPackagePaperEquivalent(
                  description: _describePaper(quantity, capacity),
                ),
                SizedBox(height: 8.h),
                ProcurementPackageLineTotal(
                  estimatedLineTotal: _lineTotal,
                  estimatedLineTotalMinor: estimatedLineTotalMinor,
                  currency: 'ر.ي',
                  selected: selected,
                  unitPrice: isCashSale ? _cashPrice : _creditPrice,
                  quantity: quantity,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
