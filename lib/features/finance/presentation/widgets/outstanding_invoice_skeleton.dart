import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_shimmer.dart';

/// هيكل تحميل يحاكي ترتيب بيانات بطاقة الفاتورة المستحقة.
class OutstandingInvoiceSkeleton extends StatelessWidget {
  const OutstandingInvoiceSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
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
                _block(colors, 36, 36, radius: AppRadius.sm),
                AppSpacing.hSm,
                Expanded(child: _block(colors, 140, 13)),
                AppSpacing.hSm,
                _block(colors, 72, 22, radius: AppRadius.full),
              ],
            ),
            AppSpacing.vMd,
            _block(colors, 300, 1),
            AppSpacing.vMd,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _block(colors, 92, 11),
                _block(colors, 116, 16),
              ],
            ),
            AppSpacing.vSm,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _block(colors, 72, 10),
                _block(colors, 88, 15),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _block(
    AppColors colors,
    double width,
    double height, {
    double radius = AppRadius.xs,
  }) {
    return Container(
      width: width.isFinite ? width : null,
      height: height,
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
