import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/core/themes/app_colors.dart';

/// ============================================================================
/// الغلاف الهيكلي الموحد لتبويبات الشاشة الرئيسية (HomeTabShell)
/// ============================================================================
/// يطبق النمط المعماري القياسي للمنصات العالمية (Shell Layout Pattern):
/// 1. يحمي الامتداد السيادي الكامل خلف الترويسة الزجاجية (Edge-to-Edge) دون أي اقتطاع للخلفية.
/// 2. يوحد حسابات ومسافات بداية المحتوى أسفل الـ AppBar بهامش تنفيذي قياسي مريح.
/// 3. يحمي ذيل الشاشات التمريرية والقوائم من التداخل مع شريط التنقل السفلي العائم.
/// 4. يدمج السحب للتحديث (Pull-To-Refresh) وتحديد أقصى اتساع تجاوبي بدون أي تكرار برمجي.
class HomeTabShell extends StatelessWidget {
  final Widget child;
  final bool isScrollable;
  final Future<void> Function()? onRefresh;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? contentPadding;
  final bool useHorizontalPadding;
  final bool useResponsiveWrapper;
  final bool reserveBottomBarPadding;

  const HomeTabShell.scrollable({
    super.key,
    required this.child,
    this.onRefresh,
    this.physics,
    this.contentPadding,
    this.useHorizontalPadding = false,
    this.useResponsiveWrapper = true,
    this.reserveBottomBarPadding = true,
  }) : isScrollable = true;

  const HomeTabShell.fixed({
    super.key,
    required this.child,
    this.contentPadding,
    this.useHorizontalPadding = false,
    this.reserveBottomBarPadding = false,
  }) : isScrollable = false,
       onRefresh = null,
       physics = null,
       useResponsiveWrapper = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final topInset = MediaQuery.paddingOf(context).top + AppSpacing.lg;
    final bottomInset = reserveBottomBarPadding ? 150.h : 0.0;

    // 1. نمط الشاشات التمريرية الكاملة (Dashboard / More)
    if (isScrollable) {
      Widget scrollContent = child;

      if (useResponsiveWrapper) {
        scrollContent = ResponsiveContentWrapper(child: scrollContent);
      }

      final effectivePadding =
          (contentPadding as EdgeInsets?) ??
          EdgeInsets.symmetric(
            horizontal: useHorizontalPadding ? AppSpacing.screenPadding : 0,
          );

      final scrollView = SingleChildScrollView(
        physics:
            physics ??
            const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
        padding: EdgeInsets.only(
          left: effectivePadding.left,
          right: effectivePadding.right,
          top: topInset + effectivePadding.top,
          bottom: bottomInset + effectivePadding.bottom,
        ),
        child: scrollContent,
      );

      if (onRefresh != null) {
        return RefreshIndicator(
          color: colors.primary,
          edgeOffset: MediaQuery.paddingOf(context).top,
          onRefresh: onRefresh!,
          child: scrollView,
        );
      }

      return scrollView;
    }

    // 2. نمط الشاشات الهيكلية الثابتة ذات القوائم الداخلية (Operations / Partners)
    return Padding(
      padding: EdgeInsets.only(
        left: useHorizontalPadding ? AppSpacing.screenPadding : 0,
        right: useHorizontalPadding ? AppSpacing.screenPadding : 0,
        top: topInset,
        bottom: bottomInset,
      ),
      child: child,
    );
  }
}
