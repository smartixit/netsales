import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_shimmer.dart';

/// هيكل تحميل عظمي (Skeleton) متطابق تماماً مع تصميم بطاقة [NetworkPosCard] و [PosLinkedNetworkCard]
/// يُعرض في أسفل القائمة أثناء جلب الصفحة التالية (Load-More) عبر نظام الترقيم بالمؤشر (Cursor Pagination)
/// بما يضمن عدم إخفاء العناصر المحملة مسبقاً وتوفير تجربة مستخدم متناسقة وراقية.
class NetworkPosCardSkeleton extends StatelessWidget {
  const NetworkPosCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomSkeletonShimmer(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.3),
            width: 1.2,
          ),
          boxShadow: AppElevation.level1(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. ترويسة البطاقة: أيقونة/شعار، اسم، وشارة الحالة
            Row(
              children: [
                // الشعار أو الصورة
                Container(
                  width: 44.r,
                  height: 44.r,
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                AppSpacing.hSm,
                // الاسم والمعرف
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 14.h,
                        width: 140.w,
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(AppRadius.xs),
                        ),
                      ),
                      AppSpacing.vXxs,
                      Container(
                        height: 11.h,
                        width: 90.w,
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(AppRadius.xs),
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.hSm,
                // شارة الحالة
                Container(
                  width: 65.w,
                  height: 24.h,
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                ),
              ],
            ),
            AppSpacing.vSm,
            // 2. سطر التفاصيل السفلي
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 12.h,
                  width: 120.w,
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                  ),
                ),
                Container(
                  height: 28.h,
                  width: 80.w,
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
