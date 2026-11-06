
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:netsales/core/services/file_export_service.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_datagrid_export/export.dart';

/// Exports rows currently loaded into the widget. Full server result exports belong in Laravel.
class AppDataGridExportController {
  final GlobalKey<SfDataGridState> gridKey = GlobalKey<SfDataGridState>();

  Future<FileExportResult> exportExcel({
    String fileName = 'DataGrid',
    List<DataGridRow>? rows,
    List<String> excludeColumns = const [],
    bool exportTableSummaries = true,
    bool exportStackedHeaders = true,
  }) async {
    final state = gridKey.currentState;
    if (state == null) return FileExportResult.failure('DataGrid is not mounted.');
    try {
      final workbook = state.exportToExcelWorkbook(
        rows: rows,
        excludeColumns: excludeColumns,
        exportTableSummaries: exportTableSummaries,
        exportStackedHeaders: exportStackedHeaders,
      );
      final bytes = workbook.saveAsStream();
      workbook.dispose();
      return FileExportService.instance.saveFile(
        bytes: Uint8List.fromList(bytes),
        fileName: fileName,
        extension: 'xlsx',
        namingStrategy: FileNamingStrategy.report,
        autoOpen: true,
      );
    } catch (error) {
      return FileExportResult.failure('Excel export failed: $error');
    }
  }

  Future<FileExportResult> exportPdf({
    String fileName = 'DataGrid',
    List<DataGridRow>? rows,
    List<String> excludeColumns = const [],
    bool exportTableSummaries = true,
    bool exportStackedHeaders = true,
    bool fitAllColumnsInOnePage = false,
    bool canRepeatHeaders = true,
  }) async {
    final state = gridKey.currentState;
    if (state == null) return FileExportResult.failure('DataGrid is not mounted.');
    try {
      final document = state.exportToPdfDocument(
        rows: rows,
        excludeColumns: excludeColumns,
        exportTableSummaries: exportTableSummaries,
        exportStackedHeaders: exportStackedHeaders,
        fitAllColumnsInOnePage: fitAllColumnsInOnePage,
        canRepeatHeaders: canRepeatHeaders,
      );
      final bytes = await document.save();
      document.dispose();
      return FileExportService.instance.saveFile(
        bytes: Uint8List.fromList(bytes),
        fileName: fileName,
        extension: 'pdf',
        namingStrategy: FileNamingStrategy.report,
        autoOpen: true,
      );
    } catch (error) {
      return FileExportResult.failure('PDF export failed: $error');
    }
  }
}
