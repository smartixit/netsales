import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/text_formatter.dart';
import 'package:netsales/features/home/presentation/controllers/dashboard_controller.dart';
import 'package:netsales/features/home/presentation/controllers/home_layout_controller.dart';
import 'package:netsales/widgets/buttons/custom_theme_toggle_button.dart';
import 'package:netsales/widgets/images/custom_cached_image.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// ============================================================================
/// ترويسة التطبيق التنفيذية الموحدة (HomeAppBar)
/// ============================================================================
/// منصة قيادة علوية فاخرة تعكس الحضور التنفيذي للمستخدم:
/// - هوية بصرية متميزة مع مؤشر اتصال ومزامنة لحظية حية.
/// - تحية زمنية ذكية تتكيف مع أوقات اليوم.
/// - رصيف إجراءات زجاجي مدمج (Frosted Action Dock) يجمع أدوات الخصوصية والثيم والإشعارات.
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final HomeLayoutController controller;

  const HomeAppBar({
    super.key,
    required this.controller,
  });

  @override
  Size get preferredSize => Size.fromHeight(68.h);

  String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 12) {
      return 'صباح الخير';
    } else if (hour >= 12 && hour < 17) {
      return 'طاب يومك';
    } else {
      return 'مساء الخير';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final greeting = _getTimeBasedGreeting();

    return Container(
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.96),
        border: Border(
          bottom: BorderSide(
            color: colors.outlineVariant.withValues(alpha: 0.2),
            width: 1.w,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            children: [
              // 1. الصورة الرمزية للمستخدم مع مؤشر المزامنة الحية المضيء
              Obx(
                () => _ExecutiveUserAvatar(
                  logoUrl: controller.userProfileLogo,
                  fullName: controller.userFullName,
                  onTap: () => controller.changeTab(3),
                ),
              ),

              AppSpacing.hSm,

              // 2. التحية الزمنية الذكية واسم المستخدم وشارة الدور المعتمد
              Expanded(
                child: Obx(
                  () => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            greeting,
                            style: AppTypography.labelSmall.copyWith(
                              color: colors.onSurfaceVariant,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          AppSpacing.hXs,
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs,
                              vertical: 1.5.h,
                            ),
                            decoration: BoxDecoration(
                              color: colors.primary.withValues(alpha: 0.1),
                              borderRadius: AppRadius.xsRadius,
                              border: Border.all(
                                color: colors.primary.withValues(alpha: 0.2),
                                width: 0.8.w,
                              ),
                            ),
                            child: Text(
                              controller.userRoleLabel,
                              style: AppTypography.labelSmall.copyWith(
                                color: colors.primary,
                                fontSize: 9.5.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.vXxs,
                      Text(
                        controller.userShortName,
                        style: AppTypography.titleMedium.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),

              AppSpacing.hSm,

              // 3. رصيف الإجراءات الزجاجي المدمج (Frosted Action Dock)
              _FrostedActionDock(controller: controller),
            ],
          ),
        ),
      ),
    );
  }
}

/// ============================================================================
/// ودجت الصورة الرمزية التنفيذية مع هالة ضوئية ومؤشر اتصال حي
/// ============================================================================
class _ExecutiveUserAvatar extends StatelessWidget {
  final String? logoUrl;
  final String fullName;
  final VoidCallback onTap;

  const _ExecutiveUserAvatar({
    required this.logoUrl,
    required this.fullName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final initials = fullName.avatarInitial(fallback: 'ن');

    return CustomInteractiveBounce(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colors.primary.withValues(alpha: 0.3),
                  colors.primaryContainer.withValues(alpha: 0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: colors.primary.withValues(alpha: 0.35),
                width: 1.2.w,
              ),
            ),
            padding: EdgeInsets.all(2.r),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11.r),
              child: CustomCachedImage.avatar(
                url: logoUrl,
                radius: 20.r,
                fallbackText: initials,
              ),
            ),
          ),
          // نقطة المزامنة الخضراء الحية (Live Pulse Indicator)
          PositionedDirectional(
            bottom: -1.h,
            end: -1.w,
            child: Container(
              width: 12.r,
              height: 12.r,
              decoration: BoxDecoration(
                color: colors.success,
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.surface,
                  width: 2.w,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.success.withValues(alpha: 0.45),
                    blurRadius: 5.r,
                    spreadRadius: 1.r,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ============================================================================
/// رصيف الإجراءات الزجاجي المدمج (Frosted Action Dock)
/// ============================================================================
class _FrostedActionDock extends StatelessWidget {
  final HomeLayoutController controller;

  const _FrostedActionDock({required this.controller});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      height: 38.h,
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: AppRadius.fullRadius,
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.3),
          width: 1.w,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // أداة حجب الأرقام والخصوصية بنقرة واحدة
          const _PrivacyToggleDockAction(),

          _DockDivider(),

          // أداة تبديل الوضع الليلي / الفاتح
          const CustomThemeToggleButton(),

          _DockDivider(),

          // جرس الإشعارات مع شارة العداد اللحظي
          _NotificationBellDockAction(
            unreadCount: controller.unreadNotificationsCount,
            onTap: () => Get.toNamed(AppRoutes.notifications),
          ),
        ],
      ),
    );
  }
}

/// فاصل رأسي نحيف داخل رصيف الإجراءات
class _DockDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.w,
      height: 16.h,
      margin: EdgeInsets.symmetric(horizontal: 2.w),
      color: context.colors.outlineVariant.withValues(alpha: 0.25),
    );
  }
}

/// أداة الخصوصية المدمجة في الرصيف
class _PrivacyToggleDockAction extends StatelessWidget {
  const _PrivacyToggleDockAction();

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<DashboardController>()) {
      return const SizedBox.shrink();
    }
    final dashboardCtrl = Get.find<DashboardController>();
    final colors = context.colors;

    return Obx(() {
      final isMasked = dashboardCtrl.isPrivacyMasked.value;
      return CustomInteractiveBounce(
        onTap: () {
          HapticFeedback.lightImpact();
          dashboardCtrl.togglePrivacyMask();
        },
        child: Container(
          width: 32.r,
          height: 32.r,
          decoration: BoxDecoration(
            color: isMasked ? colors.primary.withValues(alpha: 0.15) : Colors.transparent,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(
            isMasked ? Icons.visibility_off_rounded : Icons.visibility_outlined,
            size: 18.r,
            color: isMasked ? colors.primary : colors.onSurfaceVariant,
          ),
        ),
      );
    });
  }
}

/// جرس الإشعارات المدمج في الرصيف مع الشارة
class _NotificationBellDockAction extends StatelessWidget {
  final RxInt unreadCount;
  final VoidCallback onTap;

  const _NotificationBellDockAction({
    required this.unreadCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomInteractiveBounce(
      onTap: onTap,
      child: Container(
        width: 32.r,
        height: 32.r,
        alignment: Alignment.center,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 19.r,
              color: colors.onSurface,
            ),
            Obx(() {
              final count = unreadCount.value;
              if (count <= 0) return const SizedBox.shrink();

              return PositionedDirectional(
                top: 3.h,
                end: 3.w,
                child: Container(
                  width: 8.r,
                  height: 8.r,
                  decoration: BoxDecoration(
                    color: colors.error,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.surface, width: 1.5.w),
                    boxShadow: [
                      BoxShadow(
                        color: colors.error.withValues(alpha: 0.5),
                        blurRadius: 3.r,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

