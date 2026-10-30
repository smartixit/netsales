import 'package:flutter/material.dart';

/// نظام الحركة والتحريك الموحّد لتطبيق NetSales (Material 3 Motion System).
///
/// كل حركة في التطبيق يجب أن تستخدم مدة ومنحنى من هذا الملف — لا أرقام صريحة.
/// المبدأ: "حركة ذات معنى" — كل حركة تُخبر المستخدم بشيء، ولا حركة تزيينية.
class AppMotion {
  AppMotion._();

  // ── المدد (Durations) ──

  /// حركة فورية للتغذية الراجعة اللمسية (150ms)
  static const Duration fast = Duration(milliseconds: 150);

  /// المدة القياسية لأغلب الانتقالات (250ms)
  static const Duration normal = Duration(milliseconds: 250);

  /// حركة بطيئة للعناصر الكبيرة أو المؤكِّدة (350ms)
  static const Duration slow = Duration(milliseconds: 350);

  /// انتقال بين الصفحات (400ms)
  static const Duration page = Duration(milliseconds: 400);

  /// فاصل التتابع بين عناصر القائمة (Stagger)
  static const Duration staggerStep = Duration(milliseconds: 60);

  /// مدة الـ Debounce الافتراضية لحقول البحث المرتبطة بالـ API
  static const Duration searchDebounce = Duration(milliseconds: 400);
  static const Duration cooldownTick = Duration(seconds: 1);

  /// دورة توهّج الهياكل العظمية (Skeleton Shimmer)
  static const Duration shimmer = Duration(milliseconds: 1400);
  static const Duration splashMinimum = Duration(milliseconds: 2500);

  // ── المنحنيات (Curves — Material 3) ──

  /// المنحنى القياسي للانتقالات المتوازنة
  static const Curve standard = Curves.easeInOutCubic;

  /// منحنى التأكيد — للعناصر الداخلة بقوة
  static const Curve emphasized = Curves.easeOutCubic;

  /// منحنى التباطؤ — للعناصر التي تدخل الشاشة
  static const Curve decelerate = Curves.easeOutQuart;

  /// منحنى التسارع — للعناصر التي تغادر الشاشة
  static const Curve accelerate = Curves.easeInQuart;

  /// منحنى ارتدادي خفيف — للتأكيدات الإيجابية فقط
  static const Curve springy = Curves.easeOutBack;

  // ── مساعدات (Helpers) ──

  /// يُرجع تأخير التتابع لعنصر بترتيب [index] مع سقف أعلى
  /// لمنع تأخير العناصر البعيدة في القوائم الطويلة.
  static Duration staggerDelay(int index, {int maxSteps = 8}) {
    final steps = index < maxSteps ? index : maxSteps;
    return staggerStep * steps;
  }

  /// هل يجب تعطيل الحركة؟ (إمكانية الوصول — Accessibility)
  static bool disabled(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  /// يُرجع المدة مع احترام إعداد تعطيل الحركة في النظام.
  static Duration duration(BuildContext context, Duration value) =>
      disabled(context) ? Duration.zero : value;
}
