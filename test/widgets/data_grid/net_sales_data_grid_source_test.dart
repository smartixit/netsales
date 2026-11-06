import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/widgets/data_grid/adapters/net_sales_data_grid_source.dart';
import 'package:netsales/widgets/data_grid/models/app_data_grid_column.dart';
import 'package:netsales/widgets/data_grid/models/app_data_grid_features.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:netsales/widgets/data_grid/models/app_data_grid_pagination.dart';

class _GridRecord {
  const _GridRecord(this.id, this.name);
  final int id;
  final String name;
}

void main() {
  late List<AppDataGridColumn<_GridRecord>> columns;
  late NetSalesDataGridSource<_GridRecord> source;

  setUp(() {
    columns = [
      AppDataGridColumn<_GridRecord>(
        name: 'id',
        label: 'ID',
        valueGetter: (row) => row.id,
      ),
      AppDataGridColumn<_GridRecord>(
        name: 'name',
        label: 'Name',
        valueGetter: (row) => row.name,
      ),
    ];
    source = NetSalesDataGridSource<_GridRecord>(
      items: const [_GridRecord(1, 'Alpha'), _GridRecord(2, 'Beta')],
      columns: columns,
    );
  });

  test('maps each data row back to its original typed model', () {
    expect(source.rows, hasLength(2));
    expect(source.itemForRow(source.rows.first)?.id, 1);
    expect(source.rows.first.getCells().map((cell) => cell.value).toList(), [
      1,
      'Alpha',
    ]);
  });

  test('replaces source records and rebuilds grid rows', () {
    source.replaceRows(const [_GridRecord(3, 'Gamma')]);

    expect(source.rows, hasLength(1));
    expect(source.itemForRow(source.rows.single)?.name, 'Gamma');
  });

  test('reorders columns while preserving each row cell mapping', () {
    source.reorderColumns(0, 1);

    expect(source.columns.map((column) => column.name).toList(), [
      'name',
      'id',
    ]);
    expect(
      source.rows.first.getCells().map((cell) => cell.columnName).toList(),
      ['id', 'name'],
    );
    expect(source.rows.first.getCells().map((cell) => cell.value).toList(), [
      1,
      'Alpha',
    ]);
  });

  test('rejects hiding every column', () {
    expect(
      () => source.updateColumns(
        columns.map((column) => column.copyWith(visible: false)).toList(),
      ),
      throwsArgumentError,
    );
  });

  test('rejects duplicate column names', () {
    expect(
      () => source.updateColumns([columns.first, columns.first]),
      throwsArgumentError,
    );
  });

  test('cursor pagination never fabricates a page total', () {
    final pagination = AppDataGridPagination.cursorBased(
      hasPrevious: true,
      hasNext: true,
      onPrevious: () async {},
      onNext: () async {},
      pageLabel: 'دفعة 2',
    );
    expect(pagination.totalPages, 0);
    expect(pagination.mode, AppDataGridPaginationMode.cursorBased);
  });

  test('remote data mode disables local filtering', () {
    const features = AppDataGridFeatures(dataMode: AppDataGridDataMode.remote);
    expect(features.canFilterLocally, isFalse);
  });

  test('editing automatically enables cell navigation', () {
    const features = AppDataGridFeatures(allowEditing: true);
    expect(features.effectiveNavigationMode, GridNavigationMode.cell);
  });

  test('appends fetched rows without dropping loaded records', () {
    source.appendRows(const [_GridRecord(3, 'Gamma')]);
    expect(source.items.map((item) => item.id).toList(), [1, 2, 3]);
    expect(source.rows, hasLength(3));
  });

  test('remote page changes are delegated with zero-based indexes', () async {
    var oldIndex = -1;
    var newIndex = -1;
    final remoteSource = NetSalesDataGridSource<_GridRecord>(
      items: const [_GridRecord(1, 'Alpha')],
      columns: columns,
      onPageChange: (oldPage, newPage) async {
        oldIndex = oldPage;
        newIndex = newPage;
        return true;
      },
    );
    expect(await remoteSource.handlePageChange(0, 2), isTrue);
    expect(oldIndex, 0);
    expect(newIndex, 2);
  });

  test('remote page failures are reported and reject navigation', () async {
    Object? capturedError;
    final remoteSource = NetSalesDataGridSource<_GridRecord>(
      items: const [_GridRecord(1, 'Alpha')],
      columns: columns,
      onPageChange: (oldPage, newPage) async => throw StateError('network'),
      onPageChangeFailure: (error) => capturedError = error,
    );
    expect(await remoteSource.handlePageChange(0, 1), isFalse);
    expect(capturedError, isA<StateError>());
  });

  test(
    'load-more requests are guarded against concurrent calls and exhaustion',
    () async {
      final completer = Completer<void>();
      var calls = 0;
      final loadMoreSource = NetSalesDataGridSource<_GridRecord>(
        items: const [_GridRecord(1, 'Alpha')],
        columns: columns,
        onLoadMore: () {
          calls++;
          return completer.future;
        },
      );

      final first = loadMoreSource.requestLoadMore();
      final second = loadMoreSource.requestLoadMore();
      expect(calls, 1);
      completer.complete();
      await Future.wait([first, second]);

      loadMoreSource.setHasMore(false);
      await loadMoreSource.requestLoadMore();
      expect(calls, 1);
    },
  );

  test('reorders visible columns while preserving row identity', () {
    final firstRow = source.rows.first;
    source.reorderVisibleColumns(0, 1);
    expect(source.columns.map((column) => column.name).toList(), [
      'name',
      'id',
    ]);
    expect(identical(source.rows.first, firstRow), isTrue);
    expect(source.itemForRow(firstRow)?.id, 1);
  });

  test('column visibility updates preserve row identity', () {
    final firstRow = source.rows.first;
    final updatedColumns = source.columns
        .map((column) => column.copyWith(visible: column.name != 'id'))
        .toList(growable: false);
    source.updateColumns(updatedColumns);
    expect(identical(source.rows.first, firstRow), isTrue);
    expect(source.itemForRow(firstRow)?.id, 1);
  });

  test(
    'editing a visually reordered row updates the matching source model',
    () async {
      final editableColumns = columns
          .map(
            (column) => column.name == 'name'
                ? column.copyWith(allowEditing: true)
                : column,
          )
          .toList(growable: false);
      final editSource = NetSalesDataGridSource<_GridRecord>(
        items: const [_GridRecord(1, 'Alpha'), _GridRecord(2, 'Beta')],
        columns: editableColumns,
        onEdit: (row, column, value) async =>
            _GridRecord(row.id, value as String),
      );
      final firstSourceRow = editSource.rows.first;
      editSource.rows.insert(0, editSource.rows.removeAt(1));
      final editColumn = GridColumn(
        columnName: 'name',
        label: const Text('Name'),
      );
      final editor =
          editSource.buildEditWidget(
                firstSourceRow,
                RowColumnIndex(1, 1),
                editColumn,
                () {},
              )
              as TextFormField;
      editor.onChanged?.call('Alpha updated');
      await editSource.onCellSubmit(
        firstSourceRow,
        RowColumnIndex(1, 1),
        editColumn,
      );
      expect(editSource.items[0].name, 'Alpha updated');
      expect(editSource.items[1].name, 'Beta');
      final updatedRow = editSource.rows.firstWhere(
        (row) => row.getCells().any(
          (cell) =>
              cell.columnName == 'name' && cell.value == 'Alpha updated',
        ),
      );
      expect(editSource.itemForRow(firstSourceRow), isNull);
      expect(editSource.itemForRow(updatedRow)?.id, 1);
    },
  );

  test('updates a column width without changing its semantic definition', () {
    source.updateColumnWidth('name', 260);

    expect(source.columns.last.width, 260);
    expect(source.columns.last.label, 'Name');
    source.reorderColumns(0, 1);
    expect(source.columns.map((column) => column.name).toList(), [
      'name',
      'id',
    ]);
  });
}
