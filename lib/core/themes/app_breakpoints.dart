import 'package:flutter/material.dart';

/// الفئات المعيارية الست لقياسات الأجهزة وفق معايير التصميم التكيفي المؤسسية.
/// متوافقة مع إرشادات Google Material 3 Window Classes و Tailwind CSS Breakpoints.
enum AppDeviceSize {
  /// هواتف صغيرة جداً أو أجهزة كاشير محمولة قديمة (< 360dp)
  mobileSmall,

  /// الهواتف الذكية القياسية في الوضع الرأسي (360 - 599dp)
  mobile,

  /// الأجهزة اللوحية وأجهزة نقاط البيع اللوحية المحمولة 7" إلى 10" (600 - 899dp)
  tablet,

  /// اللابتوبات والأجهزة اللوحية الكبيرة في الوضع الأفقي (900 - 1239dp)
  desktop,

  /// الشاشات المكتبية القياسية وشاشات العرض Full HD (1240 - 1599dp)
  desktopLarge,

  /// الشاشات العريضة جداً وشاشات 2K / 4K (>= 1600dp)
  ultraWide,
}

/// فئات عرض النوافذ الأساسية وفق مواصفات Material 3.
/// تُستخدم للتوافق الخلفي والتصنيفات العريضة (Compact / Medium / Expanded).
enum AppWindowClass {
  compact,
  medium,
  expanded,
}

/// المنظومة المركزية لنقاط الانقطاع والتصميم التكيفي (Enterprise Adaptive Breakpoints).
///
/// توفر هذه الفئة المرجع الحصري الموحد لكافة قرارات التكيف البصري، الهوامش الديناميكية،
/// عدد أعمدة الشبكات، والقيود الحجمية عبر كافة منصات التطبيق (Android, iOS, Web, Desktop).
class AppBreakpoints {
  AppBreakpoints._();

  // ═══════════════════════════════════════════════════════════════════════════
  // 1. نقاط الانقطاع الأفقية (Width Breakpoint Thresholds in dp)
  // ═══════════════════════════════════════════════════════════════════════════

  /// الحد الأقصى للهواتف الصغيرة جداً
  static const double mobileSmallMax = 360.0;

  /// الحد الأقصى لكافة الهواتف الذكية
  static const double mobileMax = 600.0;

  /// الحد الأقصى للأجهزة اللوحية وأجهزة نقاط البيع المتنقلة
  static const double tabletMax = 900.0;

  /// الحد الأقصى للابتوبات والشاشات المتوسطة
  static const double desktopMax = 1240.0;

  /// الحد الأقصى للشاشات المكتبية القياسية
  static const double desktopLargeMax = 1600.0;

  /// توافق خلفي مع قيم Material 3
  static const double compactMax = mobileMax;
  static const double mediumMax = 1024.0;

  // ═══════════════════════════════════════════════════════════════════════════
  // 2. نقاط الانقطاع الرأسية (Height Breakpoint Thresholds in dp)
  // ═══════════════════════════════════════════════════════════════════════════

  /// الحد الأقصى للارتفاع المضغوط (يمنع RenderFlex Overflow عند تدوير الهاتف أفقياً)
  static const double compactHeightMax = 480.0;

  /// الارتفاع المتوسط للشاشات
  static const double mediumHeightMax = 900.0;

  // ═══════════════════════════════════════════════════════════════════════════
  // 3. سقوف أبعاد المحتوى والنوافذ (Design Constraints in dp)
  // ═══════════════════════════════════════════════════════════════════════════

  /// أقصى عرض لاستمارات الإدخال ونماذج تسجيل الدخول (لمنع تمدد الحقول المرهق)
  static const double maxFormWidth = 540.0;

  /// أقصى عرض للمحتوى الرئيسي والبطاقات في الشاشات العريضة لمنع تشتت القراءة
  static const double maxContentWidth = 1200.0;

  /// أقصى عرض للنوافذ المنبثقة وصناديق الحوار المعتمدة
  static const double maxModalWidth = 480.0;

  /// أقصى عرض للقائمة الجانبية الممتدة (Navigation Drawer)
  static const double maxDrawerWidth = 320.0;

