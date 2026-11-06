
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import '../models/app_data_grid_column.dart';

typedef AppDataGridEditHandler<T> = Future<T?> Function(T row, AppDataGridColumn<T> column, Object? value);
typedef AppDataGridEditFailureHandler = void Function(Object error);

/// Long-lived data adapter. It must be owned by the feature/controller, not created in build().
class NetSalesDataGridSource<T> extends DataGridSource {
  NetSalesDataGridSource({
    required List<T> items,
    required List<AppDataGridColumn<T>> columns,
    this.onEdit,
    this.onEditFailure,
    this.onRefresh,
    this.onLoadMore,
    List<String> groupByColumns = const <String>[],
  }) : _columns = List<AppDataGridColumn<T>>.of(columns),
       _items = List<T>.of(items) {
    _validateColumns(_columns);
    _buildRows(notify: false);
    for (final name in groupByColumns) {
      if (_columns.any((column) => column.name == name)) {
        addColumnGroup(ColumnGroup(name: name, sortGroupRows: true));
      }
    }
  }

  List<AppDataGridColumn<T>> _columns;
  final List<T> _items;
  final List<DataGridRow> _rows = <DataGridRow>[];
  final Map<DataGridRow, T> _modelsByRow = HashMap<DataGridRow, T>.identity();
  final AppDataGridEditHandler<T>? onEdit;
  final AppDataGridEditFailureHandler? onEditFailure;
  final Future<void> Function()? onRefresh;
  final Future<void> Function()? onLoadMore;
  Object? _pendingEditValue;

  List<AppDataGridColumn<T>> get columns => List.unmodifiable(_columns);
  List<T> get items => List.unmodifiable(_items);
  @override
  List<DataGridRow> get rows => _rows;
  T? itemForRow(DataGridRow row) => _modelsByRow[row];
  List<T> itemsForRows(Iterable<DataGridRow> rows) => rows.map(itemForRow).whereType<T>().toList(growable: false);

  void replaceRows(List<T> items) {
    _items..clear()..addAll(items);
    _buildRows(notify: true);
  }

  void updateColumns(List<AppDataGridColumn<T>> columns) {
    _validateColumns(columns);
    _columns = List<AppDataGridColumn<T>>.of(columns);
    _buildRows(notify: true);
  }

  void reorderColumns(int from, int to) {
    if (from < 0 || from >= _columns.length || to < 0 || to >= _columns.length || from == to) return;
    final moved = _columns.removeAt(from);
    _columns.insert(to, moved);
    _buildRows(notify: true);
  }

  void updateColumnWidth(String name, double width) {
    _columns = _columns.map((column) =>
      column.name == name ? column.copyWith(width: width) : column
    ).toList(growable: true);
  }

  void _validateColumns(List<AppDataGridColumn<T>> columns) {
    if (columns.isEmpty || !columns.any((column) => column.visible)) {
      throw ArgumentError('DataGrid requires at least one visible column.');
    }
    final names = columns.map((column) => column.name).toSet();
    if (names.length != columns.length) {
      throw ArgumentError('DataGrid column names must be unique.');
    }
  }

  void _buildRows({required bool notify}) {
    _rows.clear();
    _modelsByRow.clear();
    for (final item in _items) {
      final row = DataGridRow(cells: _columns.map((column) =>
        DataGridCell<dynamic>(columnName: column.name, value: column.valueGetter(item))
      ).toList(growable: false));
      _rows.add(row);
      _modelsByRow[row] = item;
    }
    if (notify) notifyDataSourceListeners();
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final item = itemForRow(row);
    return DataGridRowAdapter(
      cells: _columns.where((column) => column.visible).map((column) {
        final cell = row.getCells().firstWhere((value) => value.columnName == column.name);
        return Builder(builder: (context) {
          final child = item != null && column.cellBuilder != null
              ? column.cellBuilder!(context, item, cell.value)
              : Text(cell.value?.toString() ?? '—', maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium);
          return Container(
            alignment: column.cellAlignment,
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 14),
            child: child,
          );
        });
      }).toList(growable: false),
    );
  }

  @override
  bool onCellBeginEdit(DataGridRow row, RowColumnIndex index, GridColumn column) {
    final definition = _columnFor(column.columnName);
    return definition?.allowEditing == true && onEdit != null;
  }

  @override
  Widget? buildEditWidget(DataGridRow row, RowColumnIndex index, GridColumn column, CellSubmit submitCell) {
    final item = itemForRow(row);
    final definition = _columnFor(column.columnName);
    if (item == null || definition == null || !definition.allowEditing) return null;
    final initialValue = row.getCells().firstWhere((cell) => cell.columnName == column.columnName).value;
    _pendingEditValue = initialValue;
    void changed(Object? value) => _pendingEditValue = value;
    if (definition.editorBuilder != null) {
      return definition.editorBuilder!(row: item, initialValue: initialValue, onChanged: changed, onSubmit: submitCell);
    }
    return TextFormField(
      initialValue: initialValue?.toString() ?? '',
      autofocus: true,
      maxLines: 1,
      onChanged: changed,
      onFieldSubmitted: (value) {
        changed(value);
        submitCell();
      },
      decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8), border: OutlineInputBorder()),
    );
  }

  @override
  Future<bool> canSubmitCell(DataGridRow row, RowColumnIndex index, GridColumn column) async {
    final item = itemForRow(row);
    final definition = _columnFor(column.columnName);
    if (item == null || definition == null) return false;
    final value = definition.parseEditedValue?.call(_pendingEditValue) ?? _pendingEditValue;
    return definition.validateEditedValue?.call(item, value) ?? true;
  }

  @override
  Future<void> onCellSubmit(DataGridRow row, RowColumnIndex index, GridColumn column) async {
    final item = itemForRow(row);
    final definition = _columnFor(column.columnName);
    if (item == null || definition == null || onEdit == null) return;
    final value = definition.parseEditedValue?.call(_pendingEditValue) ?? _pendingEditValue;
    try {
      final updatedItem = await onEdit!(item, definition, value);
      if (updatedItem != null) _replaceRow(row, updatedItem);
    } catch (error) {
      onEditFailure?.call(error);
    } finally {
      _pendingEditValue = null;
    }
  }

  @override
  void onCellCancelEdit(DataGridRow row, RowColumnIndex index, GridColumn column) {
    _pendingEditValue = null;
  }

  @override
  Future<void> handleRefresh() async => onRefresh?.call();

  @override
  Future<void> handleLoadMoreRows() async => onLoadMore?.call();

  AppDataGridColumn<T>? _columnFor(String name) {
    for (final column in _columns) {
      if (column.name == name) return column;
    }
    return null;
  }

  void _replaceRow(DataGridRow oldRow, T updatedItem) {
    final index = _rows.indexOf(oldRow);
    if (index < 0) return;
    _items[index] = updatedItem;
    final updatedRow = DataGridRow(
      cells: _columns.map((column) => DataGridCell<dynamic>(
        columnName: column.name,
        value: column.valueGetter(updatedItem),
      )).toList(growable: false),
    );
    _rows[index] = updatedRow;
    _modelsByRow.remove(oldRow);
    _modelsByRow[updatedRow] = updatedItem;
    notifyDataSourceListeners();
  }
}
