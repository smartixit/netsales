import 'package:flutter/material.dart';

import '../config/dashboard_layout_config.dart';
import '../models/dashboard_breadcrumb.dart';
import '../models/dashboard_navigation_item.dart';
import '../models/dashboard_user_profile.dart';
import '../theme/dashboard_layout_theme.dart';
import '../widgets/dashboard_page_header.dart';
import '../widgets/dashboard_sidebar.dart';
import '../widgets/dashboard_topbar.dart';

class DashboardShell extends StatelessWidget {
  const DashboardShell({
    required this.child,
    required this.navigation,
    required this.selectedNavigationId,
    required this.onNavigationSelected,
    this.config = const DashboardLayoutConfig(),
    this.sidebarHeader,
    this.sidebarFooter,
    this.topbarLeading,
    this.search,
    this.notifications,
    this.topbarActions,
    this.profile,
    this.onProfileTap,
    this.breadcrumbs = const [],
    this.onBreadcrumbTap,
    this.pageHeader,
    this.sidebarCollapsed = false,
    this.onSidebarCollapsedChanged,
    this.expandedGroupIds = const {},
    this.onGroupExpansionChanged,
    this.content,
    super.key,
  });

  final Widget child;
  final DashboardNavigationSection navigation;
  final String? selectedNavigationId;
  final ValueChanged<String> onNavigationSelected;
  final DashboardLayoutConfig config;
  final Widget? sidebarHeader;
  final Widget? sidebarFooter;
  final Widget? topbarLeading;
  final Widget? search;
  final Widget? notifications;
  final List<Widget>? topbarActions;
  final DashboardUserProfile? profile;
  final VoidCallback? onProfileTap;
  final List<DashboardBreadcrumb> breadcrumbs;
  final ValueChanged<String>? onBreadcrumbTap;
  final DashboardPageHeaderData? pageHeader;
  final bool sidebarCollapsed;
  final ValueChanged<bool>? onSidebarCollapsedChanged;
  final Set<String> expandedGroupIds;
  final ValueChanged<String>? onGroupExpansionChanged;
  final Widget? content;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < config.mobileBreakpoint;
        final theme = DashboardLayoutTheme.of(context);
        final sidebar = DashboardSidebar(
          navigation: navigation,
          selectedNavigationId: selectedNavigationId,
          onNavigationSelected: onNavigationSelected,
          collapsed: sidebarCollapsed,
          onCollapsedChanged: onSidebarCollapsedChanged,
          header: sidebarHeader,
          footer: sidebarFooter,
          expandedGroupIds: expandedGroupIds,
          onGroupExpansionChanged: onGroupExpansionChanged,
        );
        return Scaffold(
          backgroundColor: theme.contentBackground,
          drawer: isCompact
              ? Drawer(
                  width: config.expandedSidebarWidth,
                  child: SafeArea(child: sidebar),
                )
              : null,
          body: SafeArea(
            child: Row(
              children: [
                if (!isCompact)
                  AnimatedContainer(
                    duration: theme.motionDuration,
                    curve: theme.motionCurve,
                    width: sidebarCollapsed
                        ? config.collapsedSidebarWidth
                        : config.expandedSidebarWidth,
                    child: sidebar,
                  ),
                Expanded(
                  child: Column(
                    children: [
                      DashboardTopbar(
                        height: config.topbarHeight,
                        leading: isCompact
                            ? Builder(
                                builder: (context) => IconButton(
                                  tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
                                  onPressed: () => Scaffold.of(context).openDrawer(),
                                  icon: const Icon(Icons.menu_rounded),
                                ),
                              )
                            : topbarLeading ??
                                (onSidebarCollapsedChanged == null
                                    ? null
                                    : IconButton(
                                        tooltip: sidebarCollapsed
                                            ? 'Expand navigation'
                                            : 'Collapse navigation',
                                        onPressed: () => onSidebarCollapsedChanged!(!sidebarCollapsed),
                                        icon: Icon(sidebarCollapsed
                                            ? Icons.menu_open_rounded
                                            : Icons.menu_rounded),
                                      )),
                        search: search,
                        notifications: notifications,
                        actions: topbarActions,
                        profile: profile,
                        onProfileTap: onProfileTap,
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.all(config.contentPadding ?? theme.contentPadding),
                          child: Align(
                            alignment: AlignmentDirectional.topCenter,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: config.maxContentWidth ?? double.infinity,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (config.showBreadcrumbs && breadcrumbs.isNotEmpty)
                                    _BreadcrumbRow(
                                      breadcrumbs: breadcrumbs,
                                      onTap: onBreadcrumbTap,
                                    ),
                                  if (pageHeader != null) ...[
                                    const SizedBox(height: 12),
                                    DashboardPageHeader(data: pageHeader!),
                                  ],
                                  if (pageHeader != null) const SizedBox(height: 20),
                                  content ?? child,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BreadcrumbRow extends StatelessWidget {
  const _BreadcrumbRow({required this.breadcrumbs, this.onTap});

  final List<DashboardBreadcrumb> breadcrumbs;
  final ValueChanged<String>? onTap;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall;
    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      children: [
        for (var index = 0; index < breadcrumbs.length; index++) ...[
          if (index > 0)
            Icon(
              Directionality.of(context) == TextDirection.rtl
                  ? Icons.chevron_left_rounded
                  : Icons.chevron_right_rounded,
              size: 16,
              color: scheme.onSurfaceVariant,
            ),
          InkWell(
            onTap: breadcrumbs[index].enabled && breadcrumbs[index].id != null && onTap != null
                ? () => onTap!(breadcrumbs[index].id!)
                : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (breadcrumbs[index].icon != null) ...[
                    Icon(breadcrumbs[index].icon, size: 14, color: scheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    breadcrumbs[index].label,
                    style: style?.copyWith(
                      color: index == breadcrumbs.length - 1
                          ? scheme.onSurface
                          : scheme.onSurfaceVariant,
                      fontWeight: index == breadcrumbs.length - 1
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
