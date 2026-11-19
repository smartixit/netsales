import 'package:flutter/material.dart';

/// بيانات بطاقة الإحصائيات وعرض الأرقام للمكون العام CustomMetricDisplayCard
class CustomMetricCardData {
  final String label;
  final String value;
  final String? unit;
  final IconData icon;
  final Color accentColor;
  final bool isPrimary;
  final String? caption;

  const CustomMetricCardData({
    required this.label,
    required this.value,
    this.unit,
    required this.icon,
    required this.accentColor,
    this.isPrimary = false,
    this.caption,
  });
}
