import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_shimmer.dart';

/// Skeleton مطابق للتدرج البصري لبطاقة سند السداد.
class RepaymentCardSkeleton extends StatelessWidget {
  const RepaymentCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    Widget block(double width, double height, {double radius = AppRadius.xs}) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(radius ?? AppRadius.xs),
        ),
      );
    }

    return CustomSkeletonShimmer(
      child: Container(
        margin: EdgeInsets.only(bottom: AppSpacing.sm),
        padding: EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: colors.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                block(36, 36, radius: AppRadius.sm),
                AppSpacing.hSm,
                Expanded(child: block(136, 14)),
                AppSpacing.hSm,
                block(76, 22, radius: AppRadius.full),
              ],
            ),
            AppSpacing.vMd,
            block(220, 11),
            AppSpacing.vMd,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [block(88, 11), block(108, 16)],
            ),
          ],
        ),
      ),
    );
  }
}
