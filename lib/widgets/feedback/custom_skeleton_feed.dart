import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_card.dart';

/// ============================================================================
/// CustomSkeletonFeed — Generic feed/list skeleton placeholder (project-agnostic)
/// ============================================================================
/// A reusable skeleton placeholder for scrollable feeds and detail screens,
/// composed of stacked [CustomSkeletonCard] placeholders.
/// Respects reduced motion via [CustomSkeletonCard] -> [CustomSkeletonShimmer].
class CustomSkeletonFeed extends StatelessWidget {
  const CustomSkeletonFeed({
    super.key,
    this.itemCount = 3,
    this.cardHeight = 120,
    this.padding,
  });

  /// Number of skeleton cards to render.
  final int itemCount;

  /// Height of each skeleton card (in logical .h units).
  final double cardHeight;

  /// Optional outer padding override.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          padding ??
          EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
            vertical: AppSpacing.xl,
          ),
      child: Column(
        children: List.generate(
          itemCount,
          (index) => Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.sm),
            child: CustomSkeletonCard(height: cardHeight),
          ),
        ),
      ),
    );
  }
}
