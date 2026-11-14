import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/services/session_service.dart';
import 'package:netsales/core/services/theme_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/text_formatter.dart';
import 'package:netsales/features/notifications/presentation/widgets/notification_badge_button.dart';
import 'package:netsales/features/workspace/presentation/controllers/workspace_coordinator_controller.dart';
import 'package:netsales/widgets/images/custom_cached_image.dart';
import 'package:netsales/widgets/indicators/custom_pulsing_indicator.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';

/// شريط التطبيق القيادي الفاخر لمساحات العمل (WorkspaceAppBar - Executive VIP Edition)
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
  Size get preferredSize => Size.fromHeight(68.h);

  void _showExecutiveProfileSheet(BuildContext context) {
    final colors = context.colors;
    final user = Get.isRegistered<SessionService>()
        ? SessionService.to.currentUser
        : null;
    final coordinator = Get.isRegistered<WorkspaceCoordinatorController>()
        ? WorkspaceCoordinatorController.to
        : null;
    final canSwitch = coordinator?.canSwitchWorkspace ?? false;
    final isNetwork = workspace == AppWorkspace.network;

    final realFullName = user?.userFullName ?? 'المستخدم';
    final realRole = user?.role?.roleName ??
        user?.statusLabel ??
        (isNetwork ? 'مدير الشبكة' : 'مشغل نقطة البيع');

    CustomBottomSheet.show<void>(
      title: 'الملف الشخصي والتحكم القيادي',
      subtitle: isNetwork ? 'لوحة تحكم مزود الشبكة' : 'لوحة تحكم نقطة البيع',
      leadingIcon: Icons.account_circle_outlined,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // بطاقة هوية المستخدم التنفيذية
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: colors.outlineVariant),
            ),
            child: Row(
              children: [
                user?.userProfileLogo != null &&
                        user!.userProfileLogo!.isNotEmpty
                    ? CustomCachedImage.avatar(
                        url: user.userProfileLogo,
                        radius: 24.r,
                      )
                    : Container(
                        width: 48.r,
                        height: 48.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors.primary.withValues(alpha: 0.15),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          TextFormatter.avatarInitials(realFullName, maxChars: 2),
                          style: AppTypography.titleMedium.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        realFullName,
                        style: AppTypography.titleMedium.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        realRole,
                        style: AppTypography.bodySmall.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (user?.userPhoneNumber != null &&
                          user!.userPhoneNumber.isNotEmpty) ...[
                        SizedBox(height: 2.h),
                        Text(
                          user.userPhoneNumber,
                          style: AppTypography.labelSmall.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.lg),

          // قائمة الإجراءات القيادية
          if (canSwitch && coordinator != null)
            _SheetActionTile(
              icon: Icons.swap_horiz_rounded,
              iconColor: colors.primary,
              title: 'تبديل مساحة العمل',
              subtitle: coordinator.switchWorkspaceTooltip,
              onTap: () {
                Get.back<void>();
                coordinator.toggleWorkspace();
              },
            ),

          _SheetActionTile(
            icon: Icons.shield_outlined,
            iconColor: colors.info,
            title: 'إعدادات الأمان والخصوصية',
            subtitle: 'كلمة المرور، والتحقق، وتأمين الحساب',
            onTap: () {
              Get.back<void>();
              Get.toNamed<dynamic>(AppRoutes.securitySettings);
            },
          ),

          _SheetActionTile(
            icon: Icons.devices_rounded,
            iconColor: colors.secondary,
            title: 'الأجهزة والجلسات النشطة',
            subtitle: 'إدارة الأجهزة المصرح لها بالدخول',
            onTap: () {
              Get.back<void>();
              Get.toNamed<dynamic>(AppRoutes.activeSessions);
            },
          ),

          // خيار تبديل المظهر النهاري / الليلي
          _SheetActionTile(
            icon: ThemeService.to.isDarkMode
                ? Icons.light_mode_outlined
                : Icons.dark_mode_outlined,
            iconColor: colors.warning,
            title: ThemeService.to.isDarkMode
                ? 'التبديل إلى الوضع النهاري (الفاتح)'
                : 'التبديل إلى الوضع الليلي (الداكن)',
            subtitle: 'تغيير سمة وألوان الواجهة فورياً',
            onTap: () {
              Get.back<void>();
              ThemeService.to.toggleTheme();
            },
          ),

          SizedBox(height: AppSpacing.sm),
          Divider(color: colors.outlineVariant),
          SizedBox(height: AppSpacing.sm),

          // تسجيل الخروج
          _SheetActionTile(
            icon: Icons.logout_rounded,
            iconColor: colors.error,
            isDestructive: true,
            title: 'تسجيل الخروج من الحساب',
            subtitle: 'إنهاء الجلسة والعودة لشاشة الدخول',
            onTap: () {
              Get.back<void>();
              if (coordinator != null) {
                coordinator.logout();
              } else if (Get.isRegistered<SessionService>()) {
                SessionService.to.terminateSession();
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isNetwork = workspace == AppWorkspace.network;
    final user = Get.isRegistered<SessionService>()
        ? SessionService.to.currentUser
        : null;

    final realFullName = user?.userFullName ?? 'المستخدم';
    final initials = TextFormatter.avatarInitials(realFullName, maxChars: 2);

    return AppBar(
      automaticallyImplyLeading: false,
      titleSpacing: AppSpacing.md,
      toolbarHeight: 68.h,
      elevation: 0,
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      title: Row(
        children: [
          // الأفاتار القيادي مع نقطة الحالة النابضة
          CustomInteractiveBounce(
            onTap: () => _showExecutiveProfileSheet(context),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 44.r,
                  height: 44.r,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    gradient: LinearGradient(
                      colors: [colors.primary, colors.secondary],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colors.primary.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(1.5),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.md - 1),
                      color: colors.surface,
                    ),
                    alignment: Alignment.center,
                    child: user?.userProfileLogo != null &&
                            user!.userProfileLogo!.isNotEmpty
                        ? CustomCachedImage.avatar(
                            url: user.userProfileLogo,
                            radius: 19.r,
                          )
                        : Text(
                            initials,
                            style: AppTypography.titleSmall.copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                  ),
                ),
                Positioned(
                  bottom: -2,
                  left: -2,
                  child: CustomPulsingIndicator(
                    color: colors.primary,
                    size: 6.r,
                    enablePing: true,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),

          // هوية المساحة والشبكة
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(
                      color: colors.primary.withValues(alpha: 0.25),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomPulsingIndicator(
                        color: colors.primary,
                        size: 4.r,
                        enablePing: false,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        isNetwork ? 'مزود شبكة معتمد' : 'نقطة بيع معتمدة',
                        style: AppTypography.badgeText.copyWith(
                          color: colors.primary,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.titleMedium.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        ...?actions,
        const NotificationBadgeButton(),
        CustomInteractiveBounce(
          onTap: () => _showExecutiveProfileSheet(context),
          child: Container(
            width: 40.r,
            height: 40.r,
            margin: EdgeInsetsDirectional.only(end: AppSpacing.md),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: colors.outlineVariant),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.tune_rounded,
              size: 20.r,
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _SheetActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SheetActionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: CustomInteractiveBounce(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isDestructive
                ? colors.error.withValues(alpha: 0.08)
                : colors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: isDestructive
                  ? colors.error.withValues(alpha: 0.25)
                  : colors.outlineVariant.withValues(alpha: 0.6),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 38.r,
                height: 38.r,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 20.r, color: iconColor),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.bodyMedium.copyWith(
                        color: isDestructive ? colors.error : colors.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: AppTypography.bodySmall.copyWith(
                        color: colors.onSurfaceVariant,
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14.r,
                color: colors.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
