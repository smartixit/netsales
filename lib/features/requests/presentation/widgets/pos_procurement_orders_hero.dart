import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_gradients.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

/// Compact orders hero using the same layered, emerald visual language as
/// procurement package cards without duplicating the workspace app bar.
class PosProcurementOrdersHero extends StatelessWidget {
  const PosProcurementOrdersHero({
    super.key,
    required this.onCreate,
    required this.canCreate,
    this.embedded = false,
  });

  final VoidCallback onCreate;
  final bool canCreate;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: EdgeInsets.fromLTRB(
        AppSpacing.cardPadding,
        embedded ? AppSpacing.xs : AppSpacing.md,
        AppSpacing.cardPadding,
        AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        gradient: AppGradients.financialHero(context),
        borderRadius: AppRadius.xxlRadius,
        border: Border.all(
          color: colors.onPrimary.withValues(alpha: .16),
        ),
        boxShadow: AppElevation.tinted(
          context,
          colors.primary,
          alpha: .16,
          blur: 18,
          dy: 6,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          PositionedDirectional(
            top: -42.r,
            end: 66.r,
            child: Container(
              width: 118.r,
              height: 118.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.onPrimary.withValues(alpha: .075),
                  width: 16.r,
                ),
              ),
            ),
          ),
          PositionedDirectional(
            bottom: -50.r,
            start: -20.r,
            child: Container(
              width: 112.r,
              height: 112.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.onPrimary.withValues(alpha: .045),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
              14.r,
              embedded ? 11.r : 13.r,
              14.r,
              canCreate ? 11.r : 12.r,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 48.r,
                  height: 48.r,
                  decoration: BoxDecoration(
                    color: colors.onPrimary.withValues(alpha: .13),
                    borderRadius: BorderRadius.circular(17.r),
                    border: Border.all(
                      color: colors.onPrimary.withValues(alpha: .22),
                    ),
                    boxShadow: AppElevation.level2(context),
                  ),
                  child: Icon(
                    Icons.receipt_long_rounded,
                    color: colors.onPrimary,
                    size: 25.r,
                  ),
                ),
                AppSpacing.hSm,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'الطلبات',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.titleLarge.copyWith(
                          color: colors.onPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      AppSpacing.vXxs,
                      Text(
                        'إدارة طلبات التوريد ومتابعة حالتها',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.caption.copyWith(
                          color: colors.onPrimary.withValues(alpha: .82),
                        ),
                      ),
                    ],
                  ),
                ),
                if (canCreate) ...[
                  AppSpacing.hSm,
                  CustomButton.primary(
                    text: 'طلب جديد',
                    icon: Icons.add_rounded,
                    iconPosition: AppButtonIconPosition.end,
                    width: 116.w,
                    height: 40.h,
                    size: AppButtonSize.small,
                    shape: AppButtonShape.pill,
                    gradient: AppGradients.surfaceMesh(context),
                    foregroundColor: colors.primary,
                    shadow: AppElevation.level2(context),
                    onPressed: onCreate,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
