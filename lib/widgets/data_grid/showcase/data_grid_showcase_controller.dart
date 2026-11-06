
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/core/utils/date_formatter.dart';
import 'package:netsales/widgets/data_grid/adapters/app_data_grid_export_controller.dart';
import 'package:netsales/widgets/data_grid/adapters/net_sales_data_grid_source.dart';
import 'package:netsales/widgets/data_grid/models/app_data_grid_column.dart';
import 'package:netsales/widgets/data_grid/models/app_data_grid_features.dart';
import 'package:netsales/widgets/data_grid/models/app_data_grid_pagination.dart';
import 'package:netsales/widgets/data_grid/models/app_data_grid_state.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class DataGridShowcaseRecord {
  const DataGridShowcaseRecord({
    required this.id,
    required this.reference,
    required this.customer,
    required this.region,
    required this.status,
    required this.amount,
    required this.createdAt,
    required this.channel,
  });

  final int id;
  final String reference;
  final String customer;
  final String region;
  final String status;
  final num amount;
  final DateTime createdAt;
  final String channel;
}

class DataGridShowcaseController extends GetxController {
  final isDarkMode = false.obs;
  final isRtl = true.obs;
  final viewState = AppDataGridViewState.success.obs;
  final searchController = TextEditingController();
  final selectedRows = <DataGridShowcaseRecord>[].obs;
  final currentPage = 1.obs;
  final visibleColumns = <String>{}.obs;
  final groupingEnabled = false.obs;
  final exportController = AppDataGridExportController();

  late final NetSalesDataGridSource<DataGridShowcaseRecord> source;

  final List<DataGridShowcaseRecord> _records = List.generate(48, (index) {
    const statuses = ['مكتمل', 'قيد المراجعة', 'معلّق', 'مرفوض'];
    const regions = ['صنعاء', 'تعز', 'عدن', 'إب', 'الحديدة'];
    const channels = ['تحويل بنكي', 'محفظة', 'نقدي'];
    const customers = ['مؤسسة الرواد التجارية', 'شبكة المستقبل', 'مبيعات الاتصالات', 'مؤسسة النخبة', 'شبكة الأفق'];
    return DataGridShowcaseRecord(
      id: index + 1,
      reference: 'NS-${(index + 1).toString().padLeft(5, '0')}',
      customer: customers[index % customers.length],
      region: regions[index % regions.length],
      status: statuses[index % statuses.length],
      amount: 1250 + (index * 173.45),
      createdAt: DateTime(2026, 10, 1).add(Duration(days: index)),
      channel: channels[index % channels.length],
    );
  });

  @override
  void onInit() {
    super.onInit();
    source = NetSalesDataGridSource<DataGridShowcaseRecord>(
      items: _records,
      columns: _buildColumns(),
      onEdit: _editRecord,
      onRefresh: () async {
        await Future<void>.delayed(const Duration(milliseconds: 180));
        source.replaceRows(_records);
      },
      onEditFailure: (error) => Get.snackbar('تعذر حفظ التعديل', error.toString()),
    );
    visibleColumns.addAll(source.columns.map((column) => column.name));
  }

