import 'package:flutter/material.dart';

/// بيانات عمود القياس المالي/التشغيلي في سكة البطاقة التنفيذية
class ExecutiveCardMetricData {
  const ExecutiveCardMetricData({
    required this.label,
    required this.value,
    this.textColor,
    this.isEmphasized = false,
    this.flex = 1,
  });

  final String label;
  final String value;
  final Color? textColor;
  final bool isEmphasized;
  final int flex;
}
