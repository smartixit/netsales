
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_themes.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/data_grid/app_data_grid.dart';
import 'package:netsales/widgets/data_grid/models/app_data_grid_state.dart';
import 'package:netsales/widgets/menus/custom_popup_menu.dart';
import 'data_grid_showcase_controller.dart';

class DataGridShowcaseScreen extends GetView<DataGridShowcaseController> {
  const DataGridShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dark = controller.isDarkMode.value;
      final rtl = controller.isRtl.value;
      return Theme(
        data: dark ? AppThemes.dark : AppThemes.light,
        child: Directionality(
          textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('معرض نظام الجداول'),
              actions: [
                CustomButton.icon(
                  icon: Icons.light_mode_outlined,
                  tooltip: 'الوضع الفاتح/الداكن',
                  onPressed: () => controller.setDarkMode(!dark),
                ),
                CustomButton.icon(
                  icon: Icons.swap_horiz_rounded,
                  tooltip: 'RTL / LTR',
                  onPressed: () => controller.setRtl(!rtl),
                ),
              ],
            ),
            body: Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  _ShowcaseSettings(
                    dark: dark,
                    rtl: rtl,
                    grouping: controller.groupingEnabled.value,
                    onDarkChanged: controller.setDarkMode,
                    onRtlChanged: controller.setRtl,
                    onStateChanged: controller.setViewState,
                    onGroupingChanged: controller.toggleGrouping,
                  ),
                  AppSpacing.vSm,
                  Expanded(
                    child: AppDataGrid<DataGridShowcaseRecord>(
                      source: controller.source,
                      features: controller.features,
                      viewState: controller.viewState.value,
                      title: 'سجل العمليات التجارية',
                      subtitle: 'معاينة الفرز والتصفية والتحديد وتخصيص الأعمدة والتصدير',
                      searchController: controller.searchController,
                      onSearchChanged: controller.setSearch,
                      onClearSearch: controller.clearSearch,
                      pagination: controller.pagination,
                      exportController: controller.exportController,
                      exportFileName: 'NetSales_DataGrid_Showcase',
                      selectedCount: controller.selectedRows.length,
                      onSelectionChanged: controller.onSelectionChanged,
                      headerActions: [
                        _ColumnChooser(
                          columns: controller.source.columns,
                          onToggle: controller.toggleColumn,
                        ),
                      ],
                      noResultsQuery: controller.searchController.text,
                      noResultsAction: controller.clearSearch,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _ShowcaseSettings extends StatelessWidget {
  const _ShowcaseSettings({
    required this.dark,
    required this.rtl,
    required this.grouping,
    required this.onDarkChanged,
    required this.onRtlChanged,
    required this.onStateChanged,
    required this.onGroupingChanged,
  });

  final bool dark;
  final bool rtl;
  final bool grouping;
  final ValueChanged<bool> onDarkChanged;
  final ValueChanged<bool> onRtlChanged;
  final ValueChanged<AppDataGridViewState> onStateChanged;
  final VoidCallback onGroupingChanged;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: AppSpacing.xs,
    runSpacing: AppSpacing.xs,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      CustomButton.outline(text: dark ? 'Dark' : 'Light', onPressed: () => onDarkChanged(!dark)),
      CustomButton.outline(text: rtl ? 'RTL' : 'LTR', onPressed: () => onRtlChanged(!rtl)),
      CustomButton.outline(text: grouping ? 'إلغاء التجميع' : 'تجميع حسب الحالة', onPressed: onGroupingChanged),
      CustomButton.text(text: 'تحميل', onPressed: () => onStateChanged(AppDataGridViewState.loading)),
      CustomButton.text(text: 'فارغ', onPressed: () => onStateChanged(AppDataGridViewState.empty)),
      CustomButton.text(text: 'خطأ', onPressed: () => onStateChanged(AppDataGridViewState.error)),
      CustomButton.text(text: 'البيانات', onPressed: () => onStateChanged(AppDataGridViewState.success)),
    ],
  );
}

class _ColumnChooser extends StatelessWidget {
  const _ColumnChooser({required this.columns, required this.onToggle});
  final List<dynamic> columns;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) => CustomPopupMenu<String>(
    tooltip: 'إدارة الأعمدة',
    triggerIcon: Icons.view_column_outlined,
    items: columns.map((column) => CustomPopupItem<String>(
      value: column.name as String,
      label: column.label as String,
      icon: column.visible as bool ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
    )).toList(growable: false),
    onSelected: onToggle,
  );
}
