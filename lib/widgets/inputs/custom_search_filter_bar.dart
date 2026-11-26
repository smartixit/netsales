import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/cards/custom_kpi_card_data.dart';
import 'package:netsales/widgets/indicators/custom_results_counter_bar.dart';
import 'package:netsales/widgets/indicators/custom_status_summary_strip.dart';
import 'package:netsales/widgets/inputs/custom_filter_chips_strip.dart';
import 'package:netsales/widgets/inputs/custom_search_field.dart';
import 'package:netsales/widgets/inputs/custom_search_filter_option.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';

export 'package:netsales/widgets/cards/custom_kpi_card_data.dart';
export 'package:netsales/widgets/indicators/custom_results_counter_bar.dart';
export 'package:netsales/widgets/inputs/custom_filter_chips_strip.dart';
export 'package:netsales/widgets/inputs/custom_search_field.dart';
export 'package:netsales/widgets/inputs/custom_search_filter_option.dart';

/// أنماط عرض خيارات الفلترة في [CustomSearchFilterBar]
enum SearchFilterDisplayMode {
  /// شرائح فلترة أفقية مباشرة أسفل حقل البحث (أسلوب قيد المعتمد)
  inlineChips,

  /// زر فلترة يفتح ورقة خيارات سفلية
  bottomSheet,

  /// الجمع بين الشرائح الأفقية وزر الورقة السفلية
  both,
}

/// مكوّن البحث والفلترة ومؤشرات الإحصائيات الموحد العام (CustomSearchFilterBar)
///
/// مصمم ليكون مستقلاً تماماً وقابلاً للتخصيص الكامل وإعادة الاستخدام في أي مشروع:
/// 1. شريط بطاقات إحصائيات الفلترة (KPIs) الاختياري عبر [CustomStatusSummaryStrip].
/// 2. حقل البحث الكبسولي النظيف [CustomSearchField] مع دعم مسح QR والإجراءات الإضافية.
/// 3. شرائح الفلترة الأفقية [CustomFilterChipsStrip] أو شيت التصفية المنبثق.
/// 4. شريط عداد النتائج والشارات النشطة [CustomResultsCounterBar].
class CustomSearchFilterBar<T> extends StatelessWidget {
  const CustomSearchFilterBar({
    super.key,
    required this.searchController,
    this.searchHint = 'بحث بالاسم أو الرقم المرجعي...',
    this.searchQuery = '',
    this.onSearchChanged,
    this.onSearchSubmitted,
    this.onClearSearch,
    this.showSearchField = true,
    this.showScanner = false,
    this.onScanPressed,
    this.trailingActions = const [],
    this.filterOptions = const [],
    this.selectedFilter,
    this.onFilterChanged,
    this.filterDisplayMode = SearchFilterDisplayMode.inlineChips,
    this.filterSheetTitle = 'تصفية النتائج',
    this.filterSheetSubtitle = 'اختر الحالة التي ترغب في عرضها',
    this.filterButtonTooltip = 'تصفية النتائج',
    this.showActiveFilterChip = true,
    this.hasActiveFilters,
    this.onClearAll,
    this.kpiCards = const [],
    this.selectedKpiKey,
    this.isKpiLoading = false,
    this.onKpiSelected,
    this.resultsCount,
    this.totalCount,
    this.recordLabel = 'سجل',
    this.customResultsText,
    this.activeFilters = const [],
    this.isLoadingResults = false,
    this.padding,
  });

  // ── البحث ──
  final TextEditingController searchController;
  final String searchHint;
  final String searchQuery;
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String>? onSearchSubmitted;
  final VoidCallback? onClearSearch;
  final bool showSearchField;

  // ── أزرار جانبية للبحث (QR أو إجراءات مخصصة) ──
  final bool showScanner;
  final VoidCallback? onScanPressed;
  final List<Widget> trailingActions;

  // ── الفلترة ──
  final List<CustomSearchFilterOption<T>> filterOptions;
  final T? selectedFilter;
  final ValueChanged<T?>? onFilterChanged;
  final SearchFilterDisplayMode filterDisplayMode;
  final String filterSheetTitle;
  final String filterSheetSubtitle;
  final String filterButtonTooltip;
  final bool showActiveFilterChip;
  final bool? hasActiveFilters;
  final VoidCallback? onClearAll;

