import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_motion.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

/// شارة تعريفية لفلتر نشط مع إمكانية إزالته بنقرة واحدة
class ActiveFilterItem {
  final String label;
  final VoidCallback onRemove;

  const ActiveFilterItem({required this.label, required this.onRemove});
}

/// شريط موحد وأنيق لعرض عدد السجلات ونتائج البحث والفلترة (CustomResultsCounterBar)
///
/// يجمع بين أناقة كبسولات قيد (كبسولة النتائج + شارة "مفلترة" + انتقال AnimatedSwitcher)
/// ومرونة NetSales (العدد الكلي، شارات الفلاتر النشطة القابلة للإزالة فرادى، وزر المسح).
class CustomResultsCounterBar extends StatelessWidget {
  final int count;
  final int? totalCount;
  final String recordLabel;
  final String? customResultsText;
  final String filteredBadgeLabel;
  final IconData analyticsIcon;
  final bool isFiltered;
  final bool isLoading;
  final VoidCallback? onClear;
  final List<ActiveFilterItem> activeFilters;

  const CustomResultsCounterBar({
    super.key,
    required this.count,
    this.totalCount,
    this.recordLabel = 'سجل',
    this.customResultsText,
    this.filteredBadgeLabel = 'مفلترة',
    this.analyticsIcon = Icons.analytics_outlined,
    this.isFiltered = false,
    this.isLoading = false,
    this.onClear,
    this.activeFilters = const [],
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final showClearButton = isFiltered && onClear != null && !isLoading;
    final countText =
        customResultsText ??
        (totalCount != null && totalCount != count
            ? '$count من $totalCount $recordLabel'
            : '$count $recordLabel');

    return AnimatedSwitcher(
      duration: AppMotion.duration(context, AppMotion.fast),
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: Column(
        key: ValueKey('$count-$totalCount-$isFiltered-$recordLabel'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              // كبسولة عدد النتائج
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(
                    color: colors.outlineVariant.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      analyticsIcon,
                      size: 14.sp,
                      color: colors.primary,
                    ),
                    AppSpacing.hXs,
                    Text(
                      'النتائج: $countText',
                      style: AppTypography.labelSmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              if (isFiltered) ...[
                AppSpacing.hXs,
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(
                      color: colors.primary.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Text(
                    filteredBadgeLabel,
                    style: AppTypography.labelSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                ),
              ],

              const Spacer(),

              if (showClearButton)
                CustomButton.text(
                  text: 'مسح الكل',
                  icon: Icons.filter_alt_off_rounded,
                  size: AppButtonSize.small,
                  foregroundColor: colors.error,
                  onPressed: onClear,
                ),
            ],
          ),

          if (activeFilters.isNotEmpty) ...[
            AppSpacing.vXs,
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (final filter in activeFilters)
                  InputChip(
                    label: Text(
                      filter.label,
                      style: AppTypography.caption.copyWith(
                        color: colors.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    deleteIcon: Icon(
                      Icons.close_rounded,
                      size: 14.r,
                      color: colors.onPrimaryContainer,
                    ),
                    onDeleted: filter.onRemove,
                    backgroundColor: colors.primaryContainer.withValues(
                      alpha: 0.5,
                    ),
                    side: BorderSide(
                      color: colors.primary.withValues(alpha: 0.2),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