  /// العرض القياسي للشريط الجانبي المصغر (Navigation Rail)
  static const double navigationRailWidth = 72.0;

  /// العرض القياسي للجزء الثابت في الواجهات المقسمة (Adaptive Split View Pane)
  static const double splitViewSideWidth = 440.0;

  // ═══════════════════════════════════════════════════════════════════════════
  // 4. مقاييس الشاشة الآنية (Screen Dimension Readers)
  // ═══════════════════════════════════════════════════════════════════════════

  /// قراءة عرض الشاشة الفعلي بالاعتماد على SizeOf الفعالة في Flutter 3
  static double widthOf(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  /// قراءة ارتفاع الشاشة الفعلي
  static double heightOf(BuildContext context) =>
      MediaQuery.sizeOf(context).height;

  /// استخراج الفئة الدقيقة للجهاز الحالي
  static AppDeviceSize sizeOf(BuildContext context) {
    final width = widthOf(context);
    if (width < mobileSmallMax) return AppDeviceSize.mobileSmall;
    if (width < mobileMax) return AppDeviceSize.mobile;
    if (width < tabletMax) return AppDeviceSize.tablet;
    if (width < desktopMax) return AppDeviceSize.desktop;
    if (width < desktopLargeMax) return AppDeviceSize.desktopLarge;
    return AppDeviceSize.ultraWide;
  }

  /// استخراج فئة Material 3 العامة للتوافق المعماري
  static AppWindowClass classOf(BuildContext context) {
    final width = widthOf(context);
    if (width < compactMax) return AppWindowClass.compact;
    if (width < mediumMax) return AppWindowClass.medium;
    return AppWindowClass.expanded;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 5. محددات الفئات السريعة (Device Type Predicates)
  // ═══════════════════════════════════════════════════════════════════════════

  static bool isCompact(BuildContext context) =>
      classOf(context) == AppWindowClass.compact;

  static bool isMedium(BuildContext context) =>
      classOf(context) == AppWindowClass.medium;

  static bool isExpanded(BuildContext context) =>
      classOf(context) == AppWindowClass.expanded;

  static bool isMobileSmall(BuildContext context) =>
      sizeOf(context) == AppDeviceSize.mobileSmall;

  static bool isMobile(BuildContext context) {
    final size = sizeOf(context);
    return size == AppDeviceSize.mobileSmall || size == AppDeviceSize.mobile;
  }

  static bool isTablet(BuildContext context) =>
      sizeOf(context) == AppDeviceSize.tablet;

  static bool isDesktop(BuildContext context) =>
      sizeOf(context).index >= AppDeviceSize.desktop.index;

  static bool isLargeDesktop(BuildContext context) =>
      sizeOf(context).index >= AppDeviceSize.desktopLarge.index;

  static bool isUltraWide(BuildContext context) =>
      sizeOf(context) == AppDeviceSize.ultraWide;

  /// فحص الاتجاه الأفقي
  static bool isLandscape(BuildContext context) =>
      MediaQuery.orientationOf(context) == Orientation.landscape;

  /// فحص إذا كان الارتفاع مضغوطاً (لتجنب الأخطاء في هواتف Landscape)
  static bool isCompactHeight(BuildContext context) =>
      heightOf(context) < compactHeightMax;

  // ═══════════════════════════════════════════════════════════════════════════
  // 6. قواعد أنماط التنقل المؤسسية (Navigation Structure Rules)
  // ═══════════════════════════════════════════════════════════════════════════

  /// هل نستخدم شريط التنقل السفلي؟ (حصرياً للهواتف في الوضع الرأسي)
  static bool usesBottomBar(BuildContext context) =>
      isMobile(context) && !isCompactHeight(context);

  /// هل نستخدم شريط التنقل الجانبي المصغر NavigationRail؟ (للأجهزة اللوحية والهواتف الأفقية)
  static bool usesNavigationRail(BuildContext context) =>
      isTablet(context) || (isMobile(context) && isCompactHeight(context));

  /// هل نستخدم القائمة الجانبية الكاملة NavigationDrawer؟ (للشاشات المكتبية والويب)
  static bool usesNavigationDrawer(BuildContext context) => isDesktop(context);

  // ═══════════════════════════════════════════════════════════════════════════
  // 7. الهوامش ومسافات التباعد التكيفية (Adaptive Margins & Gutters)
  // ═══════════════════════════════════════════════════════════════════════════

  /// الهامش الجانبي للشاشة بحسب فئة الجهاز
  static double screenMargin(BuildContext context) {
    return switch (sizeOf(context)) {
      AppDeviceSize.mobileSmall => 12.0,
      AppDeviceSize.mobile => 16.0,
      AppDeviceSize.tablet => 24.0,
      AppDeviceSize.desktop => 32.0,
      AppDeviceSize.desktopLarge => 48.0,
      AppDeviceSize.ultraWide => 64.0,
    };
  }

  /// المسافة الفاصلة بين كروت الشبكات (Grid Gutter)
  static double gridGutter(BuildContext context) {
    return switch (sizeOf(context)) {
      AppDeviceSize.mobileSmall || AppDeviceSize.mobile => 12.0,
      AppDeviceSize.tablet => 16.0,
      AppDeviceSize.desktop ||
      AppDeviceSize.desktopLarge ||
      AppDeviceSize.ultraWide =>
        24.0,
    };
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 8. توزيع أعمدة الشبكات الذكية (Responsive Grid Columns)
  // ═══════════════════════════════════════════════════════════════════════════

  /// عدد أعمدة شبكة القوائم والبطاقات القياسية
  static int columnsFor(BuildContext context) {
    return switch (sizeOf(context)) {
      AppDeviceSize.mobileSmall || AppDeviceSize.mobile => 1,
      AppDeviceSize.tablet => 2,
      AppDeviceSize.desktop => 3,
      AppDeviceSize.desktopLarge => 4,
      AppDeviceSize.ultraWide => 5,
    };
  }

  /// عدد أعمدة شبكة المؤشرات المالية السريعة (KPI Dashboard Metrics)
  static int kpiColumnsFor(BuildContext context) {
    return switch (sizeOf(context)) {
      AppDeviceSize.mobileSmall => 1,
      AppDeviceSize.mobile => 2,
      AppDeviceSize.tablet => 3,
      AppDeviceSize.desktop => 4,
      AppDeviceSize.desktopLarge || AppDeviceSize.ultraWide => 5,
    };
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 9. دالة اختيار القيمة التكيفية الشاملة (Universal Adaptive Value Selector)
  // ═══════════════════════════════════════════════════════════════════════════

  /// اختيار قيمة ديناميكية ملائمة بدقة لحجم الجهاز الحالي مع تسلسل هرمي ذكي
  static T value<T>(
    BuildContext context, {
    required T compact,
    T? medium,
    T? expanded,
    T? tablet,
    T? desktop,
    T? desktopLarge,
    T? ultraWide,
  }) {
    final size = sizeOf(context);
    return switch (size) {
      AppDeviceSize.mobileSmall || AppDeviceSize.mobile => compact,
      AppDeviceSize.tablet => tablet ?? medium ?? compact,
      AppDeviceSize.desktop => desktop ?? expanded ?? medium ?? compact,
      AppDeviceSize.desktopLarge =>
        desktopLarge ?? desktop ?? expanded ?? medium ?? compact,
      AppDeviceSize.ultraWide =>
        ultraWide ?? desktopLarge ?? desktop ?? expanded ?? medium ?? compact,
    };
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 10. ملحقات BuildContext الانسيابية (Ergonomic Extensions)
// ═══════════════════════════════════════════════════════════════════════════

/// ملحقات توفر وصولاً مباشراً وسلساً لكافة خصائص التصميم التكيفي عبر سياق الودجت
extension ResponsiveContext on BuildContext {
  /// الحجم الدقيق للجهاز
  AppDeviceSize get deviceSize => AppBreakpoints.sizeOf(this);

  /// فئة نافذة Material 3
  AppWindowClass get windowClass => AppBreakpoints.classOf(this);

  /// فحص الهواتف المحمولة
  bool get isMobile => AppBreakpoints.isMobile(this);

  /// فحص الهواتف الصغيرة جداً
  bool get isMobileSmall => AppBreakpoints.isMobileSmall(this);

  /// فحص الأجهزة اللوحية
  bool get isTablet => AppBreakpoints.isTablet(this);

  /// فحص الشاشات المكتبية واللابتوبات
  bool get isDesktop => AppBreakpoints.isDesktop(this);

  /// فحص الشاشات المكتبية الكبيرة
  bool get isLargeDesktop => AppBreakpoints.isLargeDesktop(this);

  /// فحص الشاشات فائقة العرض
  bool get isUltraWide => AppBreakpoints.isUltraWide(this);

  /// فحص الاتجاه الأفقي
  bool get isLandscape => AppBreakpoints.isLandscape(this);

  /// فحص الارتفاع المضغوط
  bool get isCompactHeight => AppBreakpoints.isCompactHeight(this);

  /// العرض الفعلي للشاشة
  double get screenWidth => AppBreakpoints.widthOf(this);

  /// الارتفاع الفعلي للشاشة
  double get screenHeight => AppBreakpoints.heightOf(this);

  /// الهامش الجانبي الموصى به للشاشة الحالية
  double get screenMargin => AppBreakpoints.screenMargin(this);

  /// المسافة الفاصلة لكروت الشبكة
  double get gridGutter => AppBreakpoints.gridGutter(this);

  /// عدد الأعمدة الافتراضي
  int get responsiveColumns => AppBreakpoints.columnsFor(this);

  /// عدد أعمدة المؤشرات المالية
  int get kpiColumns => AppBreakpoints.kpiColumnsFor(this);

  /// دالة اختيار القيمة التكيفية المباشرة
  T responsive<T>({
    required T mobile,
    T? tablet,
    T? desktop,
    T? desktopLarge,
    T? ultraWide,
  }) =>
      AppBreakpoints.value<T>(
        this,
        compact: mobile,
        tablet: tablet,
        desktop: desktop,
        desktopLarge: desktopLarge,
        ultraWide: ultraWide,
      );
}

// ═══════════════════════════════════════════════════════════════════════════
// 11. الودجات التكيفية الجاهزة (Ready-to-Use Adaptive Layout Widgets)
// ═══════════════════════════════════════════════════════════════════════════

/// ودجت بناء تخطيط تكيفي تلقائي يفصل تماماً بين واجهة الموبايل والتابلت والشاشة الكبيرة
class AdaptiveLayout extends StatelessWidget {
  const AdaptiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  final WidgetBuilder mobile;
  final WidgetBuilder? tablet;
  final WidgetBuilder? desktop;

  @override
  Widget build(BuildContext context) {
    if (context.isDesktop && desktop != null) {
      return desktop!(context);
    }
    if (context.isTablet && tablet != null) {
      return tablet!(context);
    }
    return mobile(context);
  }
}

/// ودجت لتغليف وتوسيط محتوى الشاشات العريضة مع تقييد الحد الأقصى للاتساع
class ResponsiveContentWrapper extends StatelessWidget {
  const ResponsiveContentWrapper({
    super.key,
    required this.child,
    this.maxWidth = AppBreakpoints.maxContentWidth,
    this.padding,
    this.alignment = Alignment.topCenter,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ??
        EdgeInsets.symmetric(
          horizontal: context.screenMargin,
        );

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: effectivePadding,
          child: child,
        ),
      ),
    );
  }
}

/// ودجت لتقسيم الشاشة الكبيرة لعمودين (جانبي ورئيسي)، مع التراجع لعمود واحد على الهواتف
class AdaptiveSplitView extends StatelessWidget {
  const AdaptiveSplitView({
    super.key,
    required this.sidePane,
    required this.mainPane,
    this.sideWidth = AppBreakpoints.splitViewSideWidth,
    this.breakpoint = AppBreakpoints.tabletMax,
    this.reverse = false,
  });

  final Widget sidePane;
  final Widget mainPane;
  final double sideWidth;
  final double breakpoint;
  final bool reverse;

  @override
  Widget build(BuildContext context) {
    final width = context.screenWidth;

    if (width < breakpoint) {
      return mainPane;
    }

    final children = reverse
        ? [
            Expanded(child: mainPane),
            SizedBox(width: sideWidth, child: sidePane),
          ]
        : [
            SizedBox(width: sideWidth, child: sidePane),
            Expanded(child: mainPane),
          ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}

