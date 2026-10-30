import 'package:flutter/material.dart';

class DashboardQuickActionEntity {
  final IconData icon;
  final String label;
  final List<Color> gradientColors;
  final String permission;
  final VoidCallback? onTap;

  DashboardQuickActionEntity({
    required this.icon,
    required this.label,
    required this.gradientColors,
    required this.permission,
    this.onTap,
  });
}
