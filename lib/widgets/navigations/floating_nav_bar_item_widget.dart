import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_motion.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';
import 'package:netsales/widgets/navigations/custom_floating_nav_item.dart';
import 'package:netsales/widgets/navigations/nav_badge_icon_widget.dart';

/// ودجت عنصر التنقل المستقلة (FloatingNavBarItemWidget)
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
            horizontal: 6.w,
            vertical: 4.h,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? colors.primary.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.md),
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
              SizedBox(height: 2.h),
              AnimatedDefaultTextStyle(
                duration: AppMotion.fast,
                curve: AppMotion.standard,
                style: AppTypography.labelSmall.copyWith(
                  color: isSelected
                      ? colors.primary
                      : colors.onSurfaceVariant.withValues(alpha: 0.75),
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
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
