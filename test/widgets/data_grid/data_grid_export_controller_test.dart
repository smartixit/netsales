import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/services/file_export_service.dart';
import 'package:netsales/widgets/data_grid/adapters/app_data_grid_export_controller.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class _MemoryExportService implements IFileExportService {
  Uint8List? savedBytes;
  String? savedExtension;
  bool shouldFail = false;

  @override
  Future<FileExportResult> saveFile({
    required Uint8List bytes,
    required String fileName,
    String? extension,
    String folderName = 'NetSales',
    FileNamingStrategy namingStrategy = FileNamingStrategy.enterprise,
    DateTime? timestamp,
    bool autoOpen = true,
    bool showFeedback = true,
  }) async {
    if (shouldFail) throw StateError('storage unavailable');
    savedBytes = bytes;
    savedExtension = extension;
    return FileExportResult.success(
      filePath: '/memory/$fileName.$extension',
      fileName: '$fileName.$extension',
      bytesWritten: bytes.length,
    );
  }

  @override
  Future<bool> shareBytes({
    required Uint8List bytes,
    required String fileName,
    String? extension,
    FileNamingStrategy namingStrategy = FileNamingStrategy.enterprise,
    DateTime? timestamp,
  }) async => true;

  @override
  Future<Directory> getAppExportDirectory({
    String folderName = 'NetSales',
  }) async => Directory.systemTemp;

  @override
  String sanitizeFileName(
    String fileName, {
    String? extensionToRemove,
    String spaceReplacement = '-',
    int maxLength = 45,
  }) => fileName;
}

class _TestGridSource extends DataGridSource {
  _TestGridSource() {
    _rows = [
      DataGridRow(
        cells: [
          DataGridCell<int>(columnName: 'id', value: 1),
          DataGridCell<String>(columnName: 'name', value: 'Alpha'),
        ],
      ),
      DataGridRow(
        cells: [
          DataGridCell<int>(columnName: 'id', value: 2),
          DataGridCell<String>(columnName: 'name', value: 'Beta'),
        ],
      ),
    ];
  }

  late final List<DataGridRow> _rows;

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) => DataGridRowAdapter(
    cells: row.getCells().map((cell) => Text(cell.value.toString())).toList(),
  );
}

void main() {
  late _MemoryExportService fileService;
  late AppDataGridExportController controller;
  late _TestGridSource gridSource;

  Future<void> mountGrid(WidgetTester tester) async {
    gridSource = _TestGridSource();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SfDataGrid(
            key: controller.gridKey,
            source: gridSource,
            columns: [
              GridColumn(columnName: 'id', label: const Text('ID')),
              GridColumn(columnName: 'name', label: const Text('Name')),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  setUp(() {
    fileService = _MemoryExportService();
    controller = AppDataGridExportController(fileExportService: fileService);
  });

  test('returns a failure when the grid is not mounted', () async {
    final result = await controller.exportExcel();
    expect(result.isSuccess, isFalse);
    expect(result.errorMessage, contains('not mounted'));
  });

  testWidgets('exports a valid XLSX workbook through FileExportService', (
    tester,
  ) async {
    await mountGrid(tester);

    final result = await controller.exportExcel(fileName: 'grid-test');

    expect(result.isSuccess, isTrue);
    expect(fileService.savedExtension, 'xlsx');
    expect(fileService.savedBytes, isNotNull);
    expect(fileService.savedBytes!.length, greaterThan(4));
    expect(fileService.savedBytes!.take(2).toList(), [0x50, 0x4b]);
  });

  testWidgets('exports a valid PDF document through FileExportService', (
    tester,
  ) async {
    await mountGrid(tester);

    final result = await controller.exportPdf(fileName: 'grid-test');

    expect(result.isSuccess, isTrue);
    expect(fileService.savedExtension, 'pdf');
    expect(fileService.savedBytes, isNotNull);
    expect(fileService.savedBytes!.length, greaterThan(8));
    expect(String.fromCharCodes(fileService.savedBytes!.take(5)), '%PDF-');
  });

  testWidgets('exports only the selected rows when rows are supplied', (
    tester,
  ) async {
    await mountGrid(tester);
    final selectedRows = gridSource.rows.take(1).toList();

    final result = await controller.exportExcel(
      fileName: 'selected-grid',
      rows: selectedRows,
    );

    expect(result.isSuccess, isTrue);
    expect(fileService.savedBytes, isNotNull);
    expect(fileService.savedBytes!.take(2).toList(), [0x50, 0x4b]);
  });

  testWidgets('converts storage failures into a failed export result', (
    tester,
  ) async {
    await mountGrid(tester);
    fileService.shouldFail = true;

    final result = await controller.exportExcel();

    expect(result.isSuccess, isFalse);
    expect(result.errorMessage, contains('storage unavailable'));
  });
}
