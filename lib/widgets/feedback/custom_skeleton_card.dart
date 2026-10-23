import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_shimmer.dart';

class CustomSkeletonCard extends StatelessWidget {
  const CustomSkeletonCard({
    super.key,
    this.height = 120,
    this.width,
    this.radius,
  });

  final double height;
  final double? width;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomSkeletonShimmer(
      child: Container(
        height: height.h,
        width: width?.w,
        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular((radius ?? AppRadius.md).r),
        ),
      ),
    );
  }
}
