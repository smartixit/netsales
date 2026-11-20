import 'package:flutter/material.dart';

/// بيانات عقدة التدقيق الزمني في مسار دورة حياة المعاملة
class DocumentTimelineNodeData {
  const DocumentTimelineNodeData({
    required this.title,
    required this.subtitle,
    this.timestamp,
    required this.icon,
    this.iconColor,
    this.isCompleted = false,
    this.isLast = false,
  });

  final String title;
  final String subtitle;
  final String? timestamp;
  final IconData icon;
  final Color? iconColor;
  final bool isCompleted;
  final bool isLast;
}
