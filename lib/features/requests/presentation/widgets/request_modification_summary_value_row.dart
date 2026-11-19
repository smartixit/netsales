import 'package:flutter/material.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';

class RequestModificationSummaryValueRow extends StatelessWidget {
  const RequestModificationSummaryValueRow({
    super.key,
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          value,
          style:
              (emphasize ? AppTypography.titleSmall : AppTypography.bodyMedium)
                  .copyWith(
                    color: emphasize ? colors.primary : colors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
        ),
      ],
    );
  }
}
