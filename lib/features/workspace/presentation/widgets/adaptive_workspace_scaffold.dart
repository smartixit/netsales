import 'package:flutter/material.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/workspace/presentation/widgets/workspace_app_bar.dart';
import 'package:netsales/features/workspace/presentation/widgets/workspace_nav_item.dart';
import 'package:netsales/widgets/navigations/custom_floating_bottom_nav_bar.dart';

/// Shared adaptive shell: bottom bar on portrait phones, rail on compact-height
/// phones/tablets, and a persistent drawer on desktop-sized windows.
class AdaptiveWorkspaceScaffold extends StatelessWidget {
  const AdaptiveWorkspaceScaffold({
    super.key,
    required this.appBar,
    required this.items,
    this.mobileItems,
    required this.currentIndex,
    required this.onIndexChanged,
    this.onCenterActionTap,
    this.centerActionIcon = Icons.add_rounded,
    this.centerActionTooltip,
  });

  final WorkspaceAppBar appBar;
  final List<WorkspaceNavItem> items;
  final List<WorkspaceNavItem>? mobileItems;
  final int currentIndex;
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

    if (AppBreakpoints.usesBottomBar(context)) {
      final effectiveNavList = mobileItems ?? items;
      final floatingItems = effectiveNavList
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

      final currentItem = items[activeIndex];
      final mobileActiveIndex = mobileItems == null
          ? activeIndex
          : mobileItems!.indexOf(currentItem);

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
          currentIndex: mobileActiveIndex < 0 ? 0 : mobileActiveIndex,
          onTap: (navIndex) {
            final target = mobileItems == null
                ? navIndex
                : items.indexOf(mobileItems![navIndex]);
            if (target >= 0 && target < items.length) {
              onIndexChanged(target);
            }
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
                    'مساحات العمل',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                for (final item in items)
                  NavigationDrawerDestination(
                    icon: Icon(item.icon),
                    selectedIcon: Icon(item.activeIcon),
                    label: Text(item.label),
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
