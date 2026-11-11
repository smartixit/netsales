import 'package:flutter/material.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';

/// سطر معلومات الفاتورة (Invoice Info Row)
class InvoiceInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlight;

  const InvoiceInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: AppTypography.bodySmall.copyWith(
              color: isHighlight ? colors.primary : colors.onSurface,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

