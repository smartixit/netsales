import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/core/themes/app_colors.dart';

/// ودجت الصفحة القابلة للتحديث الموحدة والمسؤولة مركزياً عن:
/// 1. حساب الهوامش والمسافات الآمنة (Padding) للهواتف والأجهزة اللوحية
/// 2. إدارة التمرير اللانهائي الذكي (Smart Infinite Scroll) عبر عتبة استباقية (280px) لجلب البيانات تلقائياً قبل وصول المستخدم للنهاية
/// 3. دعم بناء ودجت مفرد (Box Child) أو قائمة شرائح متعددة (Slivers Pipeline) مع الحفاظ الكامل على Virtualization.
class CustomRefreshablePage extends StatelessWidget {
  const CustomRefreshablePage({
    super.key,
    required this.onRefresh,
    required Widget this.child,
    this.embedded = false,
    this.padding,
    this.maxContentWidth = 760,
    this.edgeOffset,
    this.displacement,
    this.onLoadMore,
    this.hasMore = false,
    this.hasMorePredicate,
    this.loadMoreThreshold = 280.0,
    this.onNotification,
    this.scrollKey,
    this.physics,
  }) : slivers = null;

  const CustomRefreshablePage.slivers({
    super.key,
    required this.onRefresh,
    required this.slivers,
    this.embedded = false,
    this.padding,
    this.maxContentWidth = 760,
    this.edgeOffset,
    this.displacement,
    this.onLoadMore,
    this.hasMore = false,
    this.hasMorePredicate,
    this.loadMoreThreshold = 280.0,
    this.onNotification,
    this.scrollKey,
    this.physics,
  }) : child = null;

  final Future<void> Function() onRefresh;
  final bool embedded;
  final EdgeInsetsGeometry? padding;
  final Widget? child;
  final List<Widget>? slivers;
  final double maxContentWidth;
  final double? edgeOffset;
  final double? displacement;
  final VoidCallback? onLoadMore;
  final bool hasMore;
  final ValueGetter<bool>? hasMorePredicate;
  final double loadMoreThreshold;
  final NotificationListenerCallback<ScrollNotification>? onNotification;
  final Key? scrollKey;
  final ScrollPhysics? physics;

  /// حساب الهوامش القياسية المركزية للمنظومة
  static EdgeInsets resolvePagePadding(
    BuildContext context, {
    bool embedded = false,
  }) {
    final mediaQuery = MediaQuery.of(context);
    // Embedded workspace pages render beneath a translucent, extended app bar.
    // Reserve its complete layout extent, not only the status-bar inset.
    final topPadding = embedded
        ? mediaQuery.padding.top +
              AppSpacing.appBarHeight +
              AppSpacing.sm +
              AppSpacing.md
        : AppSpacing.md;
    final bottomPadding = embedded
        ? 115.h + mediaQuery.padding.bottom
        : mediaQuery.padding.bottom + AppSpacing.xl;
    final horizontalPadding = AppBreakpoints.screenMargin(context);

    return EdgeInsets.fromLTRB(
      horizontalPadding,
      topPadding,
      horizontalPadding,
      bottomPadding,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final effectivePadding =
        padding?.resolve(Directionality.of(context)) ??
        resolvePagePadding(context, embedded: embedded);

    final effectiveEdgeOffset =
        edgeOffset ??
        (effectivePadding.top > 0 ? effectivePadding.top - 14.h : 0.0);

    final effectivePhysics =
        physics ??
        const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics());

    final List<Widget> rootSlivers;
    if (child != null) {
      rootSlivers = [
        SliverPadding(
          padding: effectivePadding,
          sliver: SliverToBoxAdapter(child: child),
        ),
      ];
    } else {
      rootSlivers = [
        SliverPadding(
          padding: effectivePadding,
          sliver: SliverMainAxisGroup(slivers: slivers ?? const <Widget>[]),
        ),
      ];
    }

    Widget scrollView = CustomScrollView(
      key: scrollKey,
      physics: effectivePhysics,
      slivers: rootSlivers,
    );

    final shouldListenScroll = onNotification != null || onLoadMore != null;
    if (shouldListenScroll) {
      scrollView = NotificationListener<ScrollNotification>(
        onNotification: (scroll) {
          if (onNotification != null) {
            final handled = onNotification!(scroll);
            if (handled) return true;
          }
          final canLoadMore = hasMorePredicate != null
              ? hasMorePredicate!()
              : hasMore;
          if (onLoadMore != null &&
              canLoadMore &&
              scroll.depth == 0 &&
              scroll.metrics.extentAfter <= loadMoreThreshold) {
            onLoadMore!();
          }
          return false;
        },
        child: scrollView,
      );
    }

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxContentWidth),
        child: RefreshIndicator.adaptive(
          edgeOffset: effectiveEdgeOffset,
          displacement: displacement ?? 36.h,
          color: colors.primary,
          backgroundColor: colors.surface,
          strokeWidth: 2.5,
          onRefresh: onRefresh,
          child: scrollView,
        ),
      ),
    );
  }
}
