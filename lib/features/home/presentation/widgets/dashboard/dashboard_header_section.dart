import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/themes/app_motion.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/home/presentation/controllers/dashboard_controller.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// ============================================================================
/// شريط الأفق التنفيذي والتحكم بالنطاق الزمني (DashboardHeaderSection)
/// ============================================================================
/// يوفر شريط تبديل انسيابي بنمط Executive Horizon Controls،
/// يربط حركة المبيعات وتغطية التوزيع بالفترة المحددة لحظياً مع تفاعل لمسي ناعم.
class DashboardHeaderSection extends StatelessWidget {
  final DashboardController controller;

  const DashboardHeaderSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      final selectedPeriodKey = controller.selectedPeriod.value;
      final selectedPeriodLabel = DashboardController.periods.firstWhere(
        (p) => p['key'] == selectedPeriodKey,
        orElse: () => {'label': 'اليوم'},
      )['label']!;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. ترويسة السياق التحليلي الموحد بدون أيقونات مكررة
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'نظرة الأداء والتوزيع الميداني',
                      style: AppTypography.titleMedium.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    AppSpacing.vXxs,
                    Text(
                      'تحليلات فورية ومؤشرات النشاط التشغيلي المباشر',
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.onSurfaceVariant,
                        fontSize: 10.5.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              AppSpacing.hSm,
              // شارة خضراء تفاعلية تدل على التحديث اللحظي المباشر
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 4.h,
                ),
                decoration: BoxDecoration(
                  color: colors.success.withValues(alpha: 0.1),
                  borderRadius: AppRadius.fullRadius,
                  border: Border.all(
                    color: colors.success.withValues(alpha: 0.25),
                    width: 0.8.w,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6.r,
                      height: 6.r,
                      decoration: BoxDecoration(
                        color: colors.success,
                        shape: BoxShape.circle,
                        boxShadow: AppElevation.tinted(context, colors.success),
                      ),
                    ),
                    AppSpacing.hXs,
                    Text(
                      selectedPeriodLabel,
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.success,
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          AppSpacing.vSm,

          // 2. كبسولة التبديل القطاعية الفاخرة للفترات الزمنية
          Container(
            padding: EdgeInsets.all(3.r),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
              borderRadius: AppRadius.fullRadius,
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: 0.2),
                width: 0.8.w,
              ),
            ),
            child: SingleChildScrollView(
              clipBehavior: Clip.none,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: DashboardController.periods.map((p) {
                  final isSelected = selectedPeriodKey == p['key'];
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2.w),
                    child: CustomInteractiveBounce(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        controller.changePeriod(p['key']!);
                      },
                      child: AnimatedContainer(
                        duration: AppMotion.normal,
                        curve: AppMotion.standard,
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colors.primary
                              : Colors.transparent,
                          borderRadius: AppRadius.fullRadius,
                          boxShadow: isSelected
                              ? AppElevation.glow(context, colors.primary)
                              : null,
                        ),
                        child: Text(
                          p['label']!,
                          style: AppTypography.labelMedium.copyWith(
                            color: isSelected
                                ? colors.onPrimary
                                : colors.onSurfaceVariant,
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : FontWeight.w600,
                            fontSize: 11.sp,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      );
    });
  }
}
