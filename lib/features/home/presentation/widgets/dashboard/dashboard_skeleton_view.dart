import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_list_tile.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_shimmer.dart';
import 'package:netsales/widgets/foundation/home_tab_shell.dart';

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

    return HomeTabShell.scrollable(
      physics: const NeverScrollableScrollPhysics(),
      child: CustomSkeletonShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. هيكل بطاقة الكيان الشبكي المستقل (Multi-Entity Deck Blueprint)
            Container(
              width: double.infinity,
              height: 200.h,
              decoration: BoxDecoration(
                color: colors.surfaceContainerHigh,
                borderRadius: AppRadius.xlRadius,
              ),
            ),

            AppSpacing.vLg,

            // 2. هيكل شريط الفترات الزمنية الزجاجي (Segmented Bar Blueprint)
            Container(
              width: double.infinity,
              height: 38.h,
              decoration: BoxDecoration(
                color: colors.surfaceContainerHigh,
                borderRadius: AppRadius.fullRadius,
              ),
            ),

            AppSpacing.vLg,

            // 3. هيكل المخطط البياني الانسيابي (Sales Trend Chart Blueprint)
            Container(
              width: double.infinity,
              height: 190.h,
              decoration: BoxDecoration(
                color: colors.surfaceContainerHigh,
                borderRadius: AppRadius.lgRadius,
              ),
            ),

            AppSpacing.vLg,

            // 4. هيكل مصفوفة كفاءة التوزيع الميداني (Bento Distribution Grid)
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 110.h,
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHigh,
                      borderRadius: AppRadius.lgRadius,
                    ),
                  ),
                ),
                AppSpacing.hMd,
                Expanded(
                  child: Container(
                    height: 110.h,
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHigh,
                      borderRadius: AppRadius.lgRadius,
                    ),
                  ),
                ),
              ],
            ),

            AppSpacing.vLg,

            // 5. هيكل سجل العمليات الأخيرة (Recent Feed Tiles)
            const CustomSkeletonListTile(hasLeading: true, lines: 2),
            AppSpacing.vMd,
            const CustomSkeletonListTile(hasLeading: true, lines: 2),
          ],
        ),
      ),
    );
  }
}
