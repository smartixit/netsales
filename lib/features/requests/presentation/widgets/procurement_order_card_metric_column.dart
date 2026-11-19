import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';

class ProcurementOrderCardMetricColumn extends StatelessWidget {
  const ProcurementOrderCardMetricColumn({
    super.key,
    required this.label,
    required this.value,
    required this.textColor,
    this.isEmphasized = false,
  });

  final String label;
  final String value;
  final Color textColor;
  final bool isEmphasized;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.caption.copyWith(
            color: colors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        AppSpacing.vXxs,
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: isEmphasized
                ? AppTypography.titleMedium.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.2,
                  )
                : AppTypography.titleSmall.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w800,
                  ),
          ),
        ),
      ],
    );
  }
}
