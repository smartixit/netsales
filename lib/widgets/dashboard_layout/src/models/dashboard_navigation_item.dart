import 'package:flutter/material.dart';

@immutable
class DashboardNavigationItem {
  const DashboardNavigationItem({
    required this.id,
    required this.label,
    required this.icon,
    this.selectedIcon,
    this.enabled = true,
    this.badge,
    this.tooltip,
    this.children = const [],
  }) : assert(id != ''),
       assert(children.length == 0 || children.length <= 20);

  final String id;
  final String label;
  final IconData icon;
  final IconData? selectedIcon;
  final bool enabled;
  final String? badge;
  final String? tooltip;
  final List<DashboardNavigationItem> children;

  bool get hasChildren => children.isNotEmpty;
}

@immutable
class DashboardNavigationGroup {
  const DashboardNavigationGroup({
    required this.label,
    required this.items,
    this.id,
  });

  final String? id;
  final String label;
  final List<DashboardNavigationItem> items;
}

@immutable
class DashboardNavigationSection {
  const DashboardNavigationSection({
    this.groups = const [],
    this.items = const [],
  });

  final List<DashboardNavigationGroup> groups;
  final List<DashboardNavigationItem> items;
}
