import 'package:flutter/material.dart';

class ProcurementDetailsMetricData {
  const ProcurementDetailsMetricData({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.accentColor,
    this.isPrimary = false,
    this.caption,
  });

  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color accentColor;
  final bool isPrimary;
  final String? caption;
}
