import 'package:flutter/widgets.dart';

/// فئات عرض الشاشة وفق Material 3 Window Size Classes.
enum AppWindowClass { compact, medium, expanded }

/// نقاط الانقطاع ومساعدات التجاوب.
///
/// المشروع يبني لـ Android/iOS/Windows/macOS/Linux/Web — لذا كل شاشة
/// يجب أن تكون صالحة على الفئات الثلاث.
class AppBreakpoints {
  AppBreakpoints._();

  /// أقل من هذا العرض = هاتف.
  static const double compactMax = 600;

  /// أقل من هذا العرض = لوحي / نافذة متوسطة.
  static const double mediumMax = 1024;

  /// أقصى عرض للمحتوى على الشاشات الكبيرة (منعاً لسطور طويلة مرهقة).
  static const double maxContentWidth = 1200;

  static double widthOf(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  static AppWindowClass classOf(BuildContext context) {
    final width = widthOf(context);
    if (width < compactMax) return AppWindowClass.compact;
    if (width < mediumMax) return AppWindowClass.medium;
    return AppWindowClass.expanded;
  }

  static bool isCompact(BuildContext context) =>
      classOf(context) == AppWindowClass.compact;

  static bool isMedium(BuildContext context) =>
      classOf(context) == AppWindowClass.medium;

  static bool isExpanded(BuildContext context) =>
      classOf(context) == AppWindowClass.expanded;

  /// هل نستخدم `NavigationRail` بدل شريط التنقّل السفلي؟
  static bool usesNavigationRail(BuildContext context) => !isCompact(context);

  /// عدد أعمدة الشبكة المناسب لعرض الشاشة الحالي.
  static int columnsFor(BuildContext context) => switch (classOf(context)) {
    AppWindowClass.compact => 1,
    AppWindowClass.medium => 2,
    AppWindowClass.expanded => 3,
  };

  /// عدد أعمدة شبكة المؤشرات (KPI) — أكثر كثافة من قوائم البطاقات.
  static int kpiColumnsFor(BuildContext context) => switch (classOf(context)) {
    AppWindowClass.compact => 2,
    AppWindowClass.medium => 3,
    AppWindowClass.expanded => 4,
  };

  /// اختيار قيمة حسب فئة العرض.
  static T value<T>(
    BuildContext context, {
    required T compact,
    T? medium,
    T? expanded,
  }) => switch (classOf(context)) {
    AppWindowClass.compact => compact,
    AppWindowClass.medium => medium ?? compact,
    AppWindowClass.expanded => expanded ?? medium ?? compact,
  };
}
