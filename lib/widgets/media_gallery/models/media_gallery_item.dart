import 'dart:typed_data';

import 'package:netsales/core/models/app_picked_file.dart';

/// أنواع الوسائط والمستندات المدعومة داخل معرض NetSales
enum MediaGalleryType {
  image,
  pdf,
  spreadsheet,
  document,
}

/// كائن الدومين النقي للوسائط والمستندات المعروضة في المعرض التفاعلي (MediaGalleryItem)
class MediaGalleryItem {
  final String url;
  final String title;
  final String? subtitle;
  final String? heroTag;
  final MediaGalleryType? type;
  final Uint8List? bytes;
  final Map<String, dynamic>? metadata;

  const MediaGalleryItem({
    required this.url,
    required this.title,
    this.subtitle,
    this.heroTag,
    this.type,
    this.bytes,
    this.metadata,
  });

  /// إنشاء عنصر معرض مباشرة من كائن المرفقات المعتمد [AppPickedFile]
  factory MediaGalleryItem.fromPickedFile(AppPickedFile file) {
    MediaGalleryType resolved;
    if (file.isPdf) {
      resolved = MediaGalleryType.pdf;
    } else if (file.isSpreadsheet) {
      resolved = MediaGalleryType.spreadsheet;
    } else if (file.isImage) {
      resolved = MediaGalleryType.image;
    } else {
      resolved = MediaGalleryType.document;
    }

    return MediaGalleryItem(
      url: file.path,
      title: file.name,
      subtitle: file.sizeFormatted,
      heroTag: 'picked_file_${file.id}',
      type: resolved,
      bytes: file.bytes,
      metadata: {
        'id': file.id,
        'sizeBytes': file.sizeBytes,
        'extension': file.extension,
        'mimeType': file.mimeType,
      },
    );
  }

  /// تحديد نوع الوسائط بدقة بناءً على النوع الصريح أو امتداد الرابط
  MediaGalleryType get resolvedType {
    if (type != null) return type!;
    final cleanUrl = url.toLowerCase().split('?').first.trim();

    if (cleanUrl.endsWith('.pdf')) {
      return MediaGalleryType.pdf;
    }
    if (cleanUrl.endsWith('.xlsx') ||
        cleanUrl.endsWith('.xls') ||
        cleanUrl.endsWith('.csv')) {
      return MediaGalleryType.spreadsheet;
    }
    if (cleanUrl.endsWith('.jpg') ||
        cleanUrl.endsWith('.jpeg') ||
        cleanUrl.endsWith('.png') ||
        cleanUrl.endsWith('.webp') ||
        cleanUrl.endsWith('.gif') ||
        cleanUrl.endsWith('.bmp') ||
        cleanUrl.endsWith('.svg')) {
      return MediaGalleryType.image;
    }

    return MediaGalleryType.document;
  }

  bool get isImage => resolvedType == MediaGalleryType.image;
  bool get isPdf => resolvedType == MediaGalleryType.pdf;
  bool get isSpreadsheet => resolvedType == MediaGalleryType.spreadsheet;
  bool get isLocalFile =>
      !url.startsWith('http://') && !url.startsWith('https://');
}
