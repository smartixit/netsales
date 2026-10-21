import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/models/app_picked_file.dart';
import 'package:netsales/core/services/file_picker_service.dart';

void main() {
  group('AppPickedFile Domain Entity Tests', () {
    test('sizeFormatted formats bytes accurately into B, KB, MB, and GB', () {
      const zeroFile = AppPickedFile(
        id: '1',
        path: '/tmp/test.txt',
        name: 'test.txt',
        sizeBytes: 0,
        extension: 'txt',
      );
      expect(zeroFile.sizeFormatted, '0 B');

      const byteFile = AppPickedFile(
        id: '2',
        path: '/tmp/test.txt',
        name: 'test.txt',
        sizeBytes: 512,
        extension: 'txt',
      );
      expect(byteFile.sizeFormatted, '512 B');

      const kbFile = AppPickedFile(
        id: '3',
        path: '/tmp/test.txt',
        name: 'test.txt',
        sizeBytes: 450 * 1024,
        extension: 'txt',
      );
      expect(kbFile.sizeFormatted, '450 KB');

      const mbFile = AppPickedFile(
        id: '4',
        path: '/tmp/document.pdf',
        name: 'document.pdf',
        sizeBytes: 2621440,
        extension: 'pdf',
      );
      expect(mbFile.sizeFormatted, '2.50 MB');
    });

    test('file extension helpers identify types cleanly', () {
      const pdf = AppPickedFile(
        id: '1',
        path: '/tmp/invoice.pdf',
        name: 'invoice.pdf',
        sizeBytes: 1000,
        extension: 'pdf',
      );
      expect(pdf.isPdf, isTrue);
      expect(pdf.isImage, isFalse);

      const excel = AppPickedFile(
        id: '2',
        path: '/tmp/cards.xlsx',
        name: 'cards.xlsx',
        sizeBytes: 2000,
        extension: 'xlsx',
      );
      expect(excel.isSpreadsheet, isTrue);
      expect(excel.isPdf, isFalse);

      const img = AppPickedFile(
        id: '3',
        path: '/tmp/logo.png',
        name: 'logo.png',
        sizeBytes: 3000,
        extension: 'png',
      );
      expect(img.isImage, isTrue);
    });
  });

  group('FilePickerService Singleton and Constants Tests', () {
    test('singleton instance is ready and provides valid defaults', () {
      final service = FilePickerService.instance;
      expect(service, isNotNull);
      expect(FilePickerService.defaultMaxFileSize, 2 * 1024 * 1024);
    });
  });
}
