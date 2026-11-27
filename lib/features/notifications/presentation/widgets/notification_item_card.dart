import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/notifications/domain/entities/notification_item_entity.dart';
import 'package:netsales/features/notifications/presentation/widgets/notification_card_media.dart';
import 'package:netsales/widgets/badges/custom_chip.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/cards/custom_card_info_bar.dart';
import 'package:netsales/widgets/cards/custom_surface_card.dart';

/// بطاقة الإشعار التنفيذية بأسلوب تطبيق قيد — عرض نقي دون أي منطق.
class NotificationItemCard extends StatelessWidget {
  const NotificationItemCard({
    super.key,
    required this.notification,
    required this.onTap,
    this.onPreviewImage,
    this.onMarkAsRead,
  });

  final NotificationItemEntity notification;
  final VoidCallback onTap;
  final VoidCallback? onPreviewImage;
  final VoidCallback? onMarkAsRead;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isUnread = !notification.isRead;
    final presentation = EnumPresentationRegistry.resolveNotificationType(
      notification.notificationType,
      serverLabel: notification.notificationTypeLabel,
    );
    final toneColor = presentation.tone.resolveColor(colors);

    return CustomSurfaceCard(
      onTap: onTap,
      padding: EdgeInsets.all(AppSpacing.md),
      borderColor: isUnread
          ? colors.primary.withValues(alpha: 0.45)
          : colors.outlineVariant.withValues(alpha: 0.45),
      borderWidth: isUnread ? 1.4 : 1.0,
      backgroundColor: isUnread
          ? colors.primary.withValues(alpha: 0.03)
          : colors.surfaceContainerLowest,
      child: Stack(
        children: [
          PositionedDirectional(
            end: -8.w,
            bottom: -10.h,
            child: Icon(
              presentation.icon ?? Icons.notifications_rounded,
              size: 64.sp,
              color: toneColor.withValues(alpha: 0.05),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42.r,
                    height: 42.r,
                    decoration: BoxDecoration(
                      color: toneColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(
                      presentation.icon ?? Icons.notifications_rounded,
                      color: toneColor,
                      size: 21.sp,
                    ),
                  ),
                  AppSpacing.hMd,
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
                                  color: colors.onSurface,
                                  fontWeight: isUnread
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isUnread) ...[
                              AppSpacing.hXs,
                              CustomChip(
                                label: 'جديد',
                                icon: Icons.circle,
                                backgroundColor: colors.primary,
                                foregroundColor: colors.onPrimary,
                              ),
                            ],
                          ],
                        ),
                        AppSpacing.vXs,
                        Text(
                          notification.notificationMessage,
                          style: AppTypography.bodySmall.copyWith(
                            color: colors.onSurfaceVariant,
                            height: 1.45,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (notification.hasImage && onPreviewImage != null) ...[
                    AppSpacing.hSm,
                    NotificationCardMedia(
                      imageUrl: notification.notificationImage!,
                      notificationId: notification.notificationId,
                      onTap: onPreviewImage!,
                    ),
                  ],
                ],
              ),
              AppSpacing.vSm,
              Row(
                children: [
                  CustomChip.fromPresentation(
                    presentation,
                    isCompact: true,
                  ),
                  const Spacer(),
                  if (isUnread && onMarkAsRead != null)
                    CustomButton(
                      text: 'تعليم كمقروء',
                      variant: AppButtonVariant.text,
                      size: AppButtonSize.small,
                      icon: Icons.done_rounded,
                      onPressed: onMarkAsRead,
                    ),
                ],
              ),
              if (notification.relativeTime.isNotEmpty ||
                  notification.hasImage) ...[
                AppSpacing.vSm,
                CustomCardInfoBar(
                  items: [
                    if (notification.relativeTime.isNotEmpty)
                      CustomCardInfoItem(
                        icon: Icons.access_time_rounded,
                        text: notification.relativeTime,
                        color: colors.onSurfaceVariant,
                      ),
                    if (notification.hasImage && onPreviewImage != null)
                      CustomCardInfoItem(
                        icon: Icons.image_outlined,
                        text: 'عرض الصورة المرفقة',
                        color: colors.primary,
                        onTap: onPreviewImage,
                      ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
