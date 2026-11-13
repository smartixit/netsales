import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:document_engine/document_engine.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:netsales/core/services/document_engine_image_pdf_service.dart';
import 'package:netsales/core/services/file_export_service.dart';
import 'package:netsales/widgets/charts/src/models/chart_series.dart';
import 'package:share_plus/share_plus.dart';

/// NetSales integration for exporting reusable charts as PNG, PDF or CSV.
abstract final class NetSalesChartsExportAdapter {
  NetSalesChartsExportAdapter._();

  static Future<Uint8List?> capturePng(
    GlobalKey boundaryKey, {
    double pixelRatio = 3,
  }) async {
    await WidgetsBinding.instance.endOfFrame;
    final renderObject = boundaryKey.currentContext?.findRenderObject();
    if (renderObject is! RenderRepaintBoundary) return null;
    final image = await renderObject.toImage(pixelRatio: pixelRatio);
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) return null;
      return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    } finally {
      image.dispose();
    }
  }

  static Future<FileExportResult> savePng({
    required GlobalKey boundaryKey,
    required String title,
  }) async {
    final bytes = await capturePng(boundaryKey);
    if (bytes == null || bytes.isEmpty) {
      return FileExportResult.failure('تعذر التقاط صورة المخطط.');
    }
    return FileExportService.instance.saveFile(
      bytes: bytes,
      fileName: title,
      extension: 'png',
      folderName: 'Charts',
      namingStrategy: FileNamingStrategy.report,
      autoOpen: false,
    );
  }

  static Future<FileExportResult> savePdf({
    required GlobalKey boundaryKey,
    required String title,
  }) async {
    final bytes = await capturePng(boundaryKey);
    if (bytes == null || bytes.isEmpty) {
      return FileExportResult.failure('تعذر التقاط المخطط لإنشاء PDF.');
    }
    try {
      final pdfBytes = await DocumentEngineImagePdfService.instance
          .renderA4Image(
            imageBytes: bytes,
            title: title,
            orientation: DocumentPageOrientation.landscape,
          );
      return FileExportService.instance.saveFile(
        bytes: pdfBytes,
        fileName: title,
        extension: 'pdf',
        folderName: 'Charts',
        namingStrategy: FileNamingStrategy.report,
        autoOpen: false,
      );
    } catch (error) {
      return FileExportResult.failure(
        'تعذر إنشاء ملف PDF للمخطط: $error',
      );
    }
  }

  static Uint8List buildCsvBytes(List<ChartSeries> series) {
    final rows = <List<String>>[
      [
        'series_id',
        'series_name',
        'index',
        'x',
        'label',
        'y',
        'low',
        'high',
        'open',
        'close',
        'volume',
        'size',
        'samples',
        'is_intermediate_sum',
        'is_total_sum',
      ],
    ];
    for (final item in series) {
      for (var index = 0; index < item.dataSource.length; index++) {
        final point = item.dataSource[index];
        rows.add([
          item.id,
          item.name,
          index.toString(),
          _value(point.x),
          point.label ?? '',
          _value(point.y),
          _value(point.low),
          _value(point.high),
          _value(point.open),
          _value(point.close),
          _value(point.volume),
          _value(point.size),
          point.samples?.join(';') ?? '',
          point.isIntermediateSum.toString(),
          point.isTotalSum.toString(),
        ]);
      }
    }
    final csv = rows.map((row) => row.map(_escape).join(',')).join('\r\n');
    return Uint8List.fromList([0xEF, 0xBB, 0xBF, ...utf8.encode('$csv\r\n')]);
  }

  static String _value(Object? value) {
    if (value == null) return '';
    if (value is DateTime) return value.toIso8601String();
    return value.toString();
  }

  static String _escape(String value) {
    if (!value.contains(RegExp(r'[",\r\n]'))) return value;
    return '"${value.replaceAll('"', '""')}"';
  }

  static Future<FileExportResult> saveCsv({
    required List<ChartSeries> series,
    required String title,
  }) {
    return FileExportService.instance.saveFile(
      bytes: buildCsvBytes(series),
      fileName: title,
      extension: 'csv',
      folderName: 'Charts',
      namingStrategy: FileNamingStrategy.report,
      autoOpen: false,
    );
  }

  static Future<bool> sharePng({
    required GlobalKey boundaryKey,
    required String title,
  }) async {
    final bytes = await capturePng(boundaryKey);
    if (bytes == null || bytes.isEmpty) return false;
    return _share(bytes, '$title.png', 'image/png');
  }

  static Future<bool> shareCsv({
    required List<ChartSeries> series,
    required String title,
  }) => _share(buildCsvBytes(series), '$title.csv', 'text/csv');

  static Future<bool> sharePdf({
    required GlobalKey boundaryKey,
    required String title,
  }) async {
    final bytes = await capturePng(boundaryKey);
    if (bytes == null || bytes.isEmpty) return false;
    try {
      final pdfBytes = await DocumentEngineImagePdfService.instance
          .renderA4Image(
            imageBytes: bytes,
            title: title,
            orientation: DocumentPageOrientation.landscape,
          );
      final result = await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(pdfBytes, mimeType: 'application/pdf'),
          ],
          fileNameOverrides: ['$title.pdf'],
          downloadFallbackEnabled: true,
        ),
      );
      return result.status == ShareResultStatus.success;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> _share(
    Uint8List bytes,
    String fileName,
    String mimeType,
  ) async {
    try {
      final result = await SharePlus.instance.share(
        ShareParams(
          files: [XFile.fromData(bytes, mimeType: mimeType)],
          fileNameOverrides: [fileName],
          downloadFallbackEnabled: true,
        ),
      );
      return result.status == ShareResultStatus.success;
    } catch (_) {
      return false;
    }
  }
}
