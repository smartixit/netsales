import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/services/theme_service.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_motion.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/text_formatter.dart';
import 'package:netsales/features/home/presentation/controllers/dashboard_controller.dart';
import 'package:netsales/features/home/presentation/controllers/home_layout_controller.dart';
import 'package:netsales/widgets/images/custom_cached_image.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';
import 'package:netsales/widgets/interactions/custome_theme_switcher.dart';

/// ============================================================================
/// ترويسة التطبيق التنفيذية الفاخرة (HomeAppBar - Quiet Luxury Direction)
/// ============================================================================
/// تصميم هادئ، واثق، وعالمي يعكس الحضور التنفيذي والسيادي لمنظومة NetSales:
/// - تأثير زجاجي بلوري حقيقي (True Frosted Glass) بانسيابية كاملة خلف الشريط.
/// - هوية تنفيذية واضحة: صورة شخصية بإطار متدرج ناعم ومؤشر مزامنة حي مدمج.
/// - تدرج هرمي أنيق: تحية ذكية وشارة دور مدمجة مع اسم تنفيذي عريض.
/// - أزرار تحكم زجاجية حرة (Floating Glass Action Orbs) بديلة عن الأرصفة الصندوقية.
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final HomeLayoutController controller;

  const HomeAppBar({super.key, required this.controller});

  @override
  Size get preferredSize => Size.fromHeight(70.h);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final greeting = controller.timeBasedGreeting;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            color: colors.surface.withValues(alpha: 0.72),
            border: Border(
              bottom: BorderSide(
                color: colors.outlineVariant.withValues(alpha: 0.15),
                width: 1.w,
              ),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.screenMargin,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  // 1. الأفاتار التنفيذي الفاخر مع مؤشر المزامنة الحية
                  Obx(
                    () => _ExecutiveAvatarOrb(
                      logoUrl: controller.userProfileLogo,
                      fullName: controller.userFullName,
                      onTap: () => controller.changeTab(3),
                    ),
                  ),

                  AppSpacing.hSm,

                  // 2. الهوية التنفيذية: التحية الذكية، شارة الدور، واسم المستخدم
                  Expanded(
                    child: Obx(
                      () => _ExecutiveGreetingIdentity(
                        greeting: greeting,
                        userShortName: controller.userShortName,
                        roleLabel: controller.userRoleLabel,
                      ),
                    ),
                  ),

                  AppSpacing.hXs,

                  // 3. أزرار التحكم الزجاجية الحرة المتناسقة (Floating Glass Orbs)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // أداة الخصوصية اللحظية (حجب/إظهار الأرصدة)
                      const _PrivacyActionOrb(),

                      AppSpacing.hXs,

                      // أداة تبديل المظهر التفاعلية بأسلوب تليجرام
                      const _ThemeActionOrb(),

                      AppSpacing.hXs,

                      // جرس الإشعارات مع شارة التنبيهات غير المقروءة
                      _NotificationActionOrb(
                        unreadCount: controller.unreadNotificationsCount,
                        onTap: () => Get.toNamed(AppRoutes.notifications),
                      ),
                    ],
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

/// ============================================================================
/// ودجت الأفاتار التنفيذي بهالة متدرجة ناعمة ومؤشر مزامنة مدمج
/// ============================================================================
class _ExecutiveAvatarOrb extends StatelessWidget {
  final String? logoUrl;
  final String fullName;
  final VoidCallback onTap;

  const _ExecutiveAvatarOrb({
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
      child: Tooltip(
        message: 'الملف الشخصي والمركز المالي',
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // الإطار الخارجي الناعم
            Container(
              width: 44.r,
              height: 44.r,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colors.primary.withValues(alpha: 0.28),
                    colors.primaryContainer.withValues(alpha: 0.10),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.primary.withValues(alpha: 0.35),
                  width: 1.2.w,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.primary.withValues(alpha: 0.08),
                    blurRadius: 8.r,
                    offset: Offset(0, 2.h),
                  ),
                ],
              ),
              padding: EdgeInsets.all(2.r),
              child: ClipOval(
                child: CustomCachedImage.avatar(
                  url: logoUrl,
                  radius: 20.r,
                  fallbackText: initials,
                ),
              ),
            ),

