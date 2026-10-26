import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/cache/netsales_cache_manager.dart';
import 'package:netsales/core/constants/api_constants.dart';
import 'package:netsales/core/models/app_picked_file.dart';
import 'package:netsales/core/services/app_cache_service.dart';
import 'package:netsales/core/models/media_gallery_item.dart';

void main() {
  group('NetSalesDioFileService URL Normalization & MIME Tests', () {
    test('normalizeMediaUrl handles relative paths correctly', () {
      const relativePath = 'networks/logos/logo_123.png';
      final normalized = NetSalesDioFileService.normalizeMediaUrl(relativePath);
      expect(normalized, '${ApiConstants.baseUrl}/files/networks/logos/logo_123.png');
    });

    test('normalizeMediaUrl handles /files/ prefixed paths correctly', () {
      const pathWithFiles = '/files/pos/logos/pos_99.png';
      final normalized = NetSalesDioFileService.normalizeMediaUrl(pathWithFiles);
      expect(normalized, '${ApiConstants.baseUrl}/files/pos/logos/pos_99.png');
    });

    test('normalizeMediaUrl leaves fully qualified http/https URLs intact', () {
      const fullUrl = 'https://example.com/cdn/image.webp?token=xyz123';
      final normalized = NetSalesDioFileService.normalizeMediaUrl(fullUrl);
      expect(normalized, fullUrl);
    });

    test('extractExtension resolves from path or MIME type accurately', () {
      expect(NetSalesDioFileService.extractExtension('doc.pdf', null), '.pdf');
      expect(NetSalesDioFileService.extractExtension('sheet.xlsx', null), '.xlsx');
      expect(NetSalesDioFileService.extractExtension('file_without_ext', 'application/pdf'), '.pdf');
      expect(
        NetSalesDioFileService.extractExtension(
          'data',
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        ),
        '.xlsx',
      );
      expect(NetSalesDioFileService.extractExtension('data', 'text/csv'), '.csv');
      expect(NetSalesDioFileService.extractExtension('photo', 'image/jpeg'), '.jpg');
    });
  });

  group('AppCacheService In-Memory TTL & Tagged Invalidation Tests', () {
    final cache = AppCacheService.instance;

    setUp(() {
      cache.clearDataCache();
    });

    test('set and get cached data before TTL expires', () {
      cache.set('key1', {'balance': 15000}, ttl: const Duration(minutes: 5));
      expect(cache.has('key1'), isTrue);

      final data = cache.get<Map<String, dynamic>>('key1');
      expect(data, isNotNull);
      expect(data!['balance'], 15000);
    });

    test('expired cache entry returns null automatically', () {
      cache.set(
        'expired_key',
        'sensitive_token',
        ttl: const Duration(milliseconds: -10), // expired in past
      );

      expect(cache.has('expired_key'), isFalse);
      expect(cache.get<String>('expired_key'), isNull);
    });

    test('invalidateByTag evicts matching tagged items in bulk', () {
      cache.set('pkg_1', 'package_one', tags: ['packages']);
      cache.set('pkg_2', 'package_two', tags: ['packages']);
      cache.set('net_1', 'network_profile', tags: ['networks']);

      expect(cache.has('pkg_1'), isTrue);
      expect(cache.has('pkg_2'), isTrue);
      expect(cache.has('net_1'), isTrue);

      // إبطال وسم باقات الشبكة فقط
      cache.invalidateByTag('packages');

      expect(cache.has('pkg_1'), isFalse);
      expect(cache.has('pkg_2'), isFalse);
      expect(cache.has('net_1'), isTrue); // يبقى سليماً دون مساس
    });
  });

  group('MediaGalleryItem Clean Architecture & Type Resolution Tests', () {
    test('resolves image URLs accurately', () {
      const item = MediaGalleryItem(
        url: 'http://server.com/api/v1/files/networks/logos/test.png',
        title: 'شعار الشبكة',
      );

      expect(item.resolvedType, MediaGalleryType.image);
      expect(item.isImage, isTrue);
      expect(item.isPdf, isFalse);
      expect(item.isLocalFile, isFalse);
    });

    test('resolves PDF documents accurately', () {
      const item = MediaGalleryItem(
        url: 'http://server.com/api/v1/files/signed/expenses/receipt.pdf?signature=123',
        title: 'فاتورة الصيانة',
      );

      expect(item.resolvedType, MediaGalleryType.pdf);
      expect(item.isPdf, isTrue);
      expect(item.isImage, isFalse);
      expect(item.isLocalFile, isFalse);
    });

    test('resolves Excel spreadsheets accurately', () {
      const item = MediaGalleryItem(
        url: 'http://server.com/api/v1/files/signed/reports/sales.xlsx',
        title: 'تقرير المبيعات',
      );

      expect(item.resolvedType, MediaGalleryType.spreadsheet);
      expect(item.isSpreadsheet, isTrue);
      expect(item.isImage, isFalse);
    });

    test('detects local file path correctly', () {
      const localItem = MediaGalleryItem(
        url: '/data/user/0/com.smartix.netsales/cache/invoice.pdf',
        title: 'فاتورة محلية',
      );

      expect(localItem.isLocalFile, isTrue);
    });

    test('converts AppPickedFile into MediaGalleryItem seamlessly', () {
      final pickedPdf = AppPickedFile(
        id: 'file_001',
        path: '/storage/emulated/0/Download/report.pdf',
        name: 'report.pdf',
        sizeBytes: 1024 * 500,
        extension: 'pdf',
        bytes: Uint8List(10),
      );

      final galleryItem = MediaGalleryItem.fromPickedFile(pickedPdf);
      expect(galleryItem.title, 'report.pdf');
      expect(galleryItem.isPdf, isTrue);
      expect(galleryItem.isLocalFile, isTrue);
      expect(galleryItem.bytes, isNotNull);
    });
  });
}
