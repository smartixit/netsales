import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_shimmer.dart';

class CustomSkeletonText extends StatelessWidget {
  const CustomSkeletonText({
    super.key,
    this.lines = 3,
    this.lineHeight = 12,
  });

  final int lines;
  final double lineHeight;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomSkeletonShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
          lines,
          (index) => Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.xs),
            child: Container(
              height: lineHeight.h,
              width: index == lines - 1 ? 120.w : double.infinity,
              decoration: BoxDecoration(
                color: colors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(AppRadius.xs.r),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
