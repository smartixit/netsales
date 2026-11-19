import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';

/// بطاقة إجمالي البند للباقة
class ProcurementPackageLineTotal extends StatelessWidget {
  const ProcurementPackageLineTotal({
    super.key,
    required this.estimatedLineTotal,
    required this.estimatedLineTotalMinor,
    required this.currency,
    required this.selected,
    this.unitPrice,
    this.quantity = 0,
  });

  final num? estimatedLineTotal;
  final int? estimatedLineTotalMinor;
  final String currency;
  final bool selected;
  final num? unitPrice;
  final int quantity;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    String? formattedTotal;
    if (estimatedLineTotal != null) {
      formattedTotal = AmountFormatter.formatValue(
        estimatedLineTotal!,
        decimalPlaces: 2,
      );
    } else if (estimatedLineTotalMinor != null) {
      formattedTotal = AmountFormatter.format(
        (estimatedLineTotalMinor! / 100).toStringAsFixed(2),
      );
    } else if (selected &&
        unitPrice != null &&
        unitPrice! > 0 &&
        quantity > 0) {
      formattedTotal = AmountFormatter.formatValue(
        unitPrice! * quantity,
        decimalPlaces: 2,
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.r, vertical: 14.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [
            colors.emeraldDark,
            colors.emeraldDeep,
          ],
        ),
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: colors.emeraldDark.withValues(alpha: .20),
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
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                '${formattedTotal ?? "0.00"} $currency',
                textDirection: TextDirection.rtl,
                style: AppTypography.currencyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
