import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_card.dart';

/// ============================================================================
/// CustomSkeletonFeed — Generic feed/list skeleton placeholder (project-agnostic)
/// ============================================================================
/// A reusable skeleton placeholder for scrollable feeds and detail screens,
/// composed of stacked [CustomSkeletonCard] placeholders.
/// Respects reduced motion via [CustomSkeletonCard] -> [CustomSkeletonShimmer].
/// Uses a scrollable [ListView] to prevent any layout overflow under constrained
/// viewports (e.g. keyboard active or small screens).
class CustomSkeletonFeed extends StatelessWidget {
  const CustomSkeletonFeed({
    super.key,
    this.itemCount = 3,
    this.cardHeight = 120,
    this.padding,
    this.physics,
  });

  /// Number of skeleton cards to render.
  final int itemCount;

  /// Height of each skeleton card (in logical .h units).
  final double cardHeight;

  /// Optional outer padding override.
  final EdgeInsetsGeometry? padding;

  /// Optional scroll physics.
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding ?? EdgeInsets.symmetric(vertical: AppSpacing.xs),
      physics: physics ??
          const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
      itemCount: itemCount,
      separatorBuilder: (_, __) => AppSpacing.vSm,
      itemBuilder: (context, index) => CustomSkeletonCard(height: cardHeight),
    );
  }
}
