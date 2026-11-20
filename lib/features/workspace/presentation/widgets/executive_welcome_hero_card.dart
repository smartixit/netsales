import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/workspace/presentation/controllers/network_workspace_controller.dart';
import 'package:netsales/widgets/images/custom_avatar_badge.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// كرت الترحيب القيادي التنفيذي المتجاوب (ExecutiveWelcomeHeroCard)
/// يعرض هوية المشغل وحالة الاتصال والكبسولات السريعة دون أي أخطاء تجاوز أو اقتطاع
class ExecutiveWelcomeHeroCard extends StatelessWidget {
  final NetworkWorkspaceController controller;
  final VoidCallback onPendingTap;

  const ExecutiveWelcomeHeroCard({
    super.key,
    required this.controller,
    required this.onPendingTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final greeting = controller.welcomeGreeting;
    final pendingCount = controller.pendingRequestsCount;
    final hasPendingMetric = pendingCount != null;
    final hasPendingRequests = pendingCount != null && pendingCount > 0;
    final realFullName = controller.userName;
    final realRole = controller.userRole;
    final initials = controller.userInitials;
    final todayStr = controller.todayFormatted;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? colors.surfaceContainerLow : colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: isDark
              ? colors.onSurface.withValues(alpha: 0.08)
              : colors.outlineVariant.withValues(alpha: 0.7),
          width: 1,
        ),
        boxShadow: AppElevation.level2(context),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. هوية المشغل والأفاتار التنفيذي
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // الأفاتار مع مؤشر النبض الحي الموحد
              CustomAvatarBadge(
                imageUrl: controller.userProfileLogo,
                initials: initials,
                size: AvatarBadgeSize.md,
                pulseColor: colors.primary,
              ),
              SizedBox(width: AppSpacing.md),

              // الاسم والرتبة ومساحة العمل
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          greeting,
                          style: AppTypography.labelSmall.copyWith(
                            color: colors.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                                                      ),
                        ),
                        Container(
                          width: 3.5,
                          height: 3.5,
                          margin: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colors.outline,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 5.w,
                            vertical: AppSpacing.xxs,
                          ),
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: Text(
                            'جلسة نشطة',
                            style: AppTypography.labelSmall.copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.w700,
                                                          ),
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.vXxs,
                    Text(
                      realFullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.titleMedium.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w900,
                                                letterSpacing: -0.2,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            realRole,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodySmall.copyWith(
                              color: colors.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                                                          ),
                          ),
                        ),
                        Container(
                          width: 3,
                          height: 3,
                          margin: EdgeInsets.symmetric(horizontal: 5.w),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colors.outline,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            controller.activeNetworkName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodySmall.copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.bold,
                                                          ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: AppSpacing.sm),
          Divider(
            color: isDark
                ? colors.onSurface.withValues(alpha: 0.06)
                : colors.outlineVariant.withValues(alpha: 0.5),
            height: 1,
          ),
          SizedBox(height: AppSpacing.sm),

          // 2. الكبسولتان السريعتان المتجاوبتان 100% بدون أي تجاوز أفقي
          Row(
            children: [
              // كبسولة التاريخ
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: isDark
                        ? colors.onSurface.withValues(alpha: 0.04)
                        : colors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: isDark
                          ? colors.onSurface.withValues(alpha: 0.06)
                          : colors.outlineVariant.withValues(alpha: 0.6),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: AppSpacing.xxl,
                        height: AppSpacing.xxl,
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Icon(
                          Icons.calendar_today_rounded,
                          size: 13.r,
                          color: colors.primary,
                        ),
                      ),
                      AppSpacing.hXs,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'تاريخ اليوم',
                              style: TextStyle(
                                color: colors.onSurfaceVariant,
                                                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              todayStr,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: colors.onSurface,
                                fontWeight: FontWeight.w700,
                                                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AppSpacing.hSm,

              // كبسولة الطلبات المعلقة
              Expanded(
                child: CustomInteractiveBounce(
                  onTap: onPendingTap,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: hasPendingRequests
                          ? colors.warning.withValues(
                              alpha: isDark ? 0.14 : 0.08,
                            )
                          : (isDark
                                ? colors.onSurface.withValues(alpha: 0.04)
                                : colors.surfaceContainerLow),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: hasPendingRequests
                            ? colors.warning.withValues(
                                alpha: isDark ? 0.4 : 0.3,
                              )
                            : (isDark
                                  ? colors.onSurface.withValues(alpha: 0.06)
                                  : colors.outlineVariant.withValues(
                                      alpha: 0.6,
                                    )),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 26.r,
                          height: 26.r,
                          decoration: BoxDecoration(
                            color:
                                (hasPendingRequests
                                        ? colors.warning
                                        : colors.primary)
                                    .withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Icon(
                            hasPendingRequests
                                ? Icons.pending_actions_rounded
                                : Icons.task_alt_rounded,
                            size: 13.r,
                            color: hasPendingRequests
                                ? colors.warning
                                : colors.primary,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'حالة التوريد',
                                style: TextStyle(
                                  color: colors.onSurfaceVariant,
                                                                    fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                !hasPendingMetric
                                    ? 'غير متاح'
                                    : hasPendingRequests
                                        ? '$pendingCount طلب معلق'
                                        : 'لا توجد طلبات معلقة',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: hasPendingRequests
                                      ? colors.warning
                                      : colors.onSurface,
                                  fontWeight: FontWeight.w700,
                                                                  ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 10.r,
                          color: hasPendingRequests
                              ? colors.warning
                              : colors.onSurfaceVariant.withValues(alpha: 0.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
