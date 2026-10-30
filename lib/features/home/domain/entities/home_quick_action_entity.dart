import 'package:flutter/material.dart';

/// ============================================================================
/// نموذج بيانات الإجراء السريع المستند إلى الصلاحيات (HomeQuickAction)
/// ============================================================================
/// يُعرّف إجراءً سريعاً يمكن للمستخدم تنفيذه من خلال الزر المركزي العائم
/// بناءً على الصلاحيات الممنوحة له من الواجهة الخلفية.
class HomeQuickActionEntity {
  /// المعرف الفريد للإجراء
  final String id;

  /// عنوان الإجراء باللغة العربية
  final String title;

  /// وصف موجز للإجراء وهدفه
  final String description;

  /// أيقونة الإجراء
  final IconData icon;

  /// مفتاح الصلاحية المطلوب لتنفيذ الإجراء
  final String requiredPermission;

  /// المسار المرتبط بالإجراء في شجرة المسارات (اختياري)
  final String? targetRoute;

  /// الدالة المخصصة للتنفيذ (اختياري)
  final VoidCallback? onExecute;

  const HomeQuickActionEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.requiredPermission,
    this.targetRoute,
    this.onExecute,
  });
}
