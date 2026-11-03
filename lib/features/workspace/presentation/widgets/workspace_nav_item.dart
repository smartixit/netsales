import 'package:flutter/material.dart';

/// عنصر التنقل في مساحة العمل
class WorkspaceNavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final Widget content;
  final int? badgeCount;
  final String? tooltip;

  const WorkspaceNavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.content,
    this.badgeCount,
    this.tooltip,
  });
}