  // ── كروت KPI إحصائيات الفلترة ──
  final List<CustomKpiCardData> kpiCards;
  final String? selectedKpiKey;
  final bool isKpiLoading;
  final ValueChanged<String?>? onKpiSelected;

  // ── عداد النتائج ──
  final int? resultsCount;
  final int? totalCount;
  final String recordLabel;
  final String? customResultsText;
  final List<ActiveFilterItem> activeFilters;
  final bool isLoadingResults;

  final EdgeInsetsGeometry? padding;

  bool get _hasActiveFilters =>
      hasActiveFilters ??
      (selectedFilter != null ||
          selectedKpiKey != null ||
          searchQuery.trim().isNotEmpty ||
          activeFilters.isNotEmpty);

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
    final showChips =
        filterOptions.isNotEmpty &&
        (filterDisplayMode == SearchFilterDisplayMode.inlineChips ||
            filterDisplayMode == SearchFilterDisplayMode.both);
    final showFilterButton =
        filterOptions.isNotEmpty &&
        onFilterChanged != null &&
        (filterDisplayMode == SearchFilterDisplayMode.bottomSheet ||
            filterDisplayMode == SearchFilterDisplayMode.both);
    final showResultsBar = resultsCount != null || customResultsText != null;

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. كروت KPI إحصائيات الفلترة
          if (kpiCards.isNotEmpty)
            CustomStatusSummaryStrip(
              cards: kpiCards,
              selectedKey: selectedKpiKey,
              isLoading: isKpiLoading,
              onSelectKey: onKpiSelected,
            ),

          // 2. شريط حقل البحث والأزرار الجانبية
          if (showSearchField)
            Row(
              children: [
                Expanded(
                  child: CustomSearchField(
                    controller: searchController,
                    hintText: searchHint,
                    searchQuery: searchQuery,
                    onChanged: onSearchChanged,
                    onSubmitted: onSearchSubmitted,
                    onClear: onClearSearch,
                  ),
                ),
                if (showScanner && onScanPressed != null) ...[
                  AppSpacing.hSm,
                  CustomButton.icon(
                    icon: Icons.qr_code_scanner_rounded,
                    tooltip: 'مسح رمز QR',
                    backgroundColor: colors.primaryContainer.withValues(
                      alpha: 0.7,
                    ),
                    foregroundColor: colors.onPrimaryContainer,
                    shape: AppButtonShape.rounded,
                    onPressed: onScanPressed,
                  ),
                ],
                if (showFilterButton) ...[
                  AppSpacing.hSm,
                  CustomButton.icon(
                    icon: Icons.tune_rounded,
                    tooltip: filterButtonTooltip,
                    backgroundColor: selectedFilter != null
                        ? colors.primaryContainer
                        : colors.surfaceContainerHighest.withValues(alpha: 0.5),
                    foregroundColor: selectedFilter != null
                        ? colors.primary
                        : colors.onSurfaceVariant,
                    shape: AppButtonShape.rounded,
                    onPressed: () => _openFilterSheet(context),
                  ),
                ],
                for (final action in trailingActions) ...[
                  AppSpacing.hSm,
                  action,
                ],
              ],
            ),

          // 3. شرائح الفلترة الأفقية (بأسلوب قيد)
          if (showChips) ...[
            if (showSearchField) AppSpacing.vMd,
            CustomFilterChipsStrip<T>(
              options: filterOptions,
              selectedValue: selectedFilter,
              onSelected: onFilterChanged,
              hasActiveFilters: _hasActiveFilters,
              onClearAll:
                  onClearAll ??
                  () {
                    searchController.clear();
                    onClearSearch?.call();
                    onFilterChanged?.call(null);
                    onKpiSelected?.call(null);
                  },
            ),
          ],

          // 4. شريط عداد النتائج والفلاتر النشطة
          if (showResultsBar) ...[
            SizedBox(height: showChips ? AppSpacing.sm : AppSpacing.xs),
            CustomResultsCounterBar(
              count: resultsCount ?? 0,
              totalCount: totalCount,
              recordLabel: recordLabel,
              customResultsText: customResultsText,
              isFiltered: _hasActiveFilters,
              isLoading: isLoadingResults,
              activeFilters: activeFilters,
              onClear:
                  onClearAll ??
                  () {
                    searchController.clear();
                    onClearSearch?.call();
                    onFilterChanged?.call(null);
                    onKpiSelected?.call(null);
                  },
            ),
          ],
        ],
      ),
    );
  }
}
