import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/workspace/presentation/widgets/workspace_app_bar.dart';
import 'package:netsales/features/workspace/presentation/widgets/workspace_nav_item.dart';
import 'package:netsales/widgets/navigations/custom_floating_bottom_nav_bar.dart';

/// الهيكل التكيفي الموحد لمساحات العمل (AdaptiveWorkspaceScaffold)
/// يتكيف تلقائياً بين شاشات الهواتف (CustomFloatingBottomNavBar بتصميم زجاجي عائم فخم)
/// والأجهزة اللوحية (NavigationRail المتجاوبة)
class AdaptiveWorkspaceScaffold extends StatelessWidget {
  final WorkspaceAppBar appBar;
  final List<WorkspaceNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;
  final VoidCallback? onCenterActionTap;
  final IconData centerActionIcon;
  final String? centerActionTooltip;

  const AdaptiveWorkspaceScaffold({
    super.key,
    required this.appBar,
    required this.items,
    required this.currentIndex,
    required this.onIndexChanged,
    this.onCenterActionTap,
    this.centerActionIcon = Icons.add_rounded,
    this.centerActionTooltip,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isMobile = AppBreakpoints.isMobile(context);
    final activeIndex = (currentIndex >= 0 && currentIndex < items.length)
        ? currentIndex
        : 0;

    if (isMobile) {
      final floatingItems = items.map((item) {
        return CustomFloatingNavItem(
          icon: item.icon,
          activeIcon: item.activeIcon,
          label: item.label,
          badgeCount: item.badgeCount,
          tooltip: item.tooltip,
        );
      }).toList();

      return Scaffold(
        extendBody: true,
        appBar: appBar,
        body: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.only(bottom: 84.h),
            child: items[activeIndex].content,
          ),
        ),
        bottomNavigationBar: CustomFloatingBottomNavBar(
          currentIndex: activeIndex,
          onTap: onIndexChanged,
          items: floatingItems,
          onCenterActionTap: onCenterActionTap,
          centerActionIcon: centerActionIcon,
          centerActionTooltip: centerActionTooltip,
        ),
      );
    }

    // للشاشات اللوحية والمكتبية (Tablet & Desktop): استخدام Navigation Rail
    return Scaffold(
      appBar: appBar,
      body: SafeArea(
        child: Row(
          children: [
            NavigationRail(
              selectedIndex: activeIndex,
              onDestinationSelected: onIndexChanged,
              backgroundColor: colors.surface,
              indicatorColor: colors.primary.withValues(alpha: 0.15),
              labelType: NavigationRailLabelType.all,
              destinations: items.map((item) {
                return NavigationRailDestination(
                  icon: Icon(item.icon, color: colors.onSurfaceVariant),
                  selectedIcon: Icon(item.activeIcon, color: colors.primary),
                  label: Text(item.label),
                );
              }).toList(),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppBreakpoints.maxContentWidth,
                  ),
                  child: items[activeIndex].content,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
