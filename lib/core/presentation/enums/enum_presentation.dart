import 'package:flutter/material.dart';
import 'package:netsales/core/presentation/enums/semantic_tone.dart';

/// وصف العرض الدلالي الموحد لقيم الـ Enums والحالات (Enum Presentation Metadata)
/// يمثل العقد النهائي غير القابل للتعديل الذي يستهلكه الـ Badge والـ Chip
class EnumPresentation {
  /// النص المعروض (Display Label) — يُفضل القيمة الصادرة من الخادم إن وُجدت
  final String label;

  /// النبرة الدلالية البصرية (Semantic Tone)
  final SemanticTone tone;

  /// أيقونة اختيارية تعبّر عن الحالة أو النوع
  final IconData? icon;

  /// وصف موجز اختياري لتلميحات الشاشة (Tooltip / Description)
  final String? description;

  /// ما إذا كانت القيمة معروفة في عقد النظام أم قيمة مستحدثة/مجهولة
  final bool isKnown;

  const EnumPresentation({
    required this.label,
    required this.tone,
    this.icon,
    this.description,
    this.isKnown = true,
  });

  /// إنشاء تمثيل آمن ومحايد لأي حالة مجهولة
  factory EnumPresentation.unknown({String? rawValue, String? fallbackLabel}) {
    return EnumPresentation(
      label:
          fallbackLabel ??
          (rawValue != null && rawValue.isNotEmpty ? rawValue : 'غير معروف'),
      tone: SemanticTone.neutral,
      icon: Icons.help_outline_rounded,
      isKnown: false,
    );
  }
}
