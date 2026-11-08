import 'package:flutter/material.dart';
import 'package:characters/characters.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/workspace/presentation/controllers/pos_workspace_controller.dart';

class PosWelcomeHeader extends StatelessWidget {
  const PosWelcomeHeader({super.key, required this.controller});
  final PosWorkspaceController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final user = controller.userName;
    final initial = user.isNotEmpty ? user.characters.first : 'م';
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [colors.primary, colors.secondary],
        ),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.18),
            blurRadius: 24.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: -18.w,
            top: -26.h,
            child: Container(
              width: 112.r,
              height: 112.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.onPrimary.withValues(alpha: 0.10),
                  width: 18.r,
                ),
              ),
            ),
          ),
          Row(
            children: [
              Container(
                width: 52.r,
                height: 52.r,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.onPrimary.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colors.onPrimary.withValues(alpha: 0.28),
                  ),
                ),
                child: Text(
                  initial,
                  style: AppTypography.titleLarge.copyWith(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              AppSpacing.hMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.welcomePeriod,
                      style: AppTypography.bodySmall.copyWith(
                        color: colors.onPrimary.withValues(alpha: 0.82),
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      user,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.titleLarge.copyWith(
                        color: colors.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      'إدارة مشترياتك وحساباتك لدى الشبكات من مكان واحد',
                      maxLines: 2,
                      style: AppTypography.bodySmall.copyWith(
                        color: colors.onPrimary.withValues(alpha: 0.86),
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.waving_hand_rounded,
                color: colors.onPrimary.withValues(alpha: 0.92),
                size: 25.r,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
