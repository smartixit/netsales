import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_motion.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/navigations/custom_floating_nav_item.dart';

/// ودجت أيقونة التبويب مع شارة التنبيهات المستقلة (NavBadgeIconWidget)
class NavBadgeIconWidget extends StatelessWidget {
  final CustomFloatingNavItem item;
  final bool isSelected;

  const NavBadgeIconWidget({
    super.key,
    required this.item,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final iconWidget = AnimatedSwitcher(
      duration: AppMotion.fast,
      switchInCurve: AppMotion.springy,
      switchOutCurve: AppMotion.standard,
      transitionBuilder: (child, animation) {
        return ScaleTransition(
          scale: animation,
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: Icon(
        isSelected ? item.activeIcon : item.icon,
        key: ValueKey('${item.label}_${isSelected ? 'active' : 'inactive'}'),
        color: isSelected
            ? colors.primary
            : colors.onSurfaceVariant.withValues(alpha: 0.75),
        size: 22.r,
      ),
    );

    if (item.badgeCount == null || item.badgeCount! <= 0) {
      return iconWidget;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        iconWidget,
        PositionedDirectional(
          top: -2.h,
          end: -6.w,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.xxs,
              vertical: 1.h,
            ),
            decoration: BoxDecoration(
              color: colors.error,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            constraints: BoxConstraints(minWidth: 14.r, minHeight: 14.r),
            child: Text(
              item.badgeCount! > 99 ? '99+' : '${item.badgeCount}',
              textAlign: TextAlign.center,
              style: AppTypography.labelSmall.copyWith(
                color: colors.onError,
                fontSize: 9.sp,
                height: 1.1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
