import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/widgets/navigations/custom_floating_nav_item.dart';
import 'package:netsales/widgets/navigations/floating_center_action_button.dart';
import 'package:netsales/widgets/navigations/floating_nav_bar_item_widget.dart';

export 'package:netsales/widgets/navigations/custom_floating_nav_item.dart';
export 'package:netsales/widgets/navigations/floating_center_action_button.dart';
export 'package:netsales/widgets/navigations/floating_nav_bar_item_widget.dart';
export 'package:netsales/widgets/navigations/nav_badge_icon_widget.dart';

/// ============================================================================
/// شريط التنقل السفلي العائم بتصميم زجاجي ضبابي موحد (CustomFloatingBottomNavBar - VIP Frosted Glass Dock)
/// ============================================================================
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasCenterAction = onCenterActionTap != null;
    final halfLength = items.length ~/ 2;

    return Align(
      alignment: Alignment.bottomCenter,
      heightFactor: 1.0,
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 520.w),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.cardPadding,
              0,
              AppSpacing.cardPadding,
              AppSpacing.cardPadding,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.xl),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  height: 68.h,
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF0F172A).withValues(alpha: 0.95)
                        : colors.surface.withValues(alpha: 0.96),
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.12)
                          : colors.outlineVariant.withValues(alpha: 0.8),
                      width: 1.w,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colors.shadow.withValues(
                          alpha: isDark ? 0.35 : 0.10,
                        ),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      for (int i = 0; i < items.length; i++) ...[
                        if (hasCenterAction && i == halfLength)
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.xxs,
                            ),
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}
