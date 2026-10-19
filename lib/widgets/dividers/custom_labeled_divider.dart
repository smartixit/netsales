import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';

/// خط فاصل أفقي موحد يتوسطه نص أو شارة دلالية (CustomLabeledDivider)
/// يُستخدم في شاشات الترحيب، تسجيل الدخول، إنشاء الحساب، والبطاقات المنقسمة.
class CustomLabeledDivider extends StatelessWidget {
  const CustomLabeledDivider({
    super.key,
    required this.label,
    this.thickness = 1.0,
    this.padding,
  });

  /// النص التوضيحي الذي يتوسط الفاصل
  final String label;

  /// سمك خط الفاصل
  final double thickness;

  /// الحشو الخارجي للفاصل
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: padding ?? EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: colors.outlineVariant.withValues(alpha: 0.45),
              thickness: thickness,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: colors.outlineVariant.withValues(alpha: 0.45),
              thickness: thickness,
            ),
          ),
        ],
      ),
    );
  }
}
