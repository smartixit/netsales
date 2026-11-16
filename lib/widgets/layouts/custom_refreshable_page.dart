import 'package:flutter/material.dart';

/// Shared refreshable, width-constrained page container.
class CustomRefreshablePage extends StatelessWidget {
  const CustomRefreshablePage({
    super.key,
    required this.onRefresh,
    required this.padding,
    required this.child,
    this.maxContentWidth = 760,
  });

  final Future<void> Function() onRefresh;
  final EdgeInsetsGeometry padding;
  final Widget child;
  final double maxContentWidth;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator.adaptive(
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: padding,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: child,
          ),
        ),
      ),
    );
  }
}
