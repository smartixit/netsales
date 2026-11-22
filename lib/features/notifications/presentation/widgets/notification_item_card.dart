import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/notifications/domain/entities/notification_item_entity.dart';
import 'package:netsales/features/notifications/presentation/widgets/notification_card_media.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// بطاقة عرض الإشعار التنفيذية ذات العمق البصري الفاخر (NotificationItemCard)
///
/// صُممت بمواصفات VIP للمؤسسات الكبرى:
/// - زجاجية داكنة (Obsidian Glassmorphism) مع حدود متوهجة دقيقة وظلال مزدوجة.
/// - أيقونة دومينية ملونة طبقاً لسجل [EnumPresentationRegistry].
/// - نقطة نيون نابضة للإشعارات غير المقروءة.
/// - دعم التمدد والانكماش التفاعلي للنصوص الطويلة (Inline Expansion) مع زر "قراءة المزيد / إخفاء".
/// - تكامل ذكي مع المرفقات الصورية عبر [NotificationCardMedia] بمصغرة مدمجة في وضع الطي
///   ولافتة عريضة عالية الدقة في وضع التمدد مع إمكانية التكبير عبر معرض الوسائط الموحد.
/// - خالية تماماً من الدوال الخاصة المعيدة للواجهات (Zero _buildXxx Helpers)، صف واحد فقط لكل ملف.
class NotificationItemCard extends StatelessWidget {
  final NotificationItemEntity notification;
  final VoidCallback onTap;
  final VoidCallback? onMarkAsRead;
  final RxBool isExpanded = false.obs;

  NotificationItemCard({
    super.key,
    required this.notification,
    required this.onTap,
    this.onMarkAsRead,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isUnread = !notification.isRead;

    // تمثيل الدومين المركزي عبر سجل النبرات والأيقونات الموحد
    final presentation = EnumPresentationRegistry.resolveNotificationType(
      notification.notificationType,
      serverLabel: notification.notificationTypeLabel,
    );
    final toneColor = presentation.tone.resolveColor(colors);

    final hasImage =
        notification.notificationImage != null &&
        notification.notificationImage!.trim().isNotEmpty;

    final isLongText =
        notification.notificationMessage.length > 80 ||
        notification.notificationMessage.contains('\n');

    final canExpand = isLongText || hasImage;

    return CustomInteractiveBounce(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4.h),
        decoration: BoxDecoration(
          color: isUnread
              ? colors.surfaceContainerLow
              : colors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isUnread
                ? colors.primary.withValues(alpha: 0.45)
                : colors.outlineVariant.withValues(alpha: 0.25),
            width: isUnread ? 1.4 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isUnread
                  ? colors.primary.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: isUnread ? 14 : 8,
              offset: const Offset(0, 4),
            ),
            if (isUnread)
              BoxShadow(
                color: toneColor.withValues(alpha: 0.05),
                blurRadius: 20,
                spreadRadius: -2,
                offset: const Offset(0, 8),
              ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 1. ترويسة الإشعار (الأيقونة، العنوان، الوقت، خرزة النيون) ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // أيقونة النوع ذات التدرج اللوني النبري
                  Container(
                    width: 42.r,
                    height: 42.r,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          toneColor.withValues(alpha: 0.22),
                          toneColor.withValues(alpha: 0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(
                        color: toneColor.withValues(alpha: 0.35),
                        width: 1.0,
                      ),
                    ),
                    child: Icon(
                      presentation.icon,
                      color: toneColor,
                      size: 22.r,
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),

                  // عنوان الإشعار وشارة نوع الدومين
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
                                  fontWeight: isUnread
                                      ? FontWeight.bold
                                      : FontWeight.w600,
                                  color: colors.onSurface,
                                  height: 1.25,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isUnread) ...[
                              SizedBox(width: 6.w),
                              // خرزة النيون النابضة للجديد
                              Container(
                                width: 8.r,
                                height: 8.r,
                                decoration: BoxDecoration(
                                  color: colors.primary,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: colors.primary.withValues(
                                        alpha: 0.7,
                                      ),
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 4.h,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            CustomStatusBadge.fromPresentation(
                              presentation,
                              isCompact: true,
                            ),
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

              SizedBox(height: AppSpacing.sm),

              // ── 2. محتوى النص وصورة الإشعار (مطوي أو ممدد) ──
              Obx(() {
                final expanded = isExpanded.value;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // نص الإشعار
                    if (!expanded && hasImage)
                      // في وضع الطي مع وجود صورة: نص ومصغرة في صف واحد
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              notification.notificationMessage,
                              style: AppTypography.bodySmall.copyWith(
                                color: isUnread
                                    ? colors.onSurface
                                    : colors.onSurfaceVariant,
                                height: 1.45,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: AppSpacing.sm),
                          NotificationCardMedia(
                            imageUrl: notification.notificationImage!,
                            title: notification.notificationTitle,
                            subtitle: notification.relativeTime,
                            notificationId: notification.notificationId,
                            isExpanded: false,
                          ),
                        ],
                      )
                    else
                      // في وضع التمدد أو بدون صورة: نص كامل
                      Text(
                        notification.notificationMessage,
                        style: AppTypography.bodySmall.copyWith(
                          color: isUnread
                              ? colors.onSurface
                              : colors.onSurfaceVariant,
                          height: 1.5,
                        ),
                        maxLines: expanded ? null : 2,
                        overflow: expanded ? null : TextOverflow.ellipsis,
                      ),

                    // لافتة الصورة الكاملة عند التمدد
                    if (expanded && hasImage)
                      NotificationCardMedia(
                        imageUrl: notification.notificationImage!,
                        title: notification.notificationTitle,
                        subtitle: notification.relativeTime,
                        notificationId: notification.notificationId,
                        isExpanded: true,
                      ),

                    // زر التبديل التفاعلي "قراءة المزيد / إخفاء"
                    if (canExpand)
                      Padding(
                        padding: EdgeInsets.only(top: 4.h),
                        child: GestureDetector(
                          onTap: () => isExpanded.toggle(),
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 4.h),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  expanded
                                      ? 'إخفاء التفاصيل'
                                      : 'قراءة المزيد...',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: colors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Icon(
                                  expanded
                                      ? Icons.keyboard_arrow_up_rounded
                                      : Icons.keyboard_arrow_down_rounded,
                                  color: colors.primary,
                                  size: 16.r,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              }),

              // ── 3. شريط الإجراءات السفلي الذكي ──
              if (isUnread || notification.targetRoute.isNotEmpty) ...[
                SizedBox(height: 8.h),
                Divider(
                  height: 1,
                  thickness: 0.6,
                  color: colors.outlineVariant.withValues(alpha: 0.2),
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (isUnread && onMarkAsRead != null)
                      Flexible(
                        child: CustomButton.text(
                          text: 'تعليم كمقروء',
                          icon: Icons.done_rounded,
                          foregroundColor: colors.onSurfaceVariant,
                          size: AppButtonSize.small,
                          onPressed: onMarkAsRead,
                        ),
                      )
                    else
                      const Spacer(),
                    if (notification.targetRoute.isNotEmpty) ...[
                      SizedBox(width: 8.w),
                      Flexible(
                        child: CustomButton.text(
                          text: 'عرض الإجراء',
                          icon: Icons.arrow_forward_rounded,
                          foregroundColor: colors.primary,
                          size: AppButtonSize.small,
                          onPressed: onTap,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
