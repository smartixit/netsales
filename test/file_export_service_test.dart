import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/services/file_export_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FileExportService service;
  late Directory testDir;

  setUpAll(() async {
    service = FileExportService.instance;
    testDir = await service.getAppExportDirectory(folderName: 'NetSalesTest');
  });

  tearDownAll(() async {
    if (testDir.existsSync()) {
      try {
        testDir.deleteSync(recursive: true);
      } catch (_) {}
    }
  });

  group('FileNamingStrategy and ISO-8601 Timestamp Tests', () {
    test('formatIsoCompact formats DateTime accurately into YYYYMMDD_HHmmss', () {
      final dt = DateTime(2026, 10, 21, 9, 5, 7);
      expect(FileExportService.formatIsoCompact(dt), equals('20261021_090507'));
    });

    test('resolveCategory correctly maps extensions to enterprise categories', () {
      expect(FileExportService.resolveCategory('pdf'), equals('DOC'));
      expect(FileExportService.resolveCategory('png'), equals('IMG'));
      expect(FileExportService.resolveCategory('jpg'), equals('IMG'));
      expect(FileExportService.resolveCategory('xlsx'), equals('SHEET'));
      expect(FileExportService.resolveCategory('csv'), equals('SHEET'));
      expect(FileExportService.resolveCategory('unknown'), equals('FILE'));
    });

    test('buildFileNameWithoutExtension generates enterprise standard name', () {
      final dt = DateTime(2026, 10, 21, 18, 5, 30);
      final name = service.buildFileNameWithoutExtension(
        rawTitle: 'فاتورة بيع كروت #1049.pdf',
        extension: 'pdf',
        strategy: FileNamingStrategy.enterprise,
        timestamp: dt,
      );

      expect(name, equals('NetSales_فاتورة-بيع-كروت-1049_20261021_180530'));
    });

    test('buildFileNameWithoutExtension with categorized strategy inserts category', () {
      final dt = DateTime(2026, 10, 21, 18, 5, 30);
      final name = service.buildFileNameWithoutExtension(
        rawTitle: 'network_logo',
        extension: 'png',
        strategy: FileNamingStrategy.categorized,
        timestamp: dt,
      );

      expect(name, equals('NetSales_IMG_network-logo_20261021_180530'));
    });

    test('custom FileNamingStrategy is completely reusable for other projects', () {
      final dt = DateTime(2026, 10, 21, 18, 5, 30);
      const customStrategy = FileNamingStrategy(
        appPrefix: 'SmartixERP',
        separator: '__',
        spaceReplacement: '_',
      );

      final name = service.buildFileNameWithoutExtension(
        rawTitle: 'Financial Statement Q3',
        extension: 'xlsx',
        strategy: customStrategy,
        timestamp: dt,
      );

      expect(name, equals('SmartixERP__Financial_Statement_Q3__20261021_180530'));
    });
  });

  group('FileExportService FileName Sanitization Tests', () {
    test('sanitizeFileName removes illegal filesystem characters and replaces with hyphens', () {
      const dirty = 'report:2026/10*final?"test"|<file>';
      final clean = service.sanitizeFileName(dirty);

      expect(clean.contains(':'), isFalse);
      expect(clean.contains('/'), isFalse);
      expect(clean.contains('*'), isFalse);
      expect(clean.contains('?'), isFalse);
      expect(clean.contains('"'), isFalse);
      expect(clean.contains('|'), isFalse);
      expect(clean.contains('<'), isFalse);
      expect(clean.contains('>'), isFalse);
    });

    test('sanitizeFileName strips existing extension to prevent duplicate extension', () {
      const name = 'invoice_123.pdf';
      final clean = service.sanitizeFileName(name, extensionToRemove: 'pdf');
      expect(clean, equals('invoice-123'));
    });

    test('sanitizeFileName defaults to fallback name if string becomes empty', () {
      const empty = '   / : * ?   ';
      final clean = service.sanitizeFileName(empty);
      expect(clean, isNotEmpty);
      expect(clean, equals('ملف'));
    });
  });

  group('FileExportService Extension Resolution Tests', () {
    test('resolveExtension respects explicit extension with or without dot', () {
      expect(FileExportService.resolveExtension(fileName: 'any', explicitExtension: 'pdf'), equals('pdf'));
      expect(FileExportService.resolveExtension(fileName: 'any', explicitExtension: '.PNG'), equals('png'));
      expect(FileExportService.resolveExtension(fileName: 'any', explicitExtension: 'xlsx'), equals('xlsx'));
    });

    test('resolveExtension extracts extension from fileName', () {
      expect(FileExportService.resolveExtension(fileName: 'statement.csv'), equals('csv'));
      expect(FileExportService.resolveExtension(fileName: 'image.JPEG'), equals('jpeg'));
      expect(FileExportService.resolveExtension(fileName: 'no_ext'), equals('bin'));
    });
  });

  group('FileExportService File Saving and Collision Resolution Tests', () {
    test('saveFile writes bytes to disk and prevents name collisions', () async {
      final sampleBytes = Uint8List.fromList([1, 2, 3, 4, 5, 6]);
      final dt = DateTime(2026, 10, 21, 18, 5, 30);

      // 1. الحفظ الأول
      final result1 = await service.saveFile(
        bytes: sampleBytes,
        fileName: 'voucher_batch',
        extension: 'pdf',
        folderName: 'NetSalesTest',
        timestamp: dt,
        autoOpen: false,
        showFeedback: false,
      );

      expect(result1.isSuccess, isTrue);
      expect(result1.bytesWritten, equals(6));
      expect(result1.fileName, equals('NetSales_voucher-batch_20261021_180530.pdf'));
      expect(File(result1.filePath!).existsSync(), isTrue);

      // 2. الحفظ الثاني بنفس الاسم والتوقيت - يجب تفادي التصادم عبر ترقيم الملف (1)
      final result2 = await service.saveFile(
        bytes: sampleBytes,
        fileName: 'voucher_batch',
        extension: 'pdf',
        folderName: 'NetSalesTest',
        timestamp: dt,
        autoOpen: false,
        showFeedback: false,
      );

      expect(result2.isSuccess, isTrue);
      expect(result2.fileName, equals('NetSales_voucher-batch_20261021_180530 (1).pdf'));
      expect(File(result2.filePath!).existsSync(), isTrue);

      // 3. الحفظ الثالث - ترقيم الملف (2)
      final result3 = await service.saveFile(
        bytes: sampleBytes,
        fileName: 'voucher_batch',
        extension: 'pdf',
        folderName: 'NetSalesTest',
        timestamp: dt,
        autoOpen: false,
        showFeedback: false,
      );

      expect(result3.isSuccess, isTrue);
      expect(result3.fileName, equals('NetSales_voucher-batch_20261021_180530 (2).pdf'));
      expect(File(result3.filePath!).existsSync(), isTrue);
    });

    test('saveFile rejects empty bytes cleanly', () async {
      final result = await service.saveFile(
        bytes: Uint8List(0),
        fileName: 'empty',
        folderName: 'NetSalesTest',
        autoOpen: false,
        showFeedback: false,
      );

      expect(result.isSuccess, isFalse);
      expect(result.bytesWritten, equals(0));
    });
  });
}
