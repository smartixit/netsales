import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_shimmer.dart';

class CustomSkeletonListTile extends StatelessWidget {
  const CustomSkeletonListTile({
    super.key,
    this.hasLeading = true,
    this.lines = 2,
  });

  final bool hasLeading;
  final int lines;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomSkeletonShimmer(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasLeading) ...[
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: colors.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
            ),
            AppSpacing.hMd,
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                lines,
                (index) => Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Container(
                    height: 12.h,
                    width: index == 0 ? double.infinity : 180.w,
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(AppRadius.xs.r),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