            // مؤشر الاتصال والمزامنة الحية المدمج في الزاوية
            PositionedDirectional(
              bottom: 0,
              end: 0,
              child: Container(
                width: 11.r,
                height: 11.r,
                decoration: BoxDecoration(
                  color: colors.success,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.surface, width: 2.w),
                  boxShadow: [
                    BoxShadow(
                      color: colors.success.withValues(alpha: 0.5),
                      blurRadius: 4.r,
                      spreadRadius: 0.5.r,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ============================================================================
/// ودجت الترحيب والهوية التنفيذية بتسلسل هرمي واضح ومريح
/// ============================================================================
class _ExecutiveGreetingIdentity extends StatelessWidget {
  final String greeting;
  final String userShortName;
  final String roleLabel;

  const _ExecutiveGreetingIdentity({
    required this.greeting,
    required this.userShortName,
    required this.roleLabel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // السطر العلوي: التحية + نقطة الفصل + الدور الوظيفي
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              greeting,
              style: AppTypography.labelSmall.copyWith(
                color: colors.onSurfaceVariant,
                fontSize: 10.5.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                '•',
                style: AppTypography.labelSmall.copyWith(
                  color: colors.outlineVariant.withValues(alpha: 0.8),
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Flexible(
              child: Text(
                roleLabel,
                style: AppTypography.labelSmall.copyWith(
                  color: colors.primary,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),

        AppSpacing.vXxs,

        // السطر الأساسي: الاسم التنفيذي العريض
        Text(
          userShortName,
          style: AppTypography.titleMedium.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
            fontSize: 15.sp,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

/// ============================================================================
/// الحاوية الأساسية للزر الزجاجي الحر (Floating Glass Action Orb)
/// ============================================================================
class _GlassActionOrb extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final String? tooltip;

  const _GlassActionOrb({
    required this.child,
    required this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final effectiveBg =
        backgroundColor ??
        colors.surfaceContainerHighest.withValues(alpha: 0.32);
    final effectiveBorder =
        borderColor ?? colors.outlineVariant.withValues(alpha: 0.18);

    final orb = CustomInteractiveBounce(
      onTap: onTap,
      child: Container(
        width: 38.r,
        height: 38.r,
        decoration: BoxDecoration(
          borderRadius: AppRadius.mdRadius,
          color: effectiveBg,
          // shape: BoxShape.circle,
          border: Border.all(color: effectiveBorder, width: 1.w),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(alpha: 0.03),
              blurRadius: 6.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: orb);
    }
    return orb;
  }
}

/// ============================================================================
/// زر الخصوصية وحجب الأرقام الزجاجي الحر
/// ============================================================================
class _PrivacyActionOrb extends StatelessWidget {
  const _PrivacyActionOrb();

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<DashboardController>()) {
      return const SizedBox.shrink();
    }
    final dashboardCtrl = Get.find<DashboardController>();
    final colors = context.colors;

    return Obx(() {
      final isMasked = dashboardCtrl.isPrivacyMasked.value;
      return _GlassActionOrb(
        tooltip: isMasked ? 'إظهار الأرصدة المالية' : 'إخفاء الأرصدة المالية',
        backgroundColor: isMasked
            ? colors.primary.withValues(alpha: 0.14)
            : colors.surfaceContainerHighest.withValues(alpha: 0.32),
        borderColor: isMasked
            ? colors.primary.withValues(alpha: 0.32)
            : colors.outlineVariant.withValues(alpha: 0.18),
        onTap: () {
          HapticFeedback.lightImpact();
          dashboardCtrl.togglePrivacyMask();
        },
        child: Icon(
          isMasked ? Icons.visibility_off_rounded : Icons.visibility_outlined,
          size: 19.r,
          color: isMasked ? colors.primary : colors.onSurfaceVariant,
        ),
      );
    });
  }
}

/// ============================================================================
/// زر تبديل المظهر الزجاجي الحر بتأثير Circular Reveal
/// ============================================================================
class _ThemeActionOrb extends StatelessWidget {
  const _ThemeActionOrb();

  void _onTap(BuildContext context) {
    final switcher = CustomThemeSwitcher.of(context);

    if (switcher != null) {
      final renderBox = context.findRenderObject() as RenderBox?;
      final origin = renderBox != null
          ? renderBox.localToGlobal(renderBox.size.center(Offset.zero))
          : Offset.zero;

      switcher.switchTheme(
        origin: origin,
        onThemeChange: ThemeService.to.toggleTheme,
      );
    } else {
      ThemeService.to.toggleTheme();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeService = ThemeService.to;

    return Obx(() {
      final isDark = themeService.isDarkMode;
      final colors = context.colors;

      return _GlassActionOrb(
        tooltip: isDark
            ? 'التبديل إلى الوضع الفاتح'
            : 'التبديل إلى الوضع الداكن',
        onTap: () => _onTap(context),
        child: AnimatedSwitcher(
          duration: AppMotion.duration(context, AppMotion.slow),
          transitionBuilder: (child, animation) {
            return RotationTransition(
              turns: Tween<double>(begin: 0.75, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: AppMotion.springy),
              ),
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: AppMotion.standard,
                ),
                child: ScaleTransition(
                  scale: CurvedAnimation(
                    parent: animation,
                    curve: AppMotion.emphasized,
                  ),
                  child: child,
                ),
              ),
            );
          },
          child: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            key: ValueKey<bool>(isDark),
            size: 19.r,
            color: isDark ? colors.warning : colors.onSurfaceVariant,
          ),
        ),
      );
    });
  }
}

/// ============================================================================
/// زر جرس الإشعارات الزجاجي الحر مع شارة العداد اللحظي
/// ============================================================================
class _NotificationActionOrb extends StatelessWidget {
  final RxInt unreadCount;
  final VoidCallback onTap;

  const _NotificationActionOrb({
    required this.unreadCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      final count = unreadCount.value;

      return _GlassActionOrb(
        tooltip: count > 0 ? '$count إشعارات جديدة' : 'الإشعارات',
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 20.r,
              color: colors.onSurfaceVariant,
            ),
            if (count > 0)
              PositionedDirectional(
                top: -2.h,
                end: -2.w,
                child: Container(
                  width: 8.5.r,
                  height: 8.5.r,
                  decoration: BoxDecoration(
                    color: colors.error,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.surface, width: 1.8.w),
                    boxShadow: [
                      BoxShadow(
                        color: colors.error.withValues(alpha: 0.55),
                        blurRadius: 4.r,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}
