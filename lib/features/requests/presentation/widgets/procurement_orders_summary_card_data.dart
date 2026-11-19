import 'package:flutter/material.dart';

class ProcurementOrdersSummaryCardData {
  const ProcurementOrdersSummaryCardData({
    required this.label,
    required this.count,
    required this.statusValue,
    required this.icon,
    required this.accentColor,
  });

  final String label;
  final int count;
  final String? statusValue;
  final IconData icon;
  final Color accentColor;
}
