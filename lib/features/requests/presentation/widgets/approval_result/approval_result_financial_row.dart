import 'package:flutter/material.dart';
import 'package:netsales/core/presentation/enums/semantic_tone.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';

class ApprovalResultFinancialRow extends StatelessWidget {
  const ApprovalResultFinancialRow({
    super.key,
    required this.label,
    required this.value,
    this.isEmphasized = false,
    this.toneColor,
    this.badgeTone,
  });

  final String label;
  final String value;
  final bool isEmphasized;
  final Color? toneColor;
  final SemanticTone? badgeTone;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: isEmphasized ? colors.onSurface : colors.onSurfaceVariant,
              fontWeight: isEmphasized ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
        if (badgeTone != null)
          CustomStatusBadge(
            label: value,
            tone: badgeTone!,
            isCompact: true,
          )
        else
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label == 'نوع البيع' ? value : '$value ر.ي',
              textDirection: TextDirection.rtl,
              style: (isEmphasized
                      ? AppTypography.titleSmall
                      : AppTypography.bodyMedium)
                  .copyWith(
                color: toneColor ?? (isEmphasized ? colors.primary : colors.onSurface),
                fontWeight: isEmphasized ? FontWeight.w900 : FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}
