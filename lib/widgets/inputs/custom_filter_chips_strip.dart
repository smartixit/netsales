import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_motion.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/inputs/custom_search_filter_option.dart';

/// شريط شرائح الفلترة الأفقية القابل للتمرير بأسلوب قيد (CustomFilterChipsStrip)
///
/// مكون عام مستقل (`<T>`) يدعم:
/// - التحديد الأحادي السلس لشرائح التصفية مع أيقونات اختيارية.
/// - شريحة "مسح الفلاتر" التلقائية عند وجود فلتر نشط.
/// - تخصيص كامل للمقاسات وباني الشريحة [chipBuilder].
class CustomFilterChipsStrip<T> extends StatelessWidget {
  const CustomFilterChipsStrip({
    super.key,
    required this.options,
    this.selectedValue,
    this.onSelected,
    this.hasActiveFilters = false,
    this.onClearAll,
    this.clearFiltersLabel = 'مسح الفلاتر',
    this.showClearChip = true,
    this.height,
    this.spacing,
    this.chipBuilder,
  });

  final List<CustomSearchFilterOption<T>> options;
  final T? selectedValue;
  final ValueChanged<T?>? onSelected;
  final bool hasActiveFilters;
  final VoidCallback? onClearAll;
  final String clearFiltersLabel;
  final bool showClearChip;
  final double? height;
  final double? spacing;
  final Widget Function(
    BuildContext context,
    CustomSearchFilterOption<T> option,
    bool isSelected,
  )?
  chipBuilder;

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) return const SizedBox.shrink();

    final colors = context.colors;
    final showClear = showClearChip && hasActiveFilters && onClearAll != null;
    final itemCount = options.length + (showClear ? 1 : 0);

    return SizedBox(
      height: height ?? 38.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (_, _) => SizedBox(width: spacing ?? AppSpacing.sm),
        itemBuilder: (context, index) {
          if (showClear && index == options.length) {
            return ActionChip(
              avatar: Icon(
                Icons.filter_alt_off_rounded,
                size: 16.sp,
                color: colors.error,
              ),
              label: Text(
                clearFiltersLabel,
                style: AppTypography.labelMedium.copyWith(
                  color: colors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: colors.error.withValues(alpha: 0.08),
              side: BorderSide(color: colors.error.withValues(alpha: 0.25)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              onPressed: onClearAll,
            );
          }

          final option = options[index];
          final isSelected = selectedValue == option.value;

          if (chipBuilder != null) {
            return chipBuilder!(context, option, isSelected);
          }

          return AnimatedContainer(
            duration: AppMotion.duration(context, AppMotion.fast),
            child: FilterChip(
              selected: isSelected,
              onSelected: onSelected != null
                  ? (_) => onSelected!(option.value)
                  : null,
              avatar: option.icon == null
                  ? null
                  : Icon(
                      option.icon,
                      size: 16.sp,
                      color: isSelected
                          ? colors.onPrimaryContainer
                          : colors.onSurfaceVariant,
                    ),
              label: Text(
                option.label,
                style: AppTypography.labelMedium.copyWith(
                  color: isSelected
                      ? colors.onPrimaryContainer
                      : colors.onSurface,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              showCheckmark: false,
              selectedColor: colors.primaryContainer.withValues(alpha: 0.8),
              backgroundColor: colors.surfaceContainerHighest.withValues(
                alpha: 0.45,
              ),
              side: BorderSide(
                color: isSelected
                    ? colors.primary.withValues(alpha: 0.45)
                    : colors.outlineVariant.withValues(alpha: 0.35),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
          );
        },
      ),
    );
  }
}
