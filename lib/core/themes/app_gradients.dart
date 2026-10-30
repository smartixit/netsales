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

  // ===========================================================================
  // باقة التدرجات الملكية لبطاقات الكيانات والشبكات (Executive Card Palette)
  // ===========================================================================

  /// 1. الزمرد الملكي الفاخر (Royal Deep Emerald)
  static LinearGradient entityEmerald(BuildContext context) {
    return const LinearGradient(
      begin: AlignmentDirectional.topStart,
      end: AlignmentDirectional.bottomEnd,
      colors: [Color(0xFF042F24), Color(0xFF084838), Color(0xFF0D6852)],
      stops: [0.0, 0.52, 1.0],
    );
  }

  /// 2. الياقوت الكحلي والنيلي الليلي (Midnight Sapphire Navy)
  static LinearGradient entitySapphire(BuildContext context) {
    return const LinearGradient(
      begin: AlignmentDirectional.topStart,
      end: AlignmentDirectional.bottomEnd,
      colors: [Color(0xFF0A1828), Color(0xFF132843), Color(0xFF1C426F)],
      stops: [0.0, 0.52, 1.0],
    );
  }

  /// 3. التيتانيوم والأوبسيديان الفاحم (Obsidian Black & Platinum Titanium)
  static LinearGradient entityObsidian(BuildContext context) {
    return const LinearGradient(
      begin: AlignmentDirectional.topStart,
      end: AlignmentDirectional.bottomEnd,
      colors: [Color(0xFF14171A), Color(0xFF20262E), Color(0xFF333B45)],
      stops: [0.0, 0.52, 1.0],
    );
  }

  /// 4. الجمشت الأرجواني المخملي (Imperial Amethyst & Deep Velvet Plum)
  static LinearGradient entityAmethyst(BuildContext context) {
    return const LinearGradient(
      begin: AlignmentDirectional.topStart,
      end: AlignmentDirectional.bottomEnd,
      colors: [Color(0xFF220A35), Color(0xFF351252), Color(0xFF4F1A77)],
      stops: [0.0, 0.52, 1.0],
    );
  }

  /// 5. البرونز والنحاس العتيق (Champagne Bronze & Deep Amber)
  static LinearGradient entityAmberBronze(BuildContext context) {
    return const LinearGradient(
      begin: AlignmentDirectional.topStart,
      end: AlignmentDirectional.bottomEnd,
      colors: [Color(0xFF28170B), Color(0xFF3E2310), Color(0xFF5D361B)],
      stops: [0.0, 0.52, 1.0],
    );
  }

  /// اختيار تدرج البطاقة ديناميكياً وفق ترتيب الكيان
  static LinearGradient entityCardGradient(BuildContext context, int index) {
    final gradients = [
      entityEmerald(context),
      entitySapphire(context),
      entityObsidian(context),
      entityAmethyst(context),
      entityAmberBronze(context),
    ];
    return gradients[index % gradients.length];
  }

  /// لون التوهج الظلي المقترن بهوية تدرج البطاقة
  static Color entityAccentColor(int index) {
    const accentColors = [
      Color(0xFF0D6852),
      Color(0xFF1C426F),
      Color(0xFF333B45),
      Color(0xFF4F1A77),
      Color(0xFF5D361B),
    ];
    return accentColors[index % accentColors.length];
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

  /// تدرج بطاقة "المزيد" (3 محطات)
  static LinearGradient moreHero(BuildContext context) {
    final scheme = _scheme(context);
    return LinearGradient(
      begin: AlignmentDirectional.topStart,
      end: AlignmentDirectional.bottomEnd,
      colors: [
        scheme.primary.withValues(alpha: _isDark(context) ? 0.12 : 0.08),
        scheme.surface.withValues(alpha: _isDark(context) ? 0.65 : 0.50),
        scheme.surfaceContainerLowest,
      ],
      stops: const [0.0, 0.45, 1.0],
    );
  }
    /// تدرج Hero ب3 محطات (accent خفيف → surface → surfaceContainerLowest) — للبطاقات Hero في operations
    static LinearGradient accentHero3(BuildContext context, Color accent) {
      final scheme = _scheme(context);
      return LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          accent.withValues(alpha: 0.06),
          scheme.surface.withValues(alpha: 0.40),
          scheme.surfaceContainerLowest,
        ],
        stops: const [0.0, 0.40, 1.0],
      );
    }

    /// تدرج Badge ب2 محطات (accent 0.18 → accent 0.06) — للشارات داخل Hero
    static LinearGradient accentBadge(BuildContext context, Color accent) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          accent.withValues(alpha: 0.18),
          accent.withValues(alpha: 0.06),
        ],
      );
    }

    /// تدرج Soft ب2 محطات (accent 0.18 → accent 0.05) — لبطاقات parties
    static LinearGradient accentSoft(BuildContext context, Color accent) {
      return LinearGradient(
        colors: [
          accent.withValues(alpha: 0.18),
          accent.withValues(alpha: 0.05),
        ],
      );
    }

    /// تدرج Ledger Hero ب3 محطات (accent 0.05 → surface 0.35 → surfaceContainerLowest)
    static LinearGradient ledgerHero3(BuildContext context, Color accent) {
      final scheme = _scheme(context);
      return LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          accent.withValues(alpha: 0.05),
          scheme.surface.withValues(alpha: 0.35),
          scheme.surfaceContainerLowest,
        ],
        stops: const [0.0, 0.40, 1.0],
      );
    }

    /// تدرج Ledger Badge ب2 محطات (accent 0.16 → accent 0.05)
    static LinearGradient ledgerBadge(BuildContext context, Color accent) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          accent.withValues(alpha: 0.16),
          accent.withValues(alpha: 0.05),
        ],
      );
    }

    /// تدرج Outline Soft ب2 محطات (accent 0.35 → accent 0.05)
    static LinearGradient outlineSoft(BuildContext context, Color accent) {
      return LinearGradient(
        colors: [
          accent.withValues(alpha: 0.35),
          accent.withValues(alpha: 0.05),
        ],
      );
    }
    /// تدرج من قائمة ألوان مخصصة (للحالات الديناميكية) — يمنع كتابة LinearGradient في الميزات
    static LinearGradient fromColors(
      BuildContext context,
      List<Color> colors, {
      AlignmentGeometry begin = AlignmentDirectional.topStart,
      AlignmentGeometry end = AlignmentDirectional.bottomEnd,
    }) {
      return LinearGradient(
        begin: begin,
        end: end,
        colors: colors,
      );
    }
  /// Primary Gradient
  static LinearGradient primaryGradient(BuildContext context) {
    // final scheme = _scheme(context);
    return LinearGradient(
      begin: AlignmentDirectional.topStart,
      end: AlignmentDirectional.bottomEnd,
      colors: [
        Color(0xFF003B32), // Deep Teal
        Color(0xFF004D40), // Dark Teal
        Color(0xFF00796B), // Muted Dark Teal
      ],
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

  /// تعبئة المساحة أسفل خطوط المخططات البيانية (Area / Spline Area Fill).
  /// يتلاشى من لون السلسلة إلى الشفافية الكاملة ليبقى المخطط مقروءاً في
  /// الوضعين الفاتح والداكن دون أي لون صريح.
  static LinearGradient chartAreaFill(
    BuildContext context,
    Color seriesColor, {
    double peakOpacity = 0.35,
  }) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        seriesColor.withValues(alpha: peakOpacity),
        seriesColor.withValues(alpha: 0.0),
      ],
    );
  }

  /// تدرّج تعتيم (Scrim Overlay) لترويسات وتذييلات معارض الوسائط والنوافذ الكاملة
  static LinearGradient statusTint(BuildContext context, Color statusColor) {
    final scheme = _scheme(context);
    return LinearGradient(
      begin: AlignmentDirectional.topStart,
      end: AlignmentDirectional.bottomEnd,
      colors: [
        statusColor.withValues(alpha: 0.06),
        scheme.surface.withValues(alpha: 0.40),
        scheme.surfaceContainerLowest,
      ],
      stops: const [0.0, 0.5, 1.0],
    );
  }

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
