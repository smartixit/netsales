import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/services/session_service.dart';
import 'package:netsales/core/services/theme_service.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/text_formatter.dart';
import 'package:netsales/features/notifications/presentation/widgets/notification_badge_button.dart';
import 'package:netsales/features/workspace/presentation/controllers/workspace_coordinator_controller.dart';
import 'package:netsales/features/workspace/presentation/widgets/workspace_entity_picker_sheet.dart';
import 'package:netsales/features/workspace/presentation/widgets/workspace_sheet_action_tile.dart';
import 'package:netsales/widgets/images/custom_cached_image.dart';
import 'package:netsales/widgets/indicators/custom_pulsing_indicator.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';

/// شريط التطبيق القيادي الفاخر العائم والضبابي لمساحات العمل (WorkspaceAppBar - Executive Frosted Glass Floating Edition)
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
  Size get preferredSize => Size.fromHeight(80.h);

  void _showEntityPickerSheet(BuildContext context) {
    WorkspaceEntityPickerSheet.show(context, currentWorkspace: workspace);
  }

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
    final realRole =
        user?.role?.roleName ??
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
                          TextFormatter.avatarInitials(
                            realFullName,
                            maxChars: 2,
                          ),
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
            WorkspaceSheetActionTile(
              icon: Icons.swap_horiz_rounded,
              iconColor: colors.primary,
              title: 'تبديل مساحة العمل',
              subtitle: coordinator.switchWorkspaceTooltip,
              onTap: () {
                Get.back<void>();
                coordinator.toggleWorkspace();
              },
            ),

          WorkspaceSheetActionTile(
            icon: Icons.shield_outlined,
            iconColor: colors.info,
            title: 'إعدادات الأمان والخصوصية',
            subtitle: 'كلمة المرور، والتحقق، وتأمين الحساب',
            onTap: () {
              Get.back<void>();
              Get.toNamed<dynamic>(AppRoutes.securitySettings);
            },
          ),

          WorkspaceSheetActionTile(
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
          WorkspaceSheetActionTile(
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
          WorkspaceSheetActionTile(
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isNetwork = workspace == AppWorkspace.network;
    final user = Get.isRegistered<SessionService>()
        ? SessionService.to.currentUser
        : null;

    final realFullName = user?.userFullName ?? 'المستخدم';
    final initials = TextFormatter.avatarInitials(realFullName, maxChars: 2);

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: AppBreakpoints.screenMargin(context),
          right: AppBreakpoints.screenMargin(context),
          top: 10.h,
          bottom: 6.h,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              height: 64.h,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF0F172A).withValues(alpha: 0.85)
                    : colors.surface.withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : colors.outlineVariant.withValues(alpha: 0.6),
                  width: 1.2.w,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.shadow.withValues(alpha: isDark ? 0.3 : 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // الأفاتار القيادي مع نقطة الحالة النابضة
                  CustomInteractiveBounce(
                    onTap: () => _showExecutiveProfileSheet(context),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 46.r,
                          height: 46.r,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              AppRadius.md + 2,
                            ),
                            gradient: LinearGradient(
                              colors: [colors.primary, colors.secondary],
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: colors.primary.withValues(alpha: 0.25),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(1.6),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                AppRadius.md + 1,
                              ),
                              color: isDark
                                  ? const Color(0xFF0E1522)
                                  : colors.surface,
                            ),
                            alignment: Alignment.center,
                            child:
                                user?.userProfileLogo != null &&
                                    user!.userProfileLogo!.isNotEmpty
                                ? CustomCachedImage.avatar(
                                    url: user.userProfileLogo,
                                    radius: AppRadius.md + 1,
                                  )
                                : Text(
                                    initials,
                                    style: AppTypography.titleMedium.copyWith(
                                      color: colors.primary,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 15.sp,
                                    ),
                                  ),
                          ),
                        ),
                        Positioned(
                          bottom: -1,
                          left: -1,
                          child: CustomPulsingIndicator(
                            color: colors.primary,
                            size: 7.r,
                            enablePing: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10.w),

                  // هوية المساحة والشبكة
                  Expanded(
                    child: CustomInteractiveBounce(
                      onTap: () => _showEntityPickerSheet(context),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: colors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(
                                AppRadius.full,
                              ),
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
                                  isNetwork
                                      ? 'مزود شبكة معتمد'
                                      : 'نقطة بيع معتمدة',
                                  style: AppTypography.badgeText.copyWith(
                                    color: colors.primary,
                                    fontSize: 10.5.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 3.h),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.titleMedium.copyWith(
                                    color: colors.onSurface,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 16.r,
                                color: colors.onSurfaceVariant.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // الإجراءات: شارة الإشعارات الحقيقية + زر التحكم القيادي
                  ...?actions,
                  const NotificationBadgeButton(),
                  SizedBox(width: 8.w),
                  CustomInteractiveBounce(
                    onTap: () => _showExecutiveProfileSheet(context),
                    child: Container(
                      width: 42.r,
                      height: 42.r,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF131D2E)
                            : colors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : colors.outlineVariant,
                        ),
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}
