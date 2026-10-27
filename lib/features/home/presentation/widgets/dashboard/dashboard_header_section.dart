import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/home/presentation/controllers/dashboard_controller.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// ============================================================================
/// شريط النطاق الزمني والتحليلات التنفيذية (DashboardHeaderSection)
/// ============================================================================
/// يوفر شريط تبديل فترات زمنية عائم بنمط Segmented Glass Controls فائق النعومة،
/// يربط حركة المبيعات وتغطية التوزيع بالفترة المحددة لحظياً.
class DashboardHeaderSection extends StatelessWidget {
  final DashboardController controller;

  const DashboardHeaderSection({
    super.key,
    required this.controller,
  });

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
          // 1. شريط العنوان والسياق التحليلي
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 28.r,
                    height: 28.r,
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.1),
                      borderRadius: AppRadius.xsRadius,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.insights_rounded,
                      size: 16.r,
                      color: colors.primary,
                    ),
                  ),
                  AppSpacing.hSm,
                  Expanded(
                    child: Text(
                      'مؤشرات أداء التوزيع',
                      style: AppTypography.titleMedium.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.hXs,
              // شارة الفترة المحددة النشطة
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 3.h,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest.withValues(alpha: 0.45),
                  borderRadius: AppRadius.fullRadius,
                  border: Border.all(
                    color: colors.outlineVariant.withValues(alpha: 0.3),
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
                        color: colors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    AppSpacing.hXs,
                    Text(
                      selectedPeriodLabel,
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.onSurface,
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          AppSpacing.vSm,

          // 2. شريط التبديل القطاعي الزجاجي للفترات الزمنية (Segmented Glass Horizon Bar)
          Container(
            padding: EdgeInsets.all(3.r),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest.withValues(alpha: 0.4),
              borderRadius: AppRadius.fullRadius,
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: 0.25),
                width: 1.w,
              ),
            ),
            child: SingleChildScrollView(
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
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: 7.h,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? colors.primary : Colors.transparent,
                          borderRadius: AppRadius.fullRadius,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: colors.primary.withValues(alpha: 0.3),
                                    blurRadius: 6.r,
                                    offset: Offset(0, 2.h),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          p['label']!,
                          style: AppTypography.labelMedium.copyWith(
                            color: isSelected ? colors.onPrimary : colors.onSurfaceVariant,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 11.5.sp,
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
