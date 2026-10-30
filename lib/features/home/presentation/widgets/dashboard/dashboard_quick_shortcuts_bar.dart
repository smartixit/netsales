import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/home/domain/entities/dashboard_quick_action_entity.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// ============================================================================
/// منصة العمليات والإجراءات السريعة (DashboardQuickShortcutsBar)
/// ============================================================================
/// رصيف إجراءات تنفيذي مدمج يتيح للمشغل إصدار الفواتير وطلب الكروت
/// وإدارة الوكلاء والمحافظ بأسرع مسار نقر وبدون تعقيد.
class DashboardQuickShortcutsBar extends StatelessWidget {
  final List<DashboardQuickActionEntity> actions;

  const DashboardQuickShortcutsBar({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ترويسة الرصيف التنفيذي (محمية ومتجاوبة)
        Row(
          children: [
            Expanded(
              child: Text(
                'العمليات والإجراءات الميدانية',
                style: AppTypography.titleMedium.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        AppSpacing.vMd,
        SizedBox(
          height: 120.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            physics: const BouncingScrollPhysics(),
            clipBehavior: Clip.none,
            itemCount: actions.length,
            separatorBuilder: (context, i) => AppSpacing.hMd,
            itemBuilder: (context, i) {
              return _ActionCard(action: actions[i]);
            },
          ),
        ),
      ],
    );
  }
}

/// بطاقة إجراء تنفيذي رشيقة بهندسة عمودية تمنع اقتصاص النصوص
class _ActionCard extends StatelessWidget {
  final DashboardQuickActionEntity action;

  const _ActionCard({required this.action});

  @override
  Widget build(BuildContext context) {
    return CustomInteractiveBounce(
      onTap: action.onTap ?? () {},
      child: Container(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        width: min(120..w, 110),
        // height: 100.h,
        decoration: BoxDecoration(
          borderRadius: AppRadius.xlRadius,
          gradient: LinearGradient(
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
            colors: [action.gradientColors.first, action.gradientColors.last],
          ),
          boxShadow: [
            BoxShadow(
              color: action.gradientColors.first.withValues(alpha: 0.38),
              blurRadius: 18,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: -14.h,
              right: -14.w,
              child: Container(
                width: min(70.w, 77),
                height: min(70.w, 77),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.lightColors.surface.withValues(alpha: 0.10),
                ),
              ),
            ),

            Positioned(
              bottom: -10.h,
              left: -10.w,
              child: Container(
                width: min(44.w, 48),
                height: min(44.w, 48),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.lightColors.surface.withValues(alpha: 0.06),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: min(14.w, 15),
                vertical: 14.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: min(44.w, 48),
                    height: min(44.w, 48),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.lightColors.surface.withValues(
                        alpha: 0.22,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        action.icon,
                        color: Colors.white,
                        size: 22.sp,
                      ),
                    ),
                  ),

                  Text(
                    action.label,
                    style: AppTypography.bodySmall.copyWith(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.3,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
