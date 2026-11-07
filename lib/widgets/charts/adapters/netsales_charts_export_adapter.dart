import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:netsales/core/services/file_export_service.dart';
import 'package:netsales/widgets/charts/src/models/chart_series.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

/// NetSales integration for exporting reusable charts as PNG, PDF or CSV.
abstract final class NetSalesChartsExportAdapter {
  NetSalesChartsExportAdapter._();

  static Future<Uint8List?> capturePng(GlobalKey boundaryKey, {double pixelRatio = 3}) async {
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

  static Future<FileExportResult> savePng({required GlobalKey boundaryKey, required String title}) async {
    final bytes = await capturePng(boundaryKey);
    if (bytes == null || bytes.isEmpty) return FileExportResult.failure('تعذر التقاط صورة المخطط.');
    return FileExportService.instance.saveFile(
      bytes: bytes, fileName: title, extension: 'png', folderName: 'Charts',
      namingStrategy: FileNamingStrategy.report, autoOpen: false,
    );
  }

  static Future<FileExportResult> savePdf({required GlobalKey boundaryKey, required String title}) async {
    final bytes = await capturePng(boundaryKey);
    if (bytes == null || bytes.isEmpty) return FileExportResult.failure('تعذر التقاط المخطط لإنشاء PDF.');
    final document = pw.Document();
    document.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4.landscape,
      margin: const pw.EdgeInsets.all(28),
      build: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Text(title, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 16),
          pw.Expanded(child: pw.Center(child: pw.Image(pw.MemoryImage(bytes), fit: pw.BoxFit.contain))),
        ],
      ),
    ));
    return FileExportService.instance.saveFile(
      bytes: await document.save(), fileName: title, extension: 'pdf',
      folderName: 'Charts', namingStrategy: FileNamingStrategy.report, autoOpen: false,
    );
  }

  static Uint8List buildCsvBytes(List<ChartSeries> series) {
    final rows = <List<String>>[
      ['series_id','series_name','index','x','label','y','low','high','open','close','volume','size','samples'],
    ];
    for (final item in series) {
      for (var index = 0; index < item.dataSource.length; index++) {
        final point = item.dataSource[index];
        rows.add([
          item.id, item.name, index.toString(), _value(point.x), point.label ?? '',
          _value(point.y), _value(point.low), _value(point.high), _value(point.open),
          _value(point.close), _value(point.volume), _value(point.size),
          point.samples?.join(';') ?? '',
        ]);
      }
    }
    final csv = rows.map((row) => row.map(_escape).join(',')).join('\r\n');
    return Uint8List.fromList([0xEF, 0xBB, 0xBF, ...utf8.encode(csv + '\r\n')]);
  }

  static String _value(Object? value) {
    if (value == null) return '';
    if (value is DateTime) return value.toIso8601String();
    return value.toString();
  }

  static String _escape(String value) {
    if (!value.contains(RegExp(r'[",\r\n]'))) return value;
    return '"' + value.replaceAll('"', '""') + '"';
  }

  static Future<FileExportResult> saveCsv({required List<ChartSeries> series, required String title}) {
    return FileExportService.instance.saveFile(
      bytes: buildCsvBytes(series), fileName: title, extension: 'csv',
      folderName: 'Charts', namingStrategy: FileNamingStrategy.report, autoOpen: false,
    );
  }

  static Future<bool> sharePng({required GlobalKey boundaryKey, required String title}) async {
    final bytes = await capturePng(boundaryKey);
    if (bytes == null || bytes.isEmpty) return false;
    return _share(bytes, title + '.png', 'image/png');
  }

  static Future<bool> shareCsv({required List<ChartSeries> series, required String title}) =>
      _share(buildCsvBytes(series), title + '.csv', 'text/csv');

  static Future<bool> sharePdf({required GlobalKey boundaryKey, required String title}) async {
    final bytes = await capturePng(boundaryKey);
    if (bytes == null || bytes.isEmpty) return false;
    final document = pw.Document();
    document.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4.landscape,
      build: (_) => pw.Center(child: pw.Image(pw.MemoryImage(bytes), fit: pw.BoxFit.contain)),
    ));
    try {
      final result = await SharePlus.instance.share(ShareParams(
        files: [XFile.fromData(await document.save(), mimeType: 'application/pdf')],
        fileNameOverrides: [title + '.pdf'],
        downloadFallbackEnabled: true,
      ));
      return result.status == ShareResultStatus.success;
    } catch (_) { return false; }
  }

  static Future<bool> _share(Uint8List bytes, String fileName, String mimeType) async {
    try {
      final result = await SharePlus.instance.share(ShareParams(
        files: [XFile.fromData(bytes, mimeType: mimeType)],
        fileNameOverrides: [fileName],
        downloadFallbackEnabled: true,
      ));
      return result.status == ShareResultStatus.success;
    } catch (_) { return false; }
  }
}
