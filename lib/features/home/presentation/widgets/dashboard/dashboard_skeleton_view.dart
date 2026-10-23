import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_list_tile.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_shimmer.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_text.dart';

/// ============================================================================
/// DashboardSkeletonView — Skeleton shimmer placeholder for the dashboard
/// ============================================================================
/// يعيد بناء الهيكل التشكيلي لواجهة لوحة القيادة أثناء التحميل الأولي باستخدام
/// أنواع متعددة من الودجات الموحدة (CustomSkeletonText / CustomSkeletonListTile
/// / CustomSkeletonShimmer) وفق ميثاق الودجات الحالاتي (§26) مع احترام
/// تفضيل تقليل الحركة تلقائياً داخل CustomSkeletonShimmer.
class DashboardSkeletonView extends StatelessWidget {
  const DashboardSkeletonView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding,
          vertical: AppSpacing.md,
        ),
        child: CustomSkeletonShimmer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. هيكل ترويسة الكيان (سطران نصيان متفاوتين)
              const CustomSkeletonText(lines: 1),
              AppSpacing.vMd,
              const CustomSkeletonText(lines: 1),

              AppSpacing.vLg,

              // 2. هيكل بطاقة السيولة المالية المركزية
              Container(
                width: double.infinity,
                height: 140.h,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(AppRadius.lg.r),
                ),
              ),

              AppSpacing.vLg,

              // 3. هيكل الرادار/التنبيهات (بلاطات قائمة)
              const CustomSkeletonListTile(hasLeading: true, lines: 2),
              AppSpacing.vMd,
              const CustomSkeletonListTile(hasLeading: true, lines: 2),

              AppSpacing.vLg,

              // 4. هيكل شبكة البينتو (صفان من البلاطات)
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 96.h,
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(AppRadius.md.r),
                      ),
                    ),
                  ),
                  AppSpacing.hMd,
                  Expanded(
                    child: Container(
                      height: 96.h,
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(AppRadius.md.r),
                      ),
                    ),
                  ),
                ],
              ),

              AppSpacing.vLg,

              // 5. هيكل تغذية العمليات الأخيرة
              const CustomSkeletonListTile(hasLeading: false, lines: 1),
              AppSpacing.vMd,
              const CustomSkeletonListTile(hasLeading: false, lines: 1),
            ],
          ),
        ),
      ),
    );
  }
}
