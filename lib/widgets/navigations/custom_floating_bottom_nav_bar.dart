import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_gradients.dart';
import 'package:netsales/core/themes/app_motion.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// ============================================================================
/// نموذج بيانات عنصر التنقل لشريط التنقل العائم الموحد (CustomFloatingNavItem)
/// ============================================================================
class CustomFloatingNavItem {
  /// الأيقونة في الحالة غير النشطة
  final IconData icon;

  /// الأيقونة في الحالة النشطة
  final IconData activeIcon;

  /// التسمية النصية للتبويب
  final String label;

  /// عداد الإشعارات أو التنبيهات على التبويب (اختياري)
  final int? badgeCount;

  /// تلميح إمكانية الوصول والتفاعل (اختياري)
  final String? tooltip;

  const CustomFloatingNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.badgeCount,
    this.tooltip,
  });
}

/// ============================================================================
/// شريط التنقل السفلي العائم بتصميم زجاجي موحد (CustomFloatingBottomNavBar)
/// ============================================================================
/// ودجت عامة نظيفة ومستقلة تماماً (Decoupled & Pure Generic UI Component)،
/// خالية من أي تبعيات خاصة بمتحكمات معينة ومطابقة لمعايير ميثاق الكود النظيف.
class CustomFloatingBottomNavBar extends StatelessWidget {
  /// مؤشر التبويب النشط حالياً
  final int currentIndex;

  /// دالة تغيير التبويب عند النقر
  final ValueChanged<int> onTap;

  /// قائمة عناصر التبويب
  final List<CustomFloatingNavItem> items;

  /// دالة النقر على زر الإجراء المركزي العائم (اختياري)
  final VoidCallback? onCenterActionTap;

  /// أيقونة زر الإجراء المركزي العائم (افتراضياً Icons.add_rounded)
  final IconData centerActionIcon;

  /// تلميح زر الإجراء المركزي العائم
  final String? centerActionTooltip;

  const CustomFloatingBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.onCenterActionTap,
    this.centerActionIcon = Icons.add_rounded,
    this.centerActionTooltip,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasCenterAction = onCenterActionTap != null;
    final halfLength = items.length ~/ 2;

    return SafeArea(
      top: false,
      child: Container(
        margin: EdgeInsets.fromLTRB(
          AppSpacing.cardPadding,
          0,
          AppSpacing.cardPadding,
          AppSpacing.cardPadding,
        ),
        height: 76.h,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        decoration: BoxDecoration(
          color: colors.surface.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(AppRadius.xxxl),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.5),
            width: 1.w,
          ),
          boxShadow: AppElevation.level4(context),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            for (int i = 0; i < items.length; i++) ...[
              if (hasCenterAction && i == halfLength)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                  child: FloatingCenterActionButton(
                    key: const ValueKey('nav_center_fab'),
                    icon: centerActionIcon,
                    tooltip: centerActionTooltip,
                    onTap: onCenterActionTap!,
                  ),
                ),
              Expanded(
                child: FloatingNavBarItemWidget(
                  key: ValueKey('nav_item_$i'),
                  item: items[i],
                  index: i,
                  isSelected: currentIndex == i,
                  onTap: () => onTap(i),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// ============================================================================
/// ودجت عنصر التنقل المستقلة (FloatingNavBarItemWidget)
/// ============================================================================
class FloatingNavBarItemWidget extends StatelessWidget {
  final CustomFloatingNavItem item;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;

  const FloatingNavBarItemWidget({
    super.key,
    required this.item,
    required this.index,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomInteractiveBounce(
      onTap: onTap,
      child: Tooltip(
        message: item.tooltip ?? item.label,
        child: AnimatedContainer(
          duration: AppMotion.fast,
          curve: AppMotion.standard,
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.xxs,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? colors.primary.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: isSelected
                  ? colors.primary.withValues(alpha: 0.25)
                  : Colors.transparent,
              width: 1.w,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              NavBadgeIconWidget(item: item, isSelected: isSelected),
              AppSpacing.vXxs,
              AnimatedDefaultTextStyle(
                duration: AppMotion.fast,
                curve: AppMotion.standard,
                style: AppTypography.labelSmall.copyWith(
                  color: isSelected
                      ? colors.primary
                      : colors.onSurfaceVariant.withValues(alpha: 0.75),
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 10.sp,
                ),
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ============================================================================
/// ودجت أيقونة التبويب مع شارة التنبيهات المستقلة (NavBadgeIconWidget)
/// ============================================================================
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

/// ============================================================================
/// ودجت زر الإجراء المركزي العائم المستقلة (FloatingCenterActionButton)
/// ============================================================================
class FloatingCenterActionButton extends StatelessWidget {
  final IconData icon;
  final String? tooltip;
  final VoidCallback onTap;

  const FloatingCenterActionButton({
    super.key,
    required this.icon,
    this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomInteractiveBounce(
      onTap: onTap,
      child: Tooltip(
        message: tooltip ?? 'إجراء سريع',
        child: Container(
          width: 50.r,
          height: 50.r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppGradients.financialHero(context),
            boxShadow: AppElevation.glow(
              context,
              colors.primary,
              alpha: 0.4,
              blur: 16.r,
            ),
          ),
          child: Center(
            child: Icon(icon, color: colors.onPrimary, size: 24.r),
          ),
        ),
      ),
    );
  }
}
