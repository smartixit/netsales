import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
        gradient: AppGradients.entityAmethyst(context),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppElevation.level3(context),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الطلبات',
                  style: AppTypography.headlineSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                AppSpacing.vXxs,
                Text(
                  'إدارة طلبات التوريد ومتابعة حالتها',
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.82),
                  ),
                ),
                if (canCreate) ...[
                  AppSpacing.vMd,
                  CustomButton(
                    text: 'طلب جديد',
                    icon: Icons.add_rounded,
                    size: AppButtonSize.medium,
                    shape: AppButtonShape.pill,
                    foregroundColor: colors.primary,
                    backgroundColor: Colors.white,
                    shadow: AppElevation.level2(context),
                    onPressed: onCreate,
                  ),
                ],
              ],
            ),
          ),
          AppSpacing.hSm,
          Container(
            width: 58.r,
            height: 58.r,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              color: Colors.white,
              size: 30.r,
            ),
          ),
          if (embedded) ...[
            AppSpacing.hXs,
            CustomButton.icon(
              icon: Icons.refresh_rounded,
              tooltip: 'تحديث الطلبات',
              foregroundColor: Colors.white,
              backgroundColor: Colors.white.withValues(alpha: 0.12),
              onPressed: onRefresh,
            ),
          ],
        ],
      ),
    );
  }
}
