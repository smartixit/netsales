import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/themes/app_colors.dart';

/// Shared refreshable, width-constrained page container with sliver scroll architecture.
/// Matches the exact proven scroll behavior from ProcurementOrdersScreen.
class CustomRefreshablePage extends StatelessWidget {
  const CustomRefreshablePage({
    super.key,
    required this.onRefresh,
    required this.padding,
    required this.child,
    this.maxContentWidth = 760,
    this.edgeOffset,
    this.displacement,
  });

  final Future<void> Function() onRefresh;
  final EdgeInsetsGeometry padding;
  final Widget child;
  final double maxContentWidth;
  final double? edgeOffset;
  final double? displacement;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final resolvedPadding = padding.resolve(Directionality.of(context));
    final effectiveEdgeOffset =
        edgeOffset ?? (resolvedPadding.top > 0 ? resolvedPadding.top - 14.h : 0.0);

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
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverPadding(
                padding: resolvedPadding,
                sliver: SliverToBoxAdapter(
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
