import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/notifications/domain/entities/notification_item_entity.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// بطاقة عرض عنصر الإشعار (NotificationItemCard)
class NotificationItemCard extends StatelessWidget {
  final NotificationItemEntity notification;
  final VoidCallback onTap;
  final VoidCallback? onMarkAsRead;

  const NotificationItemCard({
    super.key,
    required this.notification,
    required this.onTap,
    this.onMarkAsRead,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isUnread = !notification.isRead;

    final primaryAccent = isUnread ? colors.primary : colors.onSurfaceVariant;
    final backgroundColor = isUnread
        ? colors.primary.withValues(alpha: 0.05)
        : colors.surfaceContainerLow;

    final borderColor = isUnread
        ? colors.primary.withValues(alpha: 0.3)
        : colors.outlineVariant.withValues(alpha: 0.3);

    return CustomInteractiveBounce(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: borderColor,
            width: isUnread ? 1.4 : 1.0,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // أيقونة نوع الإشعار الدوميني
            Container(
              width: 44.r,
              height: 44.r,
              decoration: BoxDecoration(
                color: isUnread
                    ? colors.primary.withValues(alpha: 0.12)
                    : colors.surfaceContainerHighest.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                notification.iconData,
                color: primaryAccent,
                size: 22.r,
              ),
            ),
            SizedBox(width: AppSpacing.md),

            // محتوى وتفاصيل الإشعار
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.notificationTitle,
                          style: AppTypography.titleSmall.copyWith(
                            fontWeight:
                                isUnread ? FontWeight.bold : FontWeight.w600,
                            color: colors.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isUnread) ...[
                        SizedBox(width: AppSpacing.xs),
                        Container(
                          width: 8.r,
                          height: 8.r,
                          decoration: BoxDecoration(
                            color: colors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    notification.notificationMessage,
                    style: AppTypography.bodySmall.copyWith(
                      color: isUnread
                          ? colors.onSurface
                          : colors.onSurfaceVariant,
                      height: 1.35,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (notification.notificationTypeLabel != null &&
                          notification.notificationTypeLabel!.isNotEmpty)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: colors.surfaceContainerHighest
                                .withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(AppRadius.xs),
                          ),
                          child: Text(
                            notification.notificationTypeLabel!,
                            style: AppTypography.labelSmall.copyWith(
                              color: colors.onSurfaceVariant,
                              fontSize: 10.sp,
                            ),
                          ),
                        )
                      else
                        const SizedBox.shrink(),
                      Text(
                        notification.relativeTime,
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.onSurfaceVariant,
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
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
