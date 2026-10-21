import 'package:flutter/material.dart';

/// التدرجات اللونية الموحّدة — مشتقة حصراً من هوية المشروع
/// (`AppColors.primaryGradient` وألوان `ColorScheme`).
///
/// ممنوع تعريف أي `LinearGradient` بألوان صريحة داخل الشاشات.
class AppGradients {
  AppGradients._();

  static ColorScheme _scheme(BuildContext context) =>
      Theme.of(context).colorScheme;

  static bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  /// تدرّج الهوية الأساسي — للبطاقة المالية الرئيسية (Hero).
  static LinearGradient financialHero(BuildContext context) {
    final scheme = _scheme(context);
    return LinearGradient(
      begin: AlignmentDirectional.topStart,
      end: AlignmentDirectional.bottomEnd,
      colors: [scheme.primary, scheme.secondary, scheme.tertiary],
      stops: const [0.0, 0.55, 1.0],
    );
  }

  /// خلفية ناعمة للشاشات — إحساس Mesh بلا تكلفة رسم عالية.
  static LinearGradient surfaceMesh(BuildContext context) {
    final scheme = _scheme(context);
    return LinearGradient(
      begin: AlignmentDirectional.topStart,
      end: AlignmentDirectional.bottomEnd,
      colors: [
        scheme.surface,
        Color.alphaBlend(
          scheme.primary.withValues(alpha: _isDark(context) ? 0.06 : 0.04),
          scheme.surface,
        ),
        scheme.surface,
      ],
      stops: const [0.0, 0.45, 1.0],
    );
  }

  /// طبقة زجاجية للهيدر فوق المحتوى المتمرّر.
  static LinearGradient glassOverlay(BuildContext context) {
    final scheme = _scheme(context);
    final base = scheme.surface;
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        base.withValues(alpha: _isDark(context) ? 0.92 : 0.88),
        base.withValues(alpha: _isDark(context) ? 0.70 : 0.62),
      ],
    );
  }

  /// تدرّج إيجابي — الزيادات والأرصدة الموجبة.
  static LinearGradient positiveDelta(BuildContext context) {
    final scheme = _scheme(context);
    return LinearGradient(
      begin: AlignmentDirectional.centerStart,
      end: AlignmentDirectional.centerEnd,
      colors: [
        scheme.tertiary.withValues(alpha: 0.22),
        scheme.tertiary.withValues(alpha: 0.06),
      ],
    );
  }

  /// تدرّج سلبي — النقصان والأرصدة السالبة.
  static LinearGradient negativeDelta(BuildContext context) {
    final scheme = _scheme(context);
    return LinearGradient(
      begin: AlignmentDirectional.centerStart,
      end: AlignmentDirectional.centerEnd,
      colors: [
        scheme.error.withValues(alpha: 0.20),
        scheme.error.withValues(alpha: 0.05),
      ],
    );
  }

  /// تدرّج رأسي شفاف — لتلاشي حواف القوائم أسفل الهيدر/فوق شريط الأزرار.
  static LinearGradient fadeEdge(BuildContext context, {bool fromTop = true}) {
    final base = _scheme(context).surface;
    return LinearGradient(
      begin: fromTop ? Alignment.topCenter : Alignment.bottomCenter,
      end: fromTop ? Alignment.bottomCenter : Alignment.topCenter,
      colors: [base, base.withValues(alpha: 0.0)],
    );
  }

  /// تدرّج هيكل التحميل (Shimmer) متوافق مع الثيم.
  static LinearGradient shimmer(BuildContext context) {
    final scheme = _scheme(context);
    final base = scheme.surfaceContainerHighest;
    final highlight = Color.alphaBlend(
      scheme.surface.withValues(alpha: _isDark(context) ? 0.35 : 0.75),
      base,
    );
    return LinearGradient(
      begin: AlignmentDirectional.centerStart,
      end: AlignmentDirectional.centerEnd,
      colors: [base, highlight, base],
      stops: const [0.1, 0.5, 0.9],
    );
  }

  /// تدرّج شريط التحميل الانسيابي (Flowing Progress Bar)
  static LinearGradient flowingBar(BuildContext context) {
    final scheme = _scheme(context);
    return LinearGradient(
      colors: [
        scheme.primary.withValues(alpha: 0.35),
        scheme.primary,
        scheme.secondary,
        scheme.primary.withValues(alpha: 0.35),
      ],
      stops: const [0.0, 0.45, 0.55, 1.0],
    );
  }

  /// تدرّج تعتيم (Scrim Overlay) لترويسات وتذييلات معارض الوسائط والنوافذ الكاملة
  static LinearGradient scrimOverlay(
    BuildContext context, {
    bool fromTop = true,
    double peakOpacity = 0.85,
  }) {
    final scrim = _scheme(context).scrim;
    return LinearGradient(
      begin: fromTop ? Alignment.topCenter : Alignment.bottomCenter,
      end: fromTop ? Alignment.bottomCenter : Alignment.topCenter,
      colors: [
        scrim.withValues(alpha: peakOpacity),
        scrim.withValues(alpha: 0.0),
      ],
    );
  }
}
