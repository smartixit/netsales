import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_gradients.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

/// Rich page hero following the layered visual language of procurement package cards.
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
        AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        gradient: AppGradients.financialHero(context),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: colors.onPrimary.withValues(alpha: .16)),
        boxShadow: AppElevation.tinted(
          context,
          colors.primary,
          alpha: .18,
          blur: 20,
          dy: 7,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          PositionedDirectional(
            top: -34.r,
            end: -12.r,
            child: Container(
              width: 126.r,
              height: 126.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.onPrimary.withValues(alpha: .07),
                  width: 18.r,
                ),
              ),
            ),
          ),
          PositionedDirectional(
            bottom: -46.r,
            start: 62.r,
            child: Container(
              width: 110.r,
              height: 110.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.onPrimary.withValues(alpha: .035),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.r, 15.r, 16.r, 13.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'الطلبات',
                            maxLines: 1,
                            style: AppTypography.headlineSmall.copyWith(
                              color: colors.onPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          AppSpacing.vXxs,
                          Text(
                            'إدارة طلبات التوريد ومتابعة حالتها',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodySmall.copyWith(
                              color: colors.onPrimary.withValues(alpha: .82),
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppSpacing.hSm,
                    Container(
                      width: 58.r,
                      height: 58.r,
                      decoration: BoxDecoration(
                        gradient: AppGradients.accentBadge(context, colors.onPrimary),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colors.onPrimary.withValues(alpha: .20),
                        ),
                        boxShadow: AppElevation.level2(context),
                      ),
                      child: Icon(
                        Icons.receipt_long_rounded,
                        color: colors.onPrimary,
                        size: 29.r,
                      ),
                    ),
                  ],
                ),
                if (canCreate) ...[
                  AppSpacing.vSm,
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: CustomButton.primary(
                      text: 'طلب جديد',
                      icon: Icons.add_rounded,
                      width: 126.w,
                      height: 42.h,
                      size: AppButtonSize.small,
                      shape: AppButtonShape.pill,
                      gradient: AppGradients.surfaceMesh(context),
                      foregroundColor: colors.primary,
                      shadow: AppElevation.level2(context),
                      onPressed: onCreate,
                    ),
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
