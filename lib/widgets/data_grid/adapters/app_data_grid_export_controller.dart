import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:netsales/core/services/file_export_service.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_datagrid_export/export.dart';

/// Exports rows currently loaded into the widget. Full server result exports belong in Laravel.
class AppDataGridExportController {
  AppDataGridExportController({IFileExportService? fileExportService})
      : _fileExportService = fileExportService ?? FileExportService.instance;

  final IFileExportService _fileExportService;
  final GlobalKey<SfDataGridState> gridKey = GlobalKey<SfDataGridState>();

  Future<FileExportResult> exportExcel({
    String fileName = 'DataGrid',
    List<DataGridRow>? rows,
    List<String> excludeColumns = const [],
    bool exportTableSummaries = true,
    bool exportStackedHeaders = true,
  }) async {
    final state = gridKey.currentState;
    if (state == null) {
      return FileExportResult.failure('DataGrid is not mounted.');
    }

    try {
      final workbook = state.exportToExcelWorkbook(
        rows: rows,
        excludeColumns: excludeColumns,
        exportTableSummaries: exportTableSummaries,
        exportStackedHeaders: exportStackedHeaders,
      );

      try {
        final bytes = Uint8List.fromList(workbook.saveAsStream());
        return await _fileExportService.saveFile(
          bytes: bytes,
          fileName: fileName,
          extension: 'xlsx',
          namingStrategy: FileNamingStrategy.report,
          autoOpen: true,
        );
      } finally {
        workbook.dispose();
      }
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
    if (state == null) {
      return FileExportResult.failure('DataGrid is not mounted.');
    }

    try {
      final document = state.exportToPdfDocument(
        rows: rows,
        excludeColumns: excludeColumns,
        exportTableSummaries: exportTableSummaries,
        exportStackedHeaders: exportStackedHeaders,
        fitAllColumnsInOnePage: fitAllColumnsInOnePage,
        canRepeatHeaders: canRepeatHeaders,
      );

      try {
        final bytes = Uint8List.fromList(await document.save());
        return await _fileExportService.saveFile(
          bytes: bytes,
          fileName: fileName,
          extension: 'pdf',
          namingStrategy: FileNamingStrategy.report,
          autoOpen: true,
        );
      } finally {
        document.dispose();
      }
    } catch (error) {
      return FileExportResult.failure('PDF export failed: $error');
    }
  }
}
