import 'package:flutter/material.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';

/// سطر محاسبي داخل قسيمة الفاتورة التقديرية الرسمية
class NetworkRequestVoucherFinancialRow extends StatelessWidget {
  const NetworkRequestVoucherFinancialRow({
    super.key,
    required this.label,
    required this.amount,
    this.isMuted = false,
    this.isDiscount = false,
  });

  final String label;
  final double amount;
  final bool isMuted;
  final bool isDiscount;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: isMuted ? colors.onSurfaceVariant : colors.onSurface,
              fontWeight: isMuted ? FontWeight.w500 : FontWeight.w600,
            ),
          ),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            '${isDiscount ? "- " : ""}${AmountFormatter.formatValue(amount)} ر.ي',
            textDirection: TextDirection.rtl,
            style: AppTypography.bodyMedium.copyWith(
              color: isDiscount
                  ? colors.tertiary
                  : isMuted
                  ? colors.onSurfaceVariant
                  : colors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
