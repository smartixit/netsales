import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/text_formatter.dart';
import 'package:netsales/features/home/presentation/controllers/home_layout_controller.dart';
import 'package:netsales/widgets/animations/custom_interactive_bounce.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/buttons/custom_theme_toggle_button.dart';
import 'package:netsales/widgets/images/custom_cached_image.dart';

/// ============================================================================
/// ترويسة التطبيق الرئيسية السياقية (HomeAppBar)
/// ============================================================================
/// ترويسة أنيقة تعرض هوية المستخدم النشط، دوره، زر تبديل الثيم، وجرس الإشعارات.
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final HomeLayoutController controller;

  const HomeAppBar({
    super.key,
    required this.controller,
  });

  @override
  Size get preferredSize => Size.fromHeight(64.h);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          bottom: BorderSide(
            color: colors.outlineVariant.withValues(alpha: 0.4),
            width: 1.w,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.cardPadding,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            children: [
              // 1. صورة أو بادئة الملف الشخصي للمستخدم
              Obx(
                () => _UserAvatarWidget(
                  logoUrl: controller.userProfileLogo,
                  fullName: controller.userFullName,
                  onTap: () => controller.changeTab(3), // الذهاب للمزيد/الملف الشخصي
                ),
              ),

              AppSpacing.hSm,

              // 2. اسم المستخدم المختصر وشارة الدور المعتمد
              Expanded(
                child: Obx(
                  () => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.userShortName,
                        style: AppTypography.titleSmall.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      AppSpacing.vXxs,
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                          vertical: 1.h,
                        ),
                        decoration: BoxDecoration(
                          color: colors.primaryContainer.withValues(alpha: 0.6),
                          borderRadius: AppRadius.xsRadius,
                        ),
                        child: Text(
                          controller.userRoleLabel,
                          style: AppTypography.labelSmall.copyWith(
                            color: colors.onPrimaryContainer,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              AppSpacing.hXs,

              // 3. زر تبديل الثيم الدائري الخاطف (Light/Dark Mode)
              const CustomThemeToggleButton(),

              AppSpacing.hXs,

              // 4. زر جرس الإشعارات مع شارة العداد الحي
              _NotificationBellButton(
                unreadCount: controller.unreadNotificationsCount,
                onTap: () => Get.toNamed(AppRoutes.notifications),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ودجت صورة الملف الشخصي المستقلة
class _UserAvatarWidget extends StatelessWidget {
  final String? logoUrl;
  final String fullName;
  final VoidCallback onTap;

  const _UserAvatarWidget({
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
      child: Container(
        width: 42.r,
        height: 42.r,
        decoration: BoxDecoration(
          color: colors.primary.withValues(alpha: 0.12),
          shape: BoxShape.circle,
          border: Border.all(
            color: colors.primary.withValues(alpha: 0.25),
            width: 1.2.w,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: CustomCachedImage.avatar(
          url: logoUrl,
          radius: 21.r,
          fallbackText: initials,
        ),
      ),
    );
  }
}

/// ودجت جرس الإشعارات المستقلة مع الشارة
class _NotificationBellButton extends StatelessWidget {
  final RxInt unreadCount;
  final VoidCallback onTap;

  const _NotificationBellButton({
    required this.unreadCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        CustomButton.icon(
          icon: Icons.notifications_none_rounded,
          foregroundColor: colors.onSurface,
          backgroundColor: Colors.transparent,
          dimension: 40.r,
          iconSize: 22.r,
          onPressed: onTap,
        ),
        Obx(() {
          final count = unreadCount.value;
          if (count <= 0) return const SizedBox.shrink();

          return PositionedDirectional(
            top: 4.h,
            end: 4.w,
            child: Container(
              padding: EdgeInsets.all(AppSpacing.xxs),
              decoration: BoxDecoration(
                color: colors.error,
                shape: BoxShape.circle,
                border: Border.all(color: colors.surface, width: 1.5.w),
              ),
              constraints: BoxConstraints(minWidth: 10.r, minHeight: 10.r),
            ),
          );
        }),
      ],
    );
  }
}
