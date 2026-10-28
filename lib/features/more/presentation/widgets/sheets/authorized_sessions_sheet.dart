import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/more/domain/entities/user_session_entity.dart';
import 'package:netsales/features/more/presentation/controllers/more_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_feed.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';

/// ============================================================================
/// نافذة الأجهزة والجلسات المصرح بها (AuthorizedSessionsSheet)
/// ============================================================================
/// تعرض الأجهزة النشطة المرتبطة بالحساب، وتميز الجهاز الحالي بشارة خضراء،
/// مع إمكانية إنهاء وإلغاء صلاحية أي جهاز مشبوه أو جلسة قديمة بنقرة واحدة.
class AuthorizedSessionsSheet extends StatelessWidget {
  const AuthorizedSessionsSheet({super.key});

  /// فتح النافذة السفلية المنبثقة
  static Future<void> show(BuildContext context) {
    final controller = Get.find<MoreController>();
    controller.loadUserSessions();

    return CustomBottomSheet.show<void>(
      title: 'الأجهزة والجلسات المصرح بها',
      subtitle: 'حماية وتأمين الحساب وإدارة الأجهزة المتصلة بالنظام',
      leadingIcon: Icons.devices_rounded,
      scrollable: true,
      child: const AuthorizedSessionsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final controller = Get.find<MoreController>();

    return Obx(() {
      final isLoading = controller.isLoadingSessions.value;
      final errorMessage = controller.sessionsErrorMessage.value;
      final sessions = controller.userSessions;

      if (isLoading && sessions.isEmpty) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 24.h),
          child: const CustomSkeletonFeed(itemCount: 3, cardHeight: 110),
        );
      }

      if (errorMessage.isNotEmpty && sessions.isEmpty) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 32.h, horizontal: 16.w),
          child: Column(
            children: [
              Icon(Icons.error_outline_rounded,
                  size: 48.r, color: colors.error),
              AppSpacing.vMd,
              Text(
                errorMessage,
                style: AppTypography.bodyMedium
                    .copyWith(color: colors.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              AppSpacing.vLg,
              CustomButton.outline(
                text: 'إعادة المحاولة',
                icon: Icons.refresh_rounded,
                onPressed: () => controller.loadUserSessions(isRefresh: true),
              ),
            ],
          ),
        );
      }

      if (sessions.isEmpty) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 32.h),
          child: Center(
            child: Text(
              'لا توجد جلسات أخرى مسجلة حالياً.',
              style: AppTypography.bodyMedium
                  .copyWith(color: colors.onSurfaceVariant),
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...sessions.map(
            (session) => Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.md),
              child: _SessionCard(
                session: session,
                onTerminate: () =>
                    controller.terminateSession(session.sessionId),
              ),
            ),
          ),
        ],
      );
    });
  }
}

/// بطاقة الجلسة وجهاز المستخدم
class _SessionCard extends StatelessWidget {
  final UserSessionEntity session;
  final VoidCallback onTerminate;

  const _SessionCard({
    required this.session,
    required this.onTerminate,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isCurrent = session.isCurrentSession;

    final lastActive = session.lastActivityAt != null
        ? DateFormat('yyyy/MM/dd - hh:mm a').format(session.lastActivityAt!)
        : 'الآن';

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: isCurrent
              ? colors.success.withValues(alpha: 0.4)
              : colors.outlineVariant.withValues(alpha: 0.4),
          width: isCurrent ? 1.4 : 1.0,
        ),
        boxShadow: AppElevation.level2(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  color: (isCurrent ? colors.success : colors.primary)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  Icons.phone_android_rounded,
                  color: isCurrent ? colors.success : colors.primary,
                  size: 22.r,
                ),
              ),
              AppSpacing.hMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            session.userAgent,
                            style: AppTypography.titleSmall.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isCurrent) ...[
                          AppSpacing.hSm,
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: colors.success.withValues(alpha: 0.15),
                              borderRadius:
                                  BorderRadius.circular(AppRadius.full),
                            ),
                            child: Text(
                              'هذا الجهاز',
                              style: AppTypography.labelSmall.copyWith(
                                color: colors.success,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    AppSpacing.vXs,
                    Text(
                      'عنوان IP: ${session.ipAddress}',
                      style: AppTypography.bodySmall.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isCurrent)
                CustomInteractiveBounce(
                  onTap: onTerminate,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: colors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.logout_rounded,
                          size: 14.r,
                          color: colors.error,
                        ),
                        AppSpacing.hXs,
                        Text(
                          'إنهاء',
                          style: AppTypography.labelSmall.copyWith(
                            color: colors.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          AppSpacing.vSm,
          Text(
            'آخر نشاط: $lastActive',
            style: AppTypography.labelSmall.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
