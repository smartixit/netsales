import 'package:flutter/material.dart';

/// نموذج بيانات عنصر التنقل لشريط التنقل العائم الموحد (CustomFloatingNavItem)
class CustomFloatingNavItem {
  /// الأيقونة في الحالة غير النشطة
  final IconData icon;

  /// الأيقونة في الحالة النشطة
  final IconData activeIcon;

  /// التسمية النصية للتبويب
  final String label;

  /// عداد الإشعارات أو التنبيهات على التبويب (اختياري)
  final int? badgeCount;

  /// تلميح إمكانية الوصول والتفاعل (اختياري)
  final String? tooltip;

  const CustomFloatingNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.badgeCount,
    this.tooltip,
  });
}
