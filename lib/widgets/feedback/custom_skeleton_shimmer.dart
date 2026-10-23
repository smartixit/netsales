import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_motion.dart';

/// ============================================================================
/// CustomSkeletonShimmer — Base reusable skeleton shimmer (project-agnostic)
/// ============================================================================
/// Wraps `Shimmer.fromColors` using theme colors (no hardcoded colors).
/// Respects reduced motion (`AppMotion.disabled`).
class CustomSkeletonShimmer extends StatelessWidget {
  const CustomSkeletonShimmer({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.enabled = true,
  });

  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final disable = AppMotion.disabled(context) || !enabled;

    if (disable) {
      return child;
    }

    return Shimmer.fromColors(
      baseColor: baseColor ?? colors.surfaceContainerHigh,
      highlightColor: highlightColor ?? colors.surfaceContainerHighest,
      child: child,
    );
  }
}
