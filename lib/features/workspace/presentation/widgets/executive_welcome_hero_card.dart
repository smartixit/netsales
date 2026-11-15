import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/services/session_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/date_formatter.dart';
import 'package:netsales/core/utils/text_formatter.dart';
import 'package:netsales/features/workspace/domain/entities/network_workspace_overview_entity.dart';
import 'package:netsales/widgets/images/custom_avatar_badge.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// كرت الترحيب القيادي التنفيذي المتجاوب (ExecutiveWelcomeHeroCard)
/// يعرض هوية المشغل وحالة الاتصال والكبسولات السريعة دون أي أخطاء تجاوز أو اقتطاع
class ExecutiveWelcomeHeroCard extends StatelessWidget {
  final NetworkWorkspaceOverviewEntity overview;
  final VoidCallback onPendingTap;

  const ExecutiveWelcomeHeroCard({
    super.key,
    required this.overview,
    required this.onPendingTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = Get.isRegistered<SessionService>()
        ? SessionService.to.currentUser
        : null;

    final greeting = DateFormatter.greeting();
    final hasRequests = overview.metrics.containsKey('requests');
    final pendingCount = hasRequests
        ? int.tryParse(overview.count('requests', 'pending')) ?? 0
        : 0;

    final realFullName = user?.userFullName ?? 'المستخدم';
    final realRole =
        user?.role?.roleName ?? user?.statusLabel ?? 'مزود شبكة معتمد';
    final initials = TextFormatter.avatarInitials(realFullName, maxChars: 2);
    final todayStr = DateFormatter.fullDate(DateTime.now());

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 14.h,
      ),
      decoration: BoxDecoration(
        color: isDark ? colors.surfaceContainerLow : colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : colors.outlineVariant.withValues(alpha: 0.7),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: isDark ? 0.35 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
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
                imageUrl: user?.userProfileLogo,
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
                            fontSize: 10.5.sp,
                          ),
                        ),
                        Container(
                          width: 3.5,
                          height: 3.5,
                          margin: EdgeInsets.symmetric(horizontal: 5.w),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colors.outline,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 5.w,
                            vertical: 1.h,
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
                              fontSize: 9.5.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      realFullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.titleMedium.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w900,
                        fontSize: 15.sp,
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
                              fontSize: 11.sp,
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
                            overview.networkName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodySmall.copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 11.sp,
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
                ? Colors.white.withValues(alpha: 0.06)
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
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.04)
                        : colors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : colors.outlineVariant.withValues(alpha: 0.6),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 26.r,
                        height: 26.r,
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Icon(
                          Icons.calendar_today_rounded,
                          size: 13.r,
                          color: colors.primary,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'تاريخ اليوم',
                              style: TextStyle(
                                color: colors.onSurfaceVariant,
                                fontSize: 9.sp,
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
                                fontSize: 10.5.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 8.w),

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
                      color: pendingCount > 0
                          ? colors.warning.withValues(
                              alpha: isDark ? 0.14 : 0.08,
                            )
                          : (isDark
                              ? Colors.white.withValues(alpha: 0.04)
                              : colors.surfaceContainerLow),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: pendingCount > 0
                            ? colors.warning.withValues(
                                alpha: isDark ? 0.4 : 0.3,
                              )
                            : (isDark
                                ? Colors.white.withValues(alpha: 0.06)
                                : colors.outlineVariant.withValues(alpha: 0.6)),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 26.r,
                          height: 26.r,
                          decoration: BoxDecoration(
                            color: (pendingCount > 0
                                    ? colors.warning
                                    : colors.primary)
                                .withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Icon(
                            pendingCount > 0
                                ? Icons.pending_actions_rounded
                                : Icons.task_alt_rounded,
                            size: 13.r,
                            color: pendingCount > 0
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
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                pendingCount > 0
                                    ? '$pendingCount طلب معلق'
                                    : 'كل العمليات مستقرة',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: pendingCount > 0
                                      ? colors.warning
                                      : colors.onSurface,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10.5.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 10.r,
                          color: pendingCount > 0
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
