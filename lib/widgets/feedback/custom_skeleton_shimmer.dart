import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:netsales/core/themes/app_motion.dart';

/// ============================================================================
/// CustomSkeletonShimmer — Base reusable skeleton shimmer (project-agnostic)
/// ============================================================================
/// يوفر وميضاً ضوئياً احترافياً فائق النعومة متوافقاً مع هوية التطبيق واتجاه RTL،
/// ويمنع التداخل أو التكرار العشوائي للـ Shimmer المتداخل عبر نطاق Inherited Scope.
class CustomSkeletonShimmer extends StatelessWidget {
  const CustomSkeletonShimmer({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.period,
    this.direction,
    this.enabled = true,
  });

  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration? period;
  final ShimmerDirection? direction;
  final bool enabled;

  /// فحص ما إذا كان الودجت الحالي يقع ضمن نطاق شيمر أبوي مسبق لمنع التكرار
  static bool isInScope(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_ShimmerScope>() != null;
  }

  @override
  Widget build(BuildContext context) {
    final disable = AppMotion.disabled(context) || !enabled;

    if (disable) {
      return child;
    }

    // إذا كان العنصر موجوداً بالفعل ضمن شيمر أعلى في الشجرة، نكتفي برسم عناصره بدون شيمر مكرر
    if (isInScope(context)) {
      return child;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    // ألوان شيمر ناصعة ومصممة وفق معايير Fintech العالمية (Light & Dark)
    // في الوضع الفاتح: لون أساسي ناعم ونظيف مع وميض أبيض مشرق لمنع المظهر الداكن/المعتم
    final resolvedBaseColor = baseColor ??
        (isDark
            ? const Color(0xFF132B20)
            : const Color(0xFFE9EEF0));

    final resolvedHighlightColor = highlightColor ??
        (isDark
            ? const Color(0xFF1E4634)
            : const Color(0xFFFFFFFF));

    final resolvedPeriod = period ?? const Duration(milliseconds: 1300);
    final resolvedDirection = direction ??
        (isRtl ? ShimmerDirection.rtl : ShimmerDirection.ltr);

    return _ShimmerScope(
      child: Shimmer.fromColors(
        baseColor: resolvedBaseColor,
        highlightColor: resolvedHighlightColor,
        period: resolvedPeriod,
        direction: resolvedDirection,
        child: child,
      ),
    );
  }
}

/// نطاق داخلي لمنع إنشاء شيمر متعدد ومتداخل يسبب تشويش الحركة والوميض
class _ShimmerScope extends InheritedWidget {
  const _ShimmerScope({required super.child});

  @override
  bool updateShouldNotify(_ShimmerScope oldWidget) => false;
}
