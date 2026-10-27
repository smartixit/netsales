import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_shimmer.dart';

/// ============================================================================
/// OperationsDetailsSkeletonView — Skeleton shimmer placeholder for details
/// ============================================================================
/// يعيد بناء الهيكل التشكيلي لشاشات تفاصيل الفواتير والطلبات بنمط السند السيادي
/// أثناء التحميل الأولي مع احترام تفضيل تقليل الحركة تلقائياً عبر [CustomSkeletonShimmer].
class OperationsDetailsSkeletonView extends StatelessWidget {
  const OperationsDetailsSkeletonView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: ResponsiveContentWrapper(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.appBarHeight),
          child: CustomSkeletonShimmer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. هيكل بطاقة السند الهيرو (Hero Bond Card Blueprint)
                Container(
                  width: double.infinity,
                  height: 180.h,
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHigh,
                    borderRadius: AppRadius.xlRadius,
                  ),
                ),

                AppSpacing.vMd,

                // 2. هيكل بطاقة أطراف التعامل (Parties Pods Blueprint)
                Container(
                  width: double.infinity,
                  height: 96.h,
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHigh,
                    borderRadius: AppRadius.lgRadius,
                  ),
                ),

                AppSpacing.vMd,

                // 3. هيكل جدول بنود الباقات (Items Table Blueprint)
                Container(
                  width: double.infinity,
                  height: 160.h,
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHigh,
                    borderRadius: AppRadius.lgRadius,
                  ),
                ),

                AppSpacing.vMd,

                // 4. هيكل الملخص المالي المحاسبي (Financial Summary Blueprint)
                Container(
                  width: double.infinity,
                  height: 140.h,
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHigh,
                    borderRadius: AppRadius.lgRadius,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
