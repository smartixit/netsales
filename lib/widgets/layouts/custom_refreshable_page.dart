import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/core/themes/app_colors.dart';

/// ودجت الصفحة القابلة للتحديث الموحدة والمسؤولة مركزياً عن حساب الهوامش والمسافات الآمنة (Padding)
/// تدعم نمطين: بناء ودجت مفرد (Box Child) أو قائمة شرائح متعددة (Slivers Pipeline) مع إعفاء الشاشات كلياً
/// من حسابات الـ horizontalPadding و topPadding و bottomPadding وشريط التنقل السفلي العائم.
class CustomRefreshablePage extends StatelessWidget {
  const CustomRefreshablePage({
    super.key,
    required this.onRefresh,
    required Widget this._child,
    this.embedded = false,
    this.padding,
    this.maxContentWidth = 760,
    this.edgeOffset,
    this.displacement,
    this.onNotification,
    this.scrollKey,
    this.physics,
  })  : slivers = null;

  const CustomRefreshablePage.slivers({
    super.key,
    required this.onRefresh,
    required this.slivers,
    this.embedded = false,
    this.padding,
    this.maxContentWidth = 760,
    this.edgeOffset,
    this.displacement,
    this.onNotification,
    this.scrollKey,
    this.physics,
  })  : _child = null;

  final Future<void> Function() onRefresh;
  final bool embedded;
  final EdgeInsetsGeometry? padding;
  final Widget? _child;
  final List<Widget>? slivers;
  final double maxContentWidth;
  final double? edgeOffset;
  final double? displacement;
  final NotificationListenerCallback<ScrollNotification>? onNotification;
  final Key? scrollKey;
  final ScrollPhysics? physics;

  /// حساب الهوامش القياسية المركزية للمنظومة
  static EdgeInsets resolvePagePadding(BuildContext context, {bool embedded = false}) {
    final mediaQuery = MediaQuery.of(context);
    final topPadding = embedded
        ? mediaQuery.padding.top + 20.h
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

    final effectivePadding = padding?.resolve(Directionality.of(context)) ??
        resolvePagePadding(context, embedded: embedded);

    final effectiveEdgeOffset = edgeOffset ??
        (effectivePadding.top > 0 ? effectivePadding.top - 14.h : 0.0);

    final effectivePhysics = physics ??
        const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        );

    final List<Widget> rootSlivers;
    if (_child != null) {
      rootSlivers = [
        SliverPadding(
          padding: effectivePadding,
          sliver: SliverToBoxAdapter(child: _child),
        ),
      ];
    } else {
      rootSlivers = [
        SliverPadding(
          padding: effectivePadding,
          sliver: SliverMainAxisGroup(
            slivers: slivers ?? const <Widget>[],
          ),
        ),
      ];
    }

    Widget scrollView = CustomScrollView(
      key: scrollKey,
      physics: effectivePhysics,
      slivers: rootSlivers,
    );

    if (onNotification != null) {
      scrollView = NotificationListener<ScrollNotification>(
        onNotification: onNotification,
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
