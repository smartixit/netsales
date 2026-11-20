import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';

/// عنوان القسم الموحد للنماذج والصفحات (CustomSectionHeading)
///
/// المرجع الموحد لترويسة الأقسام في النماذج وصفحات الاختيار:
/// - دعم الأيقونة الدلالية مع لون الهوية المعتمد.
/// - عنوان رئيسي مع خط عريض ونصف شفاف للعنوان الفرعي التوضيحي.
/// - دعم عنصر إضافي اختياري في الجهة المقابلة (trailing).
class CustomSectionHeading extends StatelessWidget {
  const CustomSectionHeading({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18.r, color: colors.primary),
              SizedBox(width: 6.w),
            ],
            Expanded(
              child: Text(
                title,
                style: AppTypography.titleSmall.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w800,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            ?trailing,
          ],
        ),
        if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
          AppSpacing.vXxs,
          Text(
            subtitle!.trim(),
            style: AppTypography.bodySmall.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
