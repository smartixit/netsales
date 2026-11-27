import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/notifications/domain/entities/notification_item_entity.dart';
import 'package:netsales/features/notifications/presentation/widgets/notification_card_media.dart';
import 'package:netsales/widgets/badges/custom_chip.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/cards/custom_detail_info_section.dart';
import 'package:netsales/widgets/cards/custom_surface_card.dart';

/// ورقة تفاصيل الإشعار السفلية بأسلوب قيد مع معاينة الصورة عبر [MediaGalleryViewer].
class NotificationDetailsSheet extends StatelessWidget {
  const NotificationDetailsSheet({
    super.key,
    required this.notification,
    this.onPreviewImage,
    this.onNavigateTarget,
  });

  final NotificationItemEntity notification;
  final VoidCallback? onPreviewImage;
  final VoidCallback? onNavigateTarget;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;
    final presentation = EnumPresentationRegistry.resolveNotificationType(
      notification.notificationType,
      serverLabel: notification.notificationTypeLabel,
    );
    final toneColor = presentation.tone.resolveColor(colors);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48.r,
              height: 48.r,
              decoration: BoxDecoration(
                color: toneColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                presentation.icon ?? Icons.notifications_rounded,
                color: toneColor,
                size: 24.sp,
              ),
            ),
            AppSpacing.hMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.notificationTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colors.onSurface,
                    ),
                  ),
                  AppSpacing.vXs,
                  Text(
                    notification.formattedDateTime,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        AppSpacing.vMd,
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            CustomChip.fromPresentation(presentation),
            CustomChip(
              label: notification.isRead ? 'مقروء' : 'غير مقروء',
              icon: notification.isRead
                  ? Icons.mark_email_read_outlined
                  : Icons.mark_email_unread_outlined,
              backgroundColor: notification.isRead
                  ? colors.surfaceContainerHigh
                  : colors.primary.withValues(alpha: 0.12),
              foregroundColor: notification.isRead
                  ? colors.onSurfaceVariant
                  : colors.primary,
            ),
          ],
        ),
        if (notification.hasImage && onPreviewImage != null) ...[
          AppSpacing.vMd,
          NotificationCardMedia(
            imageUrl: notification.notificationImage!,
            notificationId: notification.notificationId,
            isBanner: true,
            onTap: onPreviewImage!,
          ),
        ],
        AppSpacing.vMd,
        CustomSurfaceCard(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: SelectableText(
            notification.notificationMessage.trim().isEmpty
                ? 'لا يوجد محتوى لهذا الإشعار.'
                : notification.notificationMessage,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.65,
              color: colors.onSurface,
            ),
          ),
        ),
        AppSpacing.vMd,
        CustomDetailInfoSection(
          icon: Icons.info_outline_rounded,
          title: 'معلومات الإشعار',
          children: [
            CustomDetailInfoTile(
              icon: presentation.icon ?? Icons.label_outline_rounded,
              label: 'نوع الإشعار',
              value: presentation.label,
            ),
            const CustomDetailInfoDivider(),
            CustomDetailInfoTile(
              icon: Icons.access_time_rounded,
              label: 'تاريخ الإرسال',
              value: notification.formattedDateTime,
            ),
          ],
        ),
        if (onNavigateTarget != null) ...[
          AppSpacing.vLg,
          CustomButton(
            text: 'فتح القسم المرتبط',
            variant: AppButtonVariant.primary,
            icon: Icons.open_in_new_rounded,
            width: double.infinity,
            onPressed: onNavigateTarget,
          ),
        ],
      ],
    );
  }
}
