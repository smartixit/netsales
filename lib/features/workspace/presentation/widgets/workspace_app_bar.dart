import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/services/session_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/notifications/presentation/widgets/notification_badge_button.dart';
import 'package:netsales/features/workspace/presentation/controllers/workspace_coordinator_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/buttons/custom_theme_toggle_button.dart';

/// شريط التطبيق الموحد لمساحات العمل (WorkspaceAppBar)
class WorkspaceAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final AppWorkspace workspace;
  final List<Widget>? actions;

  const WorkspaceAppBar({
    super.key,
    required this.title,
    required this.workspace,
    this.actions,
  });

  @override
  Size get preferredSize => Size.fromHeight(60.h);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isNetwork = workspace == AppWorkspace.network;
    final badgeColor = isNetwork ? colors.primary : colors.secondary;

    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: badgeColor.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isNetwork ? Icons.hub_rounded : Icons.storefront_rounded,
                  size: 16.sp,
                  color: badgeColor,
                ),
                SizedBox(width: 6.w),
                Text(
                  isNetwork ? 'مزود الشبكة' : 'نقطة البيع',
                  style: AppTypography.badgeText.copyWith(color: badgeColor),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Flexible(
            child: Text(
              title,
              style: AppTypography.titleMedium.copyWith(
                color: colors.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        ...?actions,
        const NotificationBadgeButton(),
        CustomButton.icon(
          icon: Icons.shield_outlined,
          foregroundColor: colors.onSurfaceVariant,
          tooltip: 'إعدادات الأمان',
          backgroundColor: Colors.transparent,
          dimension: 40.r,
          iconSize: 22.r,
          onPressed: () => Get.toNamed<dynamic>(AppRoutes.securitySettings),
        ),
        CustomButton.icon(
          icon: Icons.devices_rounded,
          foregroundColor: colors.onSurfaceVariant,
          tooltip: 'الأجهزة والجلسات النشطة',
          backgroundColor: Colors.transparent,
          dimension: 40.r,
          iconSize: 22.r,
          onPressed: () => Get.toNamed<dynamic>(AppRoutes.activeSessions),
        ),
        const CustomThemeToggleButton(),
        CustomButton.icon(
          icon: Icons.logout_rounded,
          foregroundColor: colors.error,
          tooltip: 'تسجيل الخروج',
          backgroundColor: Colors.transparent,
          dimension: 40.r,
          iconSize: 22.r,
          onPressed: () {
            if (Get.isRegistered<WorkspaceCoordinatorController>()) {
              WorkspaceCoordinatorController.to.logout();
            } else if (Get.isRegistered<SessionService>()) {
              SessionService.to.terminateSession();
            }
          },
        ),
      ],
      elevation: 0,
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
    );
  }
}
