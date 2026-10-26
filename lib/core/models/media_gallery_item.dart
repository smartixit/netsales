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

  /// استخراج الامتداد الحقيقي والدقيق للملف من البيانات الوصفية أو الرابط أو التوقيع الثنائي (Magic Numbers)
  String get fileExtension {
    // 1. من الميتاداتا الصريحة عند إنشاء العنصر من AppPickedFile
    final metaExt = metadata?['extension'] as String?;
    if (metaExt != null && metaExt.trim().isNotEmpty) {
      final clean = metaExt.trim().toLowerCase();
      return clean.startsWith('.') ? clean.substring(1) : clean;
    }

    // 2. من مسار الرابط أو الملف
    final cleanUrl = url.split('?').first.trim();
    final dotIndex = cleanUrl.lastIndexOf('.');
    if (dotIndex != -1 && dotIndex < cleanUrl.length - 1) {
      final candidate = cleanUrl.substring(dotIndex + 1).toLowerCase();
      if (candidate.length <= 5 && !candidate.contains('/')) {
        return candidate;
      }
    }

    // 3. من اسم الملف أو العنوان إذا كان يحمل امتداداً
    final cleanTitle = title.split('?').first.trim();
    final titleDotIndex = cleanTitle.lastIndexOf('.');
    if (titleDotIndex != -1 && titleDotIndex < cleanTitle.length - 1) {
      final candidate = cleanTitle.substring(titleDotIndex + 1).toLowerCase();
      if (candidate.length <= 5 && !candidate.contains('/')) {
        return candidate;
      }
    }

    // 4. فحص التوقيع الثنائي للملف (File Signatures / Magic Numbers)
    if (bytes != null && bytes!.length >= 4) {
      // PDF: %PDF (0x25, 0x50, 0x44, 0x46)
      if (bytes![0] == 0x25 && bytes![1] == 0x50 && bytes![2] == 0x44 && bytes![3] == 0x46) {
        return 'pdf';
      }
      // PNG: 0x89, 0x50, 0x4E, 0x47
      if (bytes![0] == 0x89 && bytes![1] == 0x50 && bytes![2] == 0x4E && bytes![3] == 0x47) {
        return 'png';
      }
      // JPEG: 0xFF, 0xD8, 0xFF
      if (bytes![0] == 0xFF && bytes![1] == 0xD8 && bytes![2] == 0xFF) {
        return 'jpg';
      }
      // GIF: GIF8 (0x47, 0x49, 0x46, 0x38)
      if (bytes![0] == 0x47 && bytes![1] == 0x49 && bytes![2] == 0x46 && bytes![3] == 0x38) {
        return 'gif';
      }
      // WebP: RIFF...WEBP
      if (bytes!.length >= 12 &&
          bytes![0] == 0x52 && bytes![1] == 0x49 && bytes![2] == 0x46 && bytes![3] == 0x46 &&
          bytes![8] == 0x57 && bytes![9] == 0x45 && bytes![10] == 0x42 && bytes![11] == 0x50) {
        return 'webp';
      }
      // Office XML / ZIP (xlsx, docx): PK (0x50, 0x4B)
      if (bytes![0] == 0x50 && bytes![1] == 0x4B) {
        if (isSpreadsheet) return 'xlsx';
        return 'zip';
      }
    }

    // 5. البديل الآمن المتوافق مع نوع المعرض
    if (isPdf) return 'pdf';
    if (isSpreadsheet) return 'xlsx';
    if (isImage) return 'jpg';

    return 'bin';
  }
}
