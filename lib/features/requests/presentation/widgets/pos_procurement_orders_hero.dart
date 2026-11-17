import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_gradients.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

class PosProcurementOrdersHero extends StatelessWidget {
  const PosProcurementOrdersHero({
    super.key,
    required this.onCreate,
    required this.onRefresh,
    required this.canCreate,
    this.embedded = false,
  });

  final VoidCallback onCreate;
  final VoidCallback onRefresh;
  final bool canCreate;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      margin: EdgeInsets.fromLTRB(
        AppSpacing.cardPadding,
        embedded ? AppSpacing.sm : AppSpacing.md,
        AppSpacing.cardPadding,
        AppSpacing.sm,
      ),
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: AppGradients.surfaceMesh(context),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.34)),
        boxShadow: AppElevation.level1(context),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الطلبات',
                  style: AppTypography.headlineSmall.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                AppSpacing.vXxs,
                Text(
                  'إدارة طلبات التوريد ومتابعة حالتها',
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (canCreate)
            CustomButton.primary(
              text: 'طلب جديد',
              icon: Icons.add_rounded,
              size: AppButtonSize.medium,
              shape: AppButtonShape.pill,
              gradient: AppGradients.entityAmethyst(context),
              foregroundColor: Colors.white,
              shadow: AppElevation.level2(context),
              onPressed: onCreate,
            ),
          if (embedded) ...[
            AppSpacing.hXs,
            CustomButton.icon(
              icon: Icons.refresh_rounded,
              tooltip: 'تحديث الطلبات',
              foregroundColor: colors.onSurfaceVariant,
              backgroundColor: colors.surfaceContainerHighest,
              onPressed: onRefresh,
            ),
          ],
        ],
      ),
    );
  }
}
