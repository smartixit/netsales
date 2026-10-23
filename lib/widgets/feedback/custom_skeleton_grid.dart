import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_card.dart';

class CustomSkeletonGrid extends StatelessWidget {
  const CustomSkeletonGrid({
    super.key,
    this.count = 6,
    this.crossAxisCount = 2,
    this.itemHeight = 120,
  });

  final int count;
  final int crossAxisCount;
  final double itemHeight;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
        childAspectRatio: 1.2,
      ),
      itemCount: count,
      itemBuilder: (_, __) => CustomSkeletonCard(height: itemHeight),
    );
  }
}
