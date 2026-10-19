import 'package:flutter/material.dart';

/// نظام الارتفاع/الظلال الموحّد.
///
/// بديل لأي `BoxShadow` صريح في الشاشات. الظلال تُبنى من `colorScheme.shadow`
/// وتتكيّف تلقائياً مع الوضع الليلي (ظلال أخف + اعتماد على السطح الأفتح).
class AppElevation {
  AppElevation._();

  static bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color _shadowColor(BuildContext context, double alpha) {
    final scheme = Theme.of(context).colorScheme;
    final factor = _isDark(context) ? 0.55 : 1.0;
    return scheme.shadow.withValues(alpha: alpha * factor);
  }

  /// بلا ظل — الأسطح المسطّحة.
  static List<BoxShadow> level0(BuildContext context) => const <BoxShadow>[];

  /// ظل خفيف جداً — الحقول والشرائح.
  static List<BoxShadow> level1(BuildContext context) => <BoxShadow>[
    BoxShadow(
      color: _shadowColor(context, 0.04),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];

  /// ظل البطاقات القياسية.
  static List<BoxShadow> level2(BuildContext context) => <BoxShadow>[
    BoxShadow(
      color: _shadowColor(context, 0.06),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  /// ظل البطاقات البارزة (KPI / Hero).
  static List<BoxShadow> level3(BuildContext context) => <BoxShadow>[
    BoxShadow(
      color: _shadowColor(context, 0.08),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  /// ظل العناصر العائمة (FAB / Header زجاجي).
  static List<BoxShadow> level4(BuildContext context) => <BoxShadow>[
    BoxShadow(
      color: _shadowColor(context, 0.10),
      blurRadius: 28,
      offset: const Offset(0, 12),
    ),
  ];

  /// ظل الحوارات والأوراق السفلية.
  static List<BoxShadow> level5(BuildContext context) => <BoxShadow>[
    BoxShadow(
      color: _shadowColor(context, 0.14),
      blurRadius: 40,
      offset: const Offset(0, 16),
    ),
  ];

  /// ظل ملوّن مشتق من لون دلالي (للبطاقات المالية البارزة).
  static List<BoxShadow> tinted(
    BuildContext context,
    Color color, {
    double alpha = 0.28,
    double blur = 24,
    double dy = 10,
  }) => <BoxShadow>[
    BoxShadow(
      color: color.withValues(alpha: _isDark(context) ? alpha * 0.6 : alpha),
      blurRadius: blur,
      offset: Offset(0, dy),
    ),
  ];

  /// توهج ضوئي ملوّن محيطي (للعناصر المشعة، الهالات، وأشرطة التحميل الانسيابية)
  static List<BoxShadow> glow(
    BuildContext context,
    Color color, {
    double alpha = 0.25,
    double blur = 16,
    double spread = 0,
  }) => <BoxShadow>[
    BoxShadow(
      color: color.withValues(alpha: _isDark(context) ? alpha * 0.7 : alpha),
      blurRadius: blur,
      spreadRadius: spread,
      offset: Offset.zero,
    ),
  ];
}
