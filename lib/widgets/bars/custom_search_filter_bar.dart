import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/animations/custom_interactive_bounce.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';

/// ============================================================================
/// كائن عنصر التصفية الموحد (CustomFilterItem)
/// ============================================================================
class CustomFilterItem<T> {
  final String label;
  final T value;
  final int? count;
  final IconData? icon;
  final bool highlightBadge;

  const CustomFilterItem({
    required this.label,
    required this.value,
    this.count,
    this.icon,
    this.highlightBadge = false,
  });
}

/// ============================================================================
/// شريط البحث والتصفية الموحد المستقل (CustomSearchFilterBar)
/// ============================================================================
/// ودجت عام ونقي (project-agnostic) يجمع بين حقل بحث نصي سريع مع زر مسح تلقائي،
/// وشريط قطاعي للتصفيات السريعة (Filter Chips) مع شارات العدادات التفاعلية.
class CustomSearchFilterBar<T> extends StatelessWidget {
  /// وحدة تحكم حقل البحث
  final TextEditingController searchController;

  /// نص التلميح داخل حقل البحث
  final String searchHint;

  /// تسمية حقل البحث الاختيارية
  final String? searchLabel;

  /// حدث تغير النص أثناء الكتابة
  final ValueChanged<String>? onSearchChanged;

  /// حدث تأكيد البحث
  final ValueChanged<String>? onSearchSubmitted;

  /// حدث مسح حقل البحث
  final VoidCallback? onSearchClear;

  /// إظهار حقل البحث
  final bool showSearch;

  /// قائمة عناصر التصفية
  final List<CustomFilterItem<T>>? filterItems;

  /// القيمة المحددة حالياً في التصفية
  final T? selectedFilter;

  /// حدث اختيار عنصر تصفية
  final ValueChanged<T>? onFilterChanged;

  /// حدث الضغط على زر التصفية المتقدمة (اختياري)
  final VoidCallback? onFilterButtonPressed;

  /// حالة تفعيل زر التصفية المتقدمة
  final bool isFilterButtonActive;

  /// هامش داخلي مخصص
  final EdgeInsetsGeometry? padding;

  /// ودجت إضافي يوضع بجانب حقل البحث
  final Widget? trailing;

  const CustomSearchFilterBar({
    super.key,
    required this.searchController,
    this.searchHint = 'بحث...',
    this.searchLabel,
    this.onSearchChanged,
    this.onSearchSubmitted,
    this.onSearchClear,
    this.showSearch = true,
    this.filterItems,
    this.selectedFilter,
    this.onFilterChanged,
    this.onFilterButtonPressed,
    this.isFilterButtonActive = false,
    this.padding,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasFilters = filterItems != null && filterItems!.isNotEmpty;

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. حقل البحث النصي مع الأزرار الجانبية
          if (showSearch) ...[
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: searchController,
                    label: searchLabel ?? 'بحث...',
                    hint: searchHint,
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: colors.onSurfaceVariant,
                      size: 20.r,
                    ),
                    suffixIcon: ValueListenableBuilder<TextEditingValue>(
                            valueListenable: searchController,
                            builder: (context, value, _) {
                              if (value.text.isEmpty) return const SizedBox.shrink();
                              return IconButton(
                                icon: Icon(
                                  Icons.close_rounded,
                                  size: 18.r,
                                  color: colors.onSurfaceVariant,
                                ),
                                onPressed: () {
                                  searchController.clear();
                                  onSearchClear?.call();
                                  onSearchChanged?.call('');
                                },
                              );
                            },
                          ),
                    textInputAction: TextInputAction.search,
                    onChanged: onSearchChanged,
                    onFieldSubmitted: onSearchSubmitted,
                  ),
                ),
                if (onFilterButtonPressed != null) ...[
                  AppSpacing.hXs,
                  CustomInteractiveBounce(
                    onTap: onFilterButtonPressed!,
                    child: Container(
                      width: 48.r,
                      height: 48.r,
                      decoration: BoxDecoration(
                        color: isFilterButtonActive
                            ? colors.primary.withValues(alpha: 0.15)
                            : colors.surfaceContainerHighest.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: isFilterButtonActive
                              ? colors.primary
                              : colors.outlineVariant.withValues(alpha: 0.3),
                          width: isFilterButtonActive ? 1.4.w : 1.w,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.tune_rounded,
                          size: 20.r,
                          color: isFilterButtonActive
                              ? colors.primary
                              : colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ],
                if (trailing != null) ...[
                  AppSpacing.hXs,
                  trailing!,
                ],
              ],
            ),
          ],

          // 2. شريط شرائح التصفية (Filter Chips)
          if (hasFilters) ...[
            if (showSearch) AppSpacing.vSm,
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: filterItems!.map((item) {
                  final isSelected = selectedFilter == item.value;
                  return Padding(
                    padding: EdgeInsets.only(left: AppSpacing.xs),
                    child: _FilterChipWidget<T>(
                      item: item,
                      isSelected: isSelected,
                      onTap: () => onFilterChanged?.call(item.value),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// ============================================================================
/// ودجت شريحة التصفية المفردة (_FilterChipWidget)
/// ============================================================================
class _FilterChipWidget<T> extends StatelessWidget {
  final CustomFilterItem<T> item;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChipWidget({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomInteractiveBounce(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primary.withValues(alpha: 0.12)
              : colors.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: AppRadius.fullRadius,
          border: Border.all(
            color: isSelected
                ? colors.primary
                : colors.outlineVariant.withValues(alpha: 0.3),
            width: isSelected ? 1.2.w : 1.w,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.icon != null) ...[
              Icon(
                item.icon,
                size: 15.r,
                color: isSelected ? colors.primary : colors.onSurfaceVariant,
              ),
              AppSpacing.hXxs,
            ],
            Text(
              item.label,
              style: AppTypography.labelSmall.copyWith(
                color: isSelected ? colors.primary : colors.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
            if (item.count != null && item.count! > 0) ...[
              AppSpacing.hXxs,
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
                decoration: BoxDecoration(
                  color: item.highlightBadge
                      ? colors.warning.withValues(alpha: 0.2)
                      : (isSelected
                          ? colors.primary.withValues(alpha: 0.2)
                          : colors.surfaceContainerHighest),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  item.count.toString(),
                  style: AppTypography.labelSmall.copyWith(
                    fontSize: 10.sp,
                    color: item.highlightBadge
                        ? colors.warning
                        : (isSelected ? colors.primary : colors.onSurfaceVariant),
                    fontWeight: FontWeight.bold,
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
