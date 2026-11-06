
import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/widgets/data_grid/adapters/net_sales_data_grid_source.dart';
import 'package:netsales/widgets/data_grid/models/app_data_grid_column.dart';

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
    expect(source.rows.first.getCells().map((cell) => cell.value).toList(), [1, 'Alpha']);
  });

  test('replaces source records and rebuilds grid rows', () {
    source.replaceRows(const [_GridRecord(3, 'Gamma')]);

    expect(source.rows, hasLength(1));
    expect(source.itemForRow(source.rows.single)?.name, 'Gamma');
  });

  test('reorders columns while preserving each row cell mapping', () {
    source.reorderColumns(0, 1);

    expect(source.columns.map((column) => column.name).toList(), ['name', 'id']);
    expect(source.rows.first.getCells().map((cell) => cell.columnName).toList(), ['name', 'id']);
    expect(source.rows.first.getCells().map((cell) => cell.value).toList(), ['Alpha', 1]);
  });

  test('updates a column width without changing its semantic definition', () {
    source.updateColumnWidth('name', 260);

    expect(source.columns.last.width, 260);
    expect(source.columns.last.label, 'Name');
  });
}
