import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:document_engine/document_engine.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:netsales/core/services/document_engine_font_service.dart';
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
      final pdfBytes = await _buildChartPdfBytes(bytes, title);
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

  static Future<Uint8List> _buildChartPdfBytes(
    Uint8List chartPng,
    String title,
  ) async {
    final normalizedChartPng = await _normalizePdfChartImage(chartPng);
    final safeTitle = title.trim().isEmpty ? 'Chart export' : title.trim();
    final generatedAt = DateTime.now();
    final renderer = PdfDocumentRenderer(
      textShapingProvider:
          await DocumentEngineFontService.instance.arabicTextShapingProvider(),
    );
    final snapshot = DocumentSnapshot(
      metadata: DocumentMetadata(
        id: DocumentId('netsales-chart-${generatedAt.microsecondsSinceEpoch}'),
        documentTypeId: DocumentTypeId('netsales.chart-export'),
        title: safeTitle,
        locale: DocumentLocale(
          languageTag: 'ar-YE',
          direction: DocumentTextDirection.auto,
        ),
        createdAt: generatedAt,
      ),
      sections: [
        DocumentSection(
          id: 'chart-visual',
          nodes: [
            DocumentImage(
              bytes: normalizedChartPng,
              widthPoints: 780,
              heightPoints: 460,
              fit: DocumentImageFit.contain,
              alignment: DocumentImageAlignment.center,
            ),
          ],
        ),
      ],
    );
    final template = DocumentTemplateDefinition(
      id: TemplateId('netsales.chart-export.landscape'),
      version: TemplateVersion(major: 1, minor: 0, patch: 0),
      documentTypeId: DocumentTypeId('netsales.chart-export'),
      displayName: 'NetSales Landscape Chart Export',
      supportedLocaleTags: const ['ar', 'en'],
      capabilities: TemplateCapabilities([
        TemplateCapability.images,
        TemplateCapability.landscapePage,
      ]),
      isDefault: true,
      layout: DocumentTemplateLayout.standard,
    );
    final result = await renderer.render(
      snapshot: snapshot,
      template: template,
      options: DocumentRenderOptions(
        pageProfile: DocumentPageProfile.a4Landscape(
          marginTop: 28,
          marginRight: 28,
          marginBottom: 28,
          marginLeft: 28,
        ),
        generatedAt: generatedAt,
        showPageNumbers: false,
        maxPages: 1,
      ),
    );
    if (result is DocumentRenderSuccess) return result.artifact.bytes;
    if (result is DocumentRenderFailure) throw StateError(result.message);
    throw StateError('تعذر إنشاء ملف PDF للمخطط.');
  }

  static Future<Uint8List> _normalizePdfChartImage(
    Uint8List sourceBytes,
  ) async {
    const maxImageBytes = 4 * 1024 * 1024;
    if (sourceBytes.length <= maxImageBytes) {
      return Uint8List.fromList(sourceBytes);
    }

    final sourceCodec = await ui.instantiateImageCodec(sourceBytes);
    int sourceWidth;
    int sourceHeight;
    try {
      final frame = await sourceCodec.getNextFrame();
      sourceWidth = frame.image.width;
      sourceHeight = frame.image.height;
      frame.image.dispose();
    } finally {
      sourceCodec.dispose();
    }

    for (final maxWidth in [1600, 1200, 900]) {
      const maxHeight = 1000;
      final scale = [
        1.0,
        maxWidth / sourceWidth,
        maxHeight / sourceHeight,
      ].reduce((a, b) => a < b ? a : b);
      final targetWidth = (sourceWidth * scale).round().clamp(1, maxWidth).toInt();
      final targetHeight = (sourceHeight * scale).round().clamp(1, maxHeight).toInt();
      final codec = await ui.instantiateImageCodec(
        sourceBytes,
        targetWidth: targetWidth,
        targetHeight: targetHeight,
      );
      try {
        final frame = await codec.getNextFrame();
        try {
          final data = await frame.image.toByteData(
            format: ui.ImageByteFormat.png,
          );
          if (data == null) continue;
          final resized = data.buffer.asUint8List(
            data.offsetInBytes,
            data.lengthInBytes,
          );
          if (resized.length <= maxImageBytes) {
            return Uint8List.fromList(resized);
          }
        } finally {
          frame.image.dispose();
        }
      } finally {
        codec.dispose();
      }
    }

    throw StateError(
      'حجم صورة المخطط ما زال يتجاوز الحد المسموح به بعد التصغير.',
    );
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
      final pdfBytes = await _buildChartPdfBytes(bytes, title);
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
