import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';

/// قسم رصيد البيانات البطل والمواصفات (Package Card Quota Section)
///
/// يعرض السعة بخط رقمي ضخم ومريح مع مؤشرات الصلاحية وحجم الحزمة بنعومة متناهية
class PackageCardQuotaSection extends StatelessWidget {
  const PackageCardQuotaSection({
    super.key,
    required this.package,
    required this.accentColor,
  });

  final PackageEntity package;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // كتلة رصيد البيانات كبطل بصري ناصع
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        package.balanceDisplay,
                        style: AppTypography.headlineMedium.copyWith(
                          fontWeight: FontWeight.w900,
                          color: colors.onSurface,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Icon(
                      Icons.wifi_tethering_rounded,
                      size: 13.r,
                      color: accentColor,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'سعة رصيد الكرت',
                      style: AppTypography.badgeText.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(width: AppSpacing.sm),

          // كبسولات الصلاحية وحجم الحزمة الفاخرة
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              // كبسولة حجم الحزمة
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8.w,
                  vertical: 3.h,
                ),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.22),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.layers_rounded,
                      size: 12.r,
                      color: accentColor,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '${package.packageVoucherCount} كرت بالحزمة',
                      style: AppTypography.badgeText.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4.h),
              // كبسولة الصلاحية
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8.w,
                  vertical: 3.h,
                ),
                decoration: BoxDecoration(
                  color: colors.purpleAccent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                  border: Border.all(
                    color: colors.purpleAccent.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 12.r,
                      color: colors.purpleAccent,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      package.validityDisplay,
                      style: AppTypography.badgeText.copyWith(
                        color: colors.purpleAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
