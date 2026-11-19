import 'package:flutter/material.dart';
import 'package:netsales/core/themes/app_colors.dart';

/// نبرات المعنى البصري الموحدة للشارات والرقاقات (Semantic Visual Tones)
/// تُستخدم كطبقة وسيطة تفصل بين مفاهيم الـ Enums في النطاق وطبقة الألوان والسمات البصرية
enum SemanticTone {
  /// حالة إيجابية، اعتماد، نجاح، نشط (أخضر / Success)
  success,

  /// حالة تحذيرية، انتظار، مراجعة، سداد جزئي (برتقالي / Warning)
  warning,

  /// حالة سلبية، حظر، رفض، فشل، إلغاء (أحمر / Error / Danger)
  danger,

  /// حالة معلوماتية أو توجيهية (أزرق / Info)
  info,

  /// حالة حيادية للأجهزة، الأدوار، التصنيفات، أو القيم المجهولة (رمادي / Neutral)
  neutral,

  /// تمييز بعلامة النظام الأساسية عند الحاجة (Primary)
  primary;

  /// اللون النبري المنسجم مع سمات النظام
  Color color(BuildContext context) => resolveColor(context.colors);

  /// استخراج اللون مباشرة من كائن AppColors
  Color resolveColor(AppColors colors) {
    switch (this) {
      case SemanticTone.success:
        return colors.success;
      case SemanticTone.warning:
        return colors.warning;
      case SemanticTone.danger:
        return colors.error;
      case SemanticTone.info:
        return colors.info;
      case SemanticTone.primary:
        return colors.primary;
      case SemanticTone.neutral:
        return colors.onSurfaceVariant;
    }
  }
}
