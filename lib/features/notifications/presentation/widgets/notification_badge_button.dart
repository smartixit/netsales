import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/services/theme_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/notifications/presentation/controllers/notification_controller.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// زر شريط التطبيق المعتمد لعرض الإشعارات مع شارة العداد غير المقروء الحقيقية (NotificationBadgeButton - Executive VIP)
class NotificationBadgeButton extends StatelessWidget {
  final Color? color;
  final VoidCallback? onPressed;
  final bool asContainer;

  const NotificationBadgeButton({
    super.key,
    this.color,
    this.onPressed,
    this.asContainer = true,
  });

  void _handleTap() {
    if (onPressed != null) {
      onPressed!();
      return;
    }
    if (Get.isRegistered<NotificationController>()) {
      NotificationController.to.openNotificationCenter();
    } else if (Get.currentRoute != AppRoutes.notifications) {
      Get.toNamed<dynamic>(AppRoutes.notifications);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final iconColor = color ?? colors.onSurfaceVariant;
    final isDark = ThemeService.to.isDarkMode;

    final isRegistered = Get.isRegistered<NotificationController>();

    return CustomInteractiveBounce(
      onTap: _handleTap,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            width: 42.r,
            height: 42.r,
            decoration: asContainer
                ? BoxDecoration(
                    color: isDark
                        ? const Color(0xFF131D2E)
                        : colors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : colors.outlineVariant,
                    ),
                  )
                : null,
            alignment: Alignment.center,
            child: Icon(
              Icons.notifications_none_rounded,
              size: 20.r,
              color: iconColor,
            ),
          ),
          if (isRegistered)
            Obx(() {
              final count = NotificationController.to.unreadCount.value;
              if (count <= 0) return const SizedBox.shrink();

              final countText = count > 99 ? '99+' : count.toString();

              return PositionedDirectional(
                top: 2.h,
                end: 2.w,
                child: IgnorePointer(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: count > 9 ? 4.w : 5.w,
                          vertical: 1.h,
                        ),
                        constraints: BoxConstraints(
                          minWidth: 16.r,
                          minHeight: 16.r,
                        ),
                        decoration: BoxDecoration(
                          color: colors.error,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          border: Border.all(color: colors.surface, width: 1.5),
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
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
