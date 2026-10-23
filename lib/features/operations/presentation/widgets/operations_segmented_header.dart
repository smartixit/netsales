import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/operations/presentation/controllers/operations_controller.dart';
import 'package:netsales/widgets/animations/custom_interactive_bounce.dart';

/// ============================================================================
/// شريط التبديل القطاعي للعمليات (OperationsSegmentedHeader)
/// ============================================================================
/// يتيح التبديل السلس بين فواتير مبيعات الكروت وطلبات التوريد
/// مع شارات العداد الحي لكل قطاع.
class OperationsSegmentedHeader extends StatelessWidget {
  final OperationsController controller;

  const OperationsSegmentedHeader({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: AppRadius.lgRadius,
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Obx(() {
        final activeIndex = controller.activeSegmentIndex.value;
        final invoicesCount = controller.invoices.length;
        final pendingRequests = controller.pendingRequestsCount;

        return Row(
          children: [
            // 1. تبويب فواتير المبيعات
            Expanded(
              child: _SegmentItem(
                title: 'فواتير المبيعات',
                count: invoicesCount,
                isSelected: activeIndex == 0,
                onTap: () => controller.changeSegment(0),
              ),
            ),

            AppSpacing.hXs,

            // 2. تبويب طلبات الكروت
            Expanded(
              child: _SegmentItem(
                title: 'طلبات الكروت',
                count: pendingRequests,
                hasHighlightBadge: pendingRequests > 0,
                isSelected: activeIndex == 1,
                onTap: () => controller.changeSegment(1),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _SegmentItem extends StatelessWidget {
  final String title;
  final int count;
  final bool isSelected;
  final bool hasHighlightBadge;
  final VoidCallback onTap;

  const _SegmentItem({
    required this.title,
    required this.count,
    required this.isSelected,
    this.hasHighlightBadge = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomInteractiveBounce(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
          horizontal: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: isSelected ? colors.surface : Colors.transparent,
          borderRadius: AppRadius.mdRadius,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colors.shadow.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                title,
                style: AppTypography.titleSmall.copyWith(
                  color: isSelected ? colors.primary : colors.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (count > 0) ...[
              AppSpacing.hXs,
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: 2.h,
                ),
                decoration: BoxDecoration(
                  color: hasHighlightBadge
                      ? colors.warning.withValues(alpha: 0.15)
                      : (isSelected
                          ? colors.primary.withValues(alpha: 0.12)
                          : colors.onSurfaceVariant.withValues(alpha: 0.1)),
                  borderRadius: AppRadius.fullRadius,
                ),
                child: Text(
                  count.toString(),
                  style: AppTypography.labelSmall.copyWith(
                    color: hasHighlightBadge
                        ? colors.warning
                        : (isSelected ? colors.primary : colors.onSurfaceVariant),
                    fontWeight: FontWeight.bold,
                    fontSize: 10.sp,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
