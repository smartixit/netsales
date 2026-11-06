import 'package:flutter/widgets.dart';

@immutable
class DashboardBreadcrumb {
  const DashboardBreadcrumb({
    required this.label,
    this.id,
    this.icon,
    this.enabled = true,
  });

  final String label;
  final String? id;
  final IconData? icon;
  final bool enabled;
}
