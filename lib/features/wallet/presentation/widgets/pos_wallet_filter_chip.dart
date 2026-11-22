import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// رقاقة تصفية تفاعلية لدفتر أستاذ المحفظة (PosWalletFilterChip)
class PosWalletFilterChip extends StatelessWidget {
  const PosWalletFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
    this.accentColor,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final effectiveColor = accentColor ?? colors.primary;
    final bg = isSelected
        ? effectiveColor.withValues(alpha: 0.16)
        : colors.surfaceContainerHighest.withValues(alpha: 0.40);
    final border = isSelected
        ? effectiveColor
        : colors.outlineVariant.withValues(alpha: 0.35);
    final textColor = isSelected ? effectiveColor : colors.onSurface;

    return CustomInteractiveBounce(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(color: border, width: isSelected ? 1.2 : 0.8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 13.r, color: textColor),
              SizedBox(width: AppSpacing.xxs),
            ],
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: textColor,
                fontWeight: isSelected
                    ? AppTypography.bold
                    : AppTypography.medium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
