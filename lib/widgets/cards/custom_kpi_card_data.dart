import 'package:flutter/material.dart';

/// بيانات بطاقة مؤشر الأداء التفاعلية للمكون العام CustomKpiSummaryCard
class CustomKpiCardData {
  final String label;
  final int count;
  final IconData icon;
  final Color accentColor;
  final String? statusKey;

  const CustomKpiCardData({
    required this.label,
    required this.count,
    required this.icon,
    required this.accentColor,
    this.statusKey,
  });
}
