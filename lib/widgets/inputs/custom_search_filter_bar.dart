import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/presentation/enums/semantic_tone.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';
import 'package:netsales/widgets/inputs/custom_search_filter_option.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';

/// مكوّن البحث والفلترة الموحد العام لكافة شاشات وقوائم النظام (Enterprise Search & Filter Bar)
///
/// مستقل تماماً وخالٍ من أي مفاهيم مرتبطة بمجال محدد (Domain-Agnostic)،
// ignore: unintended_html_in_doc_comment
/// يدعم نمط Generic <T> لاستخدامه مع أي نوع بيانات للتصفية.
class CustomSearchFilterBar<T> extends StatelessWidget {
  const CustomSearchFilterBar({
    super.key,
    required this.searchController,
    this.searchHint = 'بحث بالاسم أو الرقم المرجعي...',
    this.searchQuery = '',
    this.onClearSearch,
    this.filterOptions = const [],
    this.selectedFilter,
    this.onFilterChanged,
    this.filterSheetTitle = 'تصفية النتائج',
    this.filterSheetSubtitle = 'اختر الحالة التي ترغب في عرضها',
    this.filterButtonTooltip = 'تصفية النتائج',
    this.showActiveFilterChip = true,
  });

  /// وحدة التحكم النصية بحقل البحث
  final TextEditingController searchController;

  /// تلميح حقل البحث
  final String searchHint;

  /// النص الحالي المستعلم عنه (لإظهار زر مسح البحث)
  final String searchQuery;

  /// دالة استدعاء عند تفريغ نص البحث
  final VoidCallback? onClearSearch;

  /// قائمة خيارات التصفية العامة
  final List<CustomSearchFilterOption<T>> filterOptions;

  /// القيمة الحالية المختارة للتصفية
  final T? selectedFilter;

  /// دالة استدعاء عند تغيير خيار التصفية
  final ValueChanged<T?>? onFilterChanged;

  /// عنوان شيت التصفية المنبثق
  final String filterSheetTitle;

  /// الوصف التوضيحي لشيت التصفية
  final String filterSheetSubtitle;

  /// تلميح زر التصفية
  final String filterButtonTooltip;

  /// هل تظهر شارة توضيح الفلتر النشط أسفل شريط البحث
  final bool showActiveFilterChip;

  Future<void> _openFilterSheet(BuildContext context) async {
    if (filterOptions.isEmpty || onFilterChanged == null) return;

    await CustomBottomSheet.showActions<void>(
      title: filterSheetTitle,
      subtitle: filterSheetSubtitle,
      leadingIcon: Icons.filter_list_rounded,
      items: filterOptions
          .map((option) {
            final isSelected = selectedFilter == option.value;
            return CustomBottomSheetActionItem(
              title: option.label,
              icon: option.icon ?? Icons.label_outline_rounded,
              trailing: isSelected
                  ? Icon(
                      Icons.check_circle_rounded,
                      color: context.colors.primary,
                      size: 20.r,
                    )
                  : null,
              onTap: () => onFilterChanged!(option.value),
            );
          })
          .toList(growable: false),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasActiveFilter = selectedFilter != null;
    final hasSearchQuery = searchQuery.trim().isNotEmpty;

    // استخراج اسم الخيار النشط للعرض في الشارة
    final activeOption = filterOptions
        .cast<CustomSearchFilterOption<T>?>()
        .firstWhere((opt) => opt?.value == selectedFilter, orElse: () => null);

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              // حقل البحث النصي الموحد
              Expanded(
                child: CustomTextField(
                  controller: searchController,
                  label: '',
                  hint: searchHint,
                  isRequired: false,
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: hasSearchQuery
                        ? colors.primary
                        : colors.onSurfaceVariant,
                    size: 20.r,
                  ),
                  suffixIcon: hasSearchQuery && onClearSearch != null
                      ? IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            size: 18.r,
                            color: colors.onSurfaceVariant,
                          ),
                          onPressed: () {
                            searchController.clear();
                            onClearSearch!();
                          },
                          tooltip: 'مسح نص البحث',
                        )
                      : null,
                ),
              ),

              // زر فتح شيت التصفية
              if (filterOptions.isNotEmpty && onFilterChanged != null) ...[
                AppSpacing.hXs,
                CustomInteractiveBounce(
                  onTap: () => _openFilterSheet(context),
                  child: Container(
                    width: 48.r,
                    height: 48.r,
                    decoration: BoxDecoration(
                      color: hasActiveFilter
                          ? colors.primary.withValues(alpha: .12)
                          : colors.surfaceContainer,
                      borderRadius: BorderRadius.circular(AppRadius.input),
                      border: Border.all(
                        color: hasActiveFilter
                            ? colors.primary
                            : colors.outlineVariant.withValues(alpha: .5),
                        width: hasActiveFilter ? 1.5 : 1.0,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.tune_rounded,
                          size: 20.r,
                          color: hasActiveFilter
                              ? colors.primary
                              : colors.onSurface,
                        ),
                        if (hasActiveFilter)
                          Positioned(
                            top: 8.r,
                            right: 8.r,
                            child: Container(
                              width: 8.r,
                              height: 8.r,
                              decoration: BoxDecoration(
                                color: colors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: colors.surface,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),

          // شريط توضيح الفلتر النشط إن وجد
          if (showActiveFilterChip &&
              hasActiveFilter &&
              activeOption != null) ...[
            AppSpacing.vXs,
            Row(
              children: [
                CustomStatusBadge(
                  label: activeOption.label,
                  icon: activeOption.icon,
                  tone: SemanticTone.primary,
                  isCompact: true,
                ),
                AppSpacing.hXxs,
                CustomInteractiveBounce(
                  onTap: () => onFilterChanged?.call(null),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.r,
                      vertical: 3.r,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.close_rounded,
                          size: 13.r,
                          color: colors.onSurfaceVariant,
                        ),
                        AppSpacing.hXxs,
                        Text(
                          'إلغاء التصفية',
                          style: AppTypography.labelSmall.copyWith(
                            color: colors.onSurfaceVariant,
                            fontSize: 10.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
