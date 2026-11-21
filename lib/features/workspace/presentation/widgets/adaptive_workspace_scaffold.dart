import 'package:flutter/material.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/workspace/presentation/widgets/workspace_app_bar.dart';
import 'package:netsales/features/workspace/presentation/widgets/workspace_nav_item.dart';
import 'package:netsales/widgets/navigations/custom_floating_bottom_nav_bar.dart';

/// Adaptive shell with exactly four primary phone destinations.
class AdaptiveWorkspaceScaffold extends StatelessWidget {
  const AdaptiveWorkspaceScaffold({
    super.key,
    required this.appBar,
    required this.items,
    required this.mobileItems,
    required this.currentIndex,
    required this.mobileCurrentIndex,
    required this.onIndexChanged,
    this.onCenterActionTap,
    this.centerActionIcon = Icons.add_rounded,
    this.centerActionTooltip,
  }) : assert(mobileItems.length == 4);

  final WorkspaceAppBar appBar;
  final List<WorkspaceNavItem> items;
  final List<WorkspaceNavItem> mobileItems;
  final int currentIndex;
  final int mobileCurrentIndex;
  final ValueChanged<int> onIndexChanged;
  final VoidCallback? onCenterActionTap;
  final IconData centerActionIcon;
  final String? centerActionTooltip;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final activeIndex = currentIndex >= 0 && currentIndex < items.length
        ? currentIndex
        : 0;
    final activeMobileIndex = mobileCurrentIndex >= 0 && mobileCurrentIndex < 4
        ? mobileCurrentIndex
        : 0;

    if (AppBreakpoints.usesBottomBar(context)) {
      final floatingItems = mobileItems
          .map(
            (item) => CustomFloatingNavItem(
              icon: item.icon,
              activeIcon: item.activeIcon,
              label: item.label,
              badgeCount: item.badgeCount,
              tooltip: item.tooltip,
            ),
          )
          .toList(growable: false);
      return Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        backgroundColor: colors.background,
        appBar: appBar,
        body: SafeArea(
          top: false,
          bottom: false,
          child: items[activeIndex].content,
        ),
        bottomNavigationBar: CustomFloatingBottomNavBar(
          currentIndex: activeMobileIndex,
          onTap: (index) {
            if (index < 0 || index >= mobileItems.length) return;
            final target = items.indexOf(mobileItems[index]);
            if (target >= 0) onIndexChanged(target);
          },
          items: floatingItems,
          onCenterActionTap: onCenterActionTap,
          centerActionIcon: centerActionIcon,
          centerActionTooltip: centerActionTooltip,
        ),
      );
    }

    final navigation = AppBreakpoints.usesNavigationDrawer(context)
        ? SizedBox(
            width: AppBreakpoints.maxDrawerWidth,
            child: NavigationDrawer(
              selectedIndex: activeIndex,
              onDestinationSelected: onIndexChanged,
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(
                    AppBreakpoints.screenMargin(context),
                    AppBreakpoints.screenMargin(context),
                    AppBreakpoints.screenMargin(context),
                    AppBreakpoints.gridGutter(context),
                  ),
                  child: Text(
                    'مساحة العمل',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                for (final item in items)
                  NavigationDrawerDestination(
                    icon: Icon(item.icon),
                    selectedIcon: Icon(item.activeIcon),
                    label: SizedBox(
                      width: AppBreakpoints.maxDrawerWidth - 112,
                      child: Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
              ],
            ),
          )
        : NavigationRail(
            selectedIndex: activeIndex,
            onDestinationSelected: onIndexChanged,
            backgroundColor: colors.surface,
            indicatorColor: colors.primary.withValues(alpha: 0.15),
            labelType: NavigationRailLabelType.all,
            destinations: items
                .map(
                  (item) => NavigationRailDestination(
                    icon: Icon(item.icon, color: colors.onSurfaceVariant),
                    selectedIcon: Icon(item.activeIcon, color: colors.primary),
                    label: Text(item.label),
                  ),
                )
                .toList(growable: false),
          );

    return Scaffold(
      backgroundColor: colors.background,
      appBar: appBar,
      body: SafeArea(
        child: Row(
          children: [
            navigation,
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
