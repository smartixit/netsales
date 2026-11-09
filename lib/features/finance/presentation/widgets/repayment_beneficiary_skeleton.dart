import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_shimmer.dart';

/// Loading placeholder مطابق لبنية حقلي اختيار الشبكة ونقطة البيع.
class RepaymentBeneficiarySkeleton extends StatelessWidget {
  const RepaymentBeneficiarySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return CustomSkeletonShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_field(colors, 92), AppSpacing.vMd, _field(colors, 118)],
      ),
    );
  }

  Widget _field(AppColors colors, double labelWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: labelWidth,
          height: 11,
          decoration: BoxDecoration(
            color: colors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(AppRadius.xs),
          ),
        ),
        AppSpacing.vXs,
        Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.button),
            border: Border.all(color: colors.outlineVariant),
          ),
        ),
      ],
    );
  }
}

/// Placeholder واحد لحقل نقطة البيع أثناء تحميل أول صفحة من الشبكة.
class RepaymentBeneficiaryFieldSkeleton extends StatelessWidget {
  const RepaymentBeneficiaryFieldSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return CustomSkeletonShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 118,
            height: 11,
            decoration: BoxDecoration(
              color: colors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(AppRadius.xs),
            ),
          ),
          AppSpacing.vXs,
          Container(
            width: double.infinity,
            height: 54,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppRadius.button),
              border: Border.all(color: colors.outlineVariant),
            ),
          ),
        ],
      ),
    );
  }
}
