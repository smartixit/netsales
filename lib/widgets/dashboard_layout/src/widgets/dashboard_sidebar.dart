import 'package:flutter/material.dart';

import '../models/dashboard_navigation_item.dart';
import '../theme/dashboard_layout_theme.dart';

class DashboardSidebar extends StatelessWidget {
  const DashboardSidebar({
    required this.navigation,
    required this.selectedNavigationId,
    required this.onNavigationSelected,
    this.collapsed = false,
    this.onCollapsedChanged,
    this.header,
    this.footer,
    this.expandedGroupIds = const {},
    this.onGroupExpansionChanged,
    super.key,
  });

  final DashboardNavigationSection navigation;
  final String? selectedNavigationId;
  final ValueChanged<String> onNavigationSelected;
  final bool collapsed;
  final ValueChanged<bool>? onCollapsedChanged;
  final Widget? header;
  final Widget? footer;
  final Set<String> expandedGroupIds;
  final ValueChanged<String>? onGroupExpansionChanged;

  @override
  Widget build(BuildContext context) {
    final theme = DashboardLayoutTheme.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: theme.sidebarBackground,
      child: Column(
        children: [
          if (header != null)
            Padding(
              padding: EdgeInsets.all(theme.sidebarPadding),
              child: header,
            ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: theme.sidebarPadding,
                vertical: 8,
              ),
              children: [
                for (final item in navigation.items)
                  _NavigationTile(
                    item: item,
                    collapsed: collapsed,
                    selectedNavigationId: selectedNavigationId,
                    onSelected: onNavigationSelected,
                  ),
                for (final group in navigation.groups) ...[
                  SizedBox(height: theme.sectionSpacing),
                  if (!collapsed)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(
                        start: 12,
                        bottom: 8,
                      ),
                      child: Text(
                        group.label.toUpperCase(),
                        style: textTheme.labelSmall?.copyWith(
                          color: theme.sidebarMuted,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  for (final item in group.items)
                    _NavigationTile(
                      item: item,
                      collapsed: collapsed,
                      selectedNavigationId: selectedNavigationId,
                      onSelected: onNavigationSelected,
                      expanded: group.id != null &&
                          expandedGroupIds.contains(group.id),
                      onExpandedChanged: group.id == null ||
                              onGroupExpansionChanged == null
                          ? null
                          : (_) => onGroupExpansionChanged!(group.id!),
                    ),
                ],
              ],
            ),
          ),
          if (footer != null)
            Padding(
              padding: EdgeInsets.all(theme.sidebarPadding),
              child: footer,
            ),
        ],
      ),
    );
  }
}

class _NavigationTile extends StatelessWidget {
  const _NavigationTile({
    required this.item,
    required this.collapsed,
    required this.selectedNavigationId,
    required this.onSelected,
    this.expanded = false,
    this.onExpandedChanged,
    this.depth = 0,
  });

  final DashboardNavigationItem item;
  final bool collapsed;
  final String? selectedNavigationId;
  final ValueChanged<String> onSelected;
  final bool expanded;
  final ValueChanged<bool>? onExpandedChanged;
  final int depth;

  bool _containsSelected(DashboardNavigationItem item) {
    if (item.id == selectedNavigationId) return true;
    return item.children.any(_containsSelected);
  }

  @override
  Widget build(BuildContext context) {
    final theme = DashboardLayoutTheme.of(context);
    final selected = _containsSelected(item);
    final color = selected
        ? theme.sidebarSelectedForeground
        : item.enabled
            ? theme.sidebarForeground
            : theme.sidebarMuted;
    final leading = Icon(
      selected ? (item.selectedIcon ?? item.icon) : item.icon,
      size: 20,
      color: color,
    );

    if (item.hasChildren && !collapsed) {
      return Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          listTileTheme: const ListTileThemeData(dense: true),
        ),
        child: ExpansionTile(
          key: PageStorageKey<String>('dashboard-nav-${item.id}'),
          initiallyExpanded: expanded || selected,
          tilePadding: EdgeInsetsDirectional.only(
            start: 12 + depth * 12,
            end: 8,
          ),
          childrenPadding: EdgeInsetsDirectional.only(
            start: 12 + depth * 12,
          ),
          leading: leading,
          title: Text(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
          trailing: item.badge == null ? null : _Badge(label: item.badge!),
          onExpansionChanged: onExpandedChanged,
          children: item.children
              .map(
                (child) => _NavigationTile(
                  item: child,
                  collapsed: false,
                  selectedNavigationId: selectedNavigationId,
                  onSelected: onSelected,
                  depth: depth + 1,
                ),
              )
              .toList(),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(bottom: theme.itemSpacing),
      child: Tooltip(
        message: collapsed ? (item.tooltip ?? item.label) : '',
        child: Material(
          color: selected ? theme.sidebarSelectedBackground : Colors.transparent,
          borderRadius: BorderRadius.circular(theme.itemRadius),
          child: InkWell(
            borderRadius: BorderRadius.circular(theme.itemRadius),
            onTap: item.enabled && !item.hasChildren
                ? () => onSelected(item.id)
                : null,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: collapsed ? 0 : 12 + depth * 12,
                vertical: 12,
              ),
              child: Row(
                mainAxisAlignment: collapsed
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                children: [
                  leading,
                  if (!collapsed) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: color,
                              fontWeight: selected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                      ),
                    ),
                    if (item.badge != null) _Badge(label: item.badge!),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = DashboardLayoutTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: theme.badgeBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: theme.badgeForeground,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