  List<AppDataGridColumn<DataGridShowcaseRecord>> _buildColumns() => [
    AppDataGridColumn<DataGridShowcaseRecord>(
      name: 'reference',
      label: 'المرجع',
      width: 130,
      valueGetter: (row) => row.reference,
    ),
    AppDataGridColumn<DataGridShowcaseRecord>(
      name: 'customer',
      label: 'العميل',
      width: 230,
      minimumWidth: 180,
      valueGetter: (row) => row.customer,
      allowEditing: true,
      editorBuilder: ({required row, required initialValue, required onChanged, required onSubmit}) =>
          TextFormField(
            initialValue: initialValue?.toString(),
            autofocus: true,
            onChanged: onChanged,
            onFieldSubmitted: (_) => onSubmit(),
          ),
      parseEditedValue: (value) => value?.toString().trim(),
      validateEditedValue: (_, value) => value is String && value.trim().length >= 3,
    ),
    AppDataGridColumn<DataGridShowcaseRecord>(
      name: 'region',
      label: 'المنطقة',
      width: 130,
      valueGetter: (row) => row.region,
    ),
    AppDataGridColumn<DataGridShowcaseRecord>(
      name: 'status',
      label: 'الحالة',
      width: 145,
      valueGetter: (row) => row.status,
      cellBuilder: (context, row, value) {
        final tone = switch (row.status) {
          'مكتمل' => context.colors.success,
          'قيد المراجعة' => context.colors.warning,
          'معلّق' => context.colors.info,
          _ => context.colors.error,
        };
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: tone.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(row.status, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: tone, fontWeight: FontWeight.w700)),
        );
      },
    ),
    AppDataGridColumn<DataGridShowcaseRecord>(
      name: 'amount',
      label: 'المبلغ',
      width: 145,
      headerAlignment: AlignmentDirectional.centerEnd,
      cellAlignment: AlignmentDirectional.centerEnd,
      valueGetter: (row) => row.amount,
      cellBuilder: (context, row, value) => Text(
        AmountFormatter.formatValue(row.amount, decimalPlaces: 2),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    ),
    AppDataGridColumn<DataGridShowcaseRecord>(
      name: 'createdAt',
      label: 'تاريخ الإنشاء',
      width: 155,
      valueGetter: (row) => row.createdAt,
      cellBuilder: (context, row, value) => Text(DateFormatter.date(row.createdAt)),
    ),
    AppDataGridColumn<DataGridShowcaseRecord>(
      name: 'channel',
      label: 'قناة الدفع',
      width: 140,
      valueGetter: (row) => row.channel,
    ),
  ];

  Future<DataGridShowcaseRecord?> _editRecord(
    DataGridShowcaseRecord row,
    AppDataGridColumn<DataGridShowcaseRecord> column,
    Object? value,
  ) async {
    // Local showcase only. Production edits must be delegated through a Use Case.
    await Future<void>.delayed(const Duration(milliseconds: 100));
    if (value is! String || value.trim().isEmpty) return null;
    if (column.name != 'customer') return row;
    final updated = DataGridShowcaseRecord(
      id: row.id,
      reference: row.reference,
      customer: value.trim(),
      region: row.region,
      status: row.status,
      amount: row.amount,
      createdAt: row.createdAt,
      channel: row.channel,
    );
    final index = _records.indexWhere((record) => record.id == row.id);
    if (index >= 0) _records[index] = updated;
    return updated;
  }

  void setDarkMode(bool value) => isDarkMode.value = value;
  void setRtl(bool value) => isRtl.value = value;
  void setViewState(AppDataGridViewState value) => viewState.value = value;

  void setSearch(String value) {
    currentPage.value = 1;
    selectedRows.clear();
    final query = value.trim().toLowerCase();
    final filtered = _records.where((row) =>
      row.reference.toLowerCase().contains(query) ||
      row.customer.toLowerCase().contains(query) ||
      row.region.toLowerCase().contains(query) ||
      row.status.toLowerCase().contains(query)
    ).toList(growable: false);
    source.replaceRows(filtered);
    viewState.value = filtered.isEmpty ? AppDataGridViewState.noResults : AppDataGridViewState.success;
  }

  void clearSearch() {
    currentPage.value = 1;
    selectedRows.clear();
    searchController.clear();
    source.replaceRows(_records);
    viewState.value = AppDataGridViewState.success;
  }

  void toggleColumn(String name) {
    if (visibleColumns.length == 1 && visibleColumns.contains(name)) return;
    final updated = source.columns.map((column) =>
      column.name == name ? column.copyWith(visible: !column.visible) : column
    ).toList(growable: false);
    source.updateColumns(updated);
    if (visibleColumns.contains(name)) {
      visibleColumns.remove(name);
    } else {
      visibleColumns.add(name);
    }
  }

  void onColumnsReordered() => visibleColumns.refresh();

  void toggleGrouping() {
    groupingEnabled.toggle();
    source.clearColumnGroups();
    if (groupingEnabled.value) {
      source.addColumnGroup(ColumnGroup(name: 'status', sortGroupRows: true));
    }
  }

  void onSelectionChanged(List<DataGridShowcaseRecord> selected, List<DataGridShowcaseRecord> deselected) {
    final next = selectedRows.toList();
    next.removeWhere((row) => deselected.any((value) => value.id == row.id));
    for (final row in selected) {
      if (!next.any((value) => value.id == row.id)) next.add(row);
    }
    selectedRows.assignAll(next);
  }

  AppDataGridPagination get pagination => AppDataGridPagination.pageBased(
    currentPage: currentPage.value,
    totalPages: source.items.isEmpty ? 1 : (source.items.length / 10).ceil(),
    onPageChanged: (page) => currentPage.value = page,
    delegate: source,
    onPageNavigationEnd: (pageIndex) => currentPage.value = pageIndex + 1,
  );

  AppDataGridFeatures get features => const AppDataGridFeatures(
    allowSorting: true,
    allowMultiColumnSorting: true,
    allowFiltering: true,
    allowSelection: true,
    allowMultiSelection: true,
    showCheckboxColumn: true,
    allowColumnResizing: true,
    allowColumnDragging: true,
    allowEditing: true,
    allowGrouping: true,
    frozenColumnsCount: 1,
    allowPullToRefresh: true,
    stackedHeaderRows: [
      StackedHeaderRow(cells: [
        StackedHeaderCell(
          text: 'بيانات العملية',
          columnNames: ['reference', 'customer', 'region'],
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: const Text('بيانات العملية'),
          ),
        ),
        StackedHeaderCell(
          text: 'تفاصيل المعالجة',
          columnNames: ['status', 'amount', 'createdAt', 'channel'],
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: const Text('تفاصيل المعالجة'),
          ),
        ),
      ]),
    ],
    tableSummaryRows: [
      GridTableSummaryRow(
        showSummaryInRow: true,
        title: 'عدد الصفوف المحملة: {Count}',
        columns: [
          GridSummaryColumn(
            name: 'Count',
            columnName: 'reference',
            summaryType: GridSummaryType.count,
          ),
        ],
        position: GridTableSummaryRowPosition.bottom,
      ),
    ],
    footer: Container(
      height: 42,
      alignment: AlignmentDirectional.centerStart,
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 12),
      child: const Text('بيانات تجريبية للمعاينة — لا تمثل سجلات فعلية.'),
    ),
    footerHeight: 42,
    rowHeight: 62,
    headerRowHeight: 56,
    defaultColumnWidth: 150,
    rowsPerPage: 10,
  );

  @override
  void onClose() {
    searchController.dispose();
    source.dispose();
    super.onClose();
  }
}
