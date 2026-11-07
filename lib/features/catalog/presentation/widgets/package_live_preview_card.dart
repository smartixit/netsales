import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';

/// بطاقة التنبيه بسلطة الخادم الحصرية للحسابات والخصومات التعاقدية (AGENTS.md §3)
class PackageLivePreviewCard extends StatelessWidget {
  const PackageLivePreviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colors.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.verified_user_outlined,
            size: AppSpacing.lg,
            color: colors.primary,
          ),
          AppSpacing.hSm,
          Expanded(
            child: Text(
              'تعتمد كافة الأسعار الصافية والخصومات التعاقدية بصورة حصرية وموثقة على خادم النظام المالي.',
              style: AppTypography.bodySmall.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
