import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';

/// رأس قسم موحد للاستخدام في شاشة نموذج الباقة (عنوان مع أيقونة)
class PackageFormSectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const PackageFormSectionHeader({
    super.key,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        Icon(icon, size: AppSpacing.lg, color: colors.primary),
        AppSpacing.hXs,
        Text(
          title,
          style: AppTypography.titleSmall.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
