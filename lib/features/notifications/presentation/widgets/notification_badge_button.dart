import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/notifications/presentation/controllers/notification_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

/// زر شريط التطبيق المعتمد لعرض الإشعارات مع شارة العداد غير المقروء (NotificationBadgeButton)
class NotificationBadgeButton extends StatelessWidget {
  final Color? color;
  final VoidCallback? onPressed;

  const NotificationBadgeButton({
    super.key,
    this.color,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final iconColor = color ?? colors.onSurfaceVariant;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        CustomButton.icon(
          icon: Icons.notifications_none_rounded,
          foregroundColor: iconColor,
          tooltip: 'مركز الإشعارات',
          backgroundColor: Colors.transparent,
          dimension: 40.r,
          iconSize: 22.r,
          onPressed: onPressed ??
              () {
                if (Get.currentRoute != AppRoutes.notifications) {
                  Get.toNamed<dynamic>(AppRoutes.notifications);
                }
              },
        ),
        Obx(() {
          int count = 0;
          if (Get.isRegistered<NotificationController>()) {
            count = NotificationController.to.unreadCount.value;
          }

          if (count <= 0) return const SizedBox.shrink();

          final countText = count > 99 ? '99+' : count.toString();

          return Positioned(
            top: 4.h,
            left: 4.w,
            child: IgnorePointer(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: count > 9 ? 4.w : 5.w,
                  vertical: 1.h,
                ),
                constraints: BoxConstraints(
                  minWidth: 18.r,
                  minHeight: 18.r,
                ),
                decoration: BoxDecoration(
                  color: colors.error,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: colors.surface,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    countText,
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.onError,
                      fontWeight: FontWeight.bold,
                      fontSize: 9.sp,
                      height: 1.1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
