import 'package:flutter/foundation.dart';

@immutable
class DashboardLayoutConfig {
  const DashboardLayoutConfig({
    this.expandedSidebarWidth = 264,
    this.collapsedSidebarWidth = 76,
    this.topbarHeight = 72,
    this.contentPadding = 28,
    this.mobileBreakpoint = 900,
    this.maxContentWidth,
    this.initiallyCollapsed = false,
    this.showBreadcrumbs = true,
  }) : assert(expandedSidebarWidth > collapsedSidebarWidth),
       assert(collapsedSidebarWidth >= 56),
       assert(mobileBreakpoint > 0);

  final double expandedSidebarWidth;
  final double collapsedSidebarWidth;
  final double topbarHeight;
  final double contentPadding;
  final double mobileBreakpoint;
  final double? maxContentWidth;
  final bool initiallyCollapsed;
  final bool showBreadcrumbs;
}
