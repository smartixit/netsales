import 'dart:io';
import 'dart:typed_data';

import 'package:netsales/core/utils/file_size_formatter.dart';

/// كائن الدومين النقي للملفات والمرفقات المختارة في النظام (AppPickedFile)
///
/// كائن قيمة غير قابل للتعديل (Immutable Value Object) يمثل أي ملف أو صورة تم اختيارها
/// محلياً، مجرداً من أي حزم خارجية أو تبعيات واجهة المستخدم.
class AppPickedFile {
  final String id;
  final String path;
  final String name;
  final int sizeBytes;
  final String extension;
  final Uint8List? bytes;
  final String? mimeType;

  const AppPickedFile({
    required this.id,
    required this.path,
    required this.name,
    required this.sizeBytes,
    required this.extension,
    this.bytes,
    this.mimeType,
  });

  /// إنشاء كائن من ملف محلي قياسي (dart:io File)
  factory AppPickedFile.fromFile(File file) {
    final path = file.path;
    final name = path.split(Platform.pathSeparator).last;
    final dotIndex = name.lastIndexOf('.');
    final ext = dotIndex != -1 && dotIndex < name.length - 1
        ? name.substring(dotIndex + 1).toLowerCase()
        : '';
    final length = file.existsSync() ? file.lengthSync() : 0;
    final id = '${DateTime.now().microsecondsSinceEpoch}_$name';

    return AppPickedFile(
      id: id,
      path: path,
      name: name,
      sizeBytes: length,
      extension: ext,
    );
  }

  /// تحويل المسار إلى كائن File محلي
  File toFile() => File(path);

  /// حجم الملف بتنسيق مقروء للبشر (مثل: 1.4 MB أو 520 KB)
  String get sizeFormatted => FileSizeFormatter.format(sizeBytes);

  /// هل الملف صورة؟
  bool get isImage {
    const imageExtensions = {
      'jpg',
      'jpeg',
      'png',
      'webp',
      'gif',
      'bmp',
      'heic',
      'heif',
    };
    return imageExtensions.contains(extension.toLowerCase());
  }

  /// هل الملف مستند PDF؟
  bool get isPdf => extension.toLowerCase() == 'pdf';

  /// هل الملف جدول بيانات (Excel / CSV)؟
  bool get isSpreadsheet {
    const sheetExtensions = {'xls', 'xlsx', 'csv'};
    return sheetExtensions.contains(extension.toLowerCase());
  }

  /// هل الملف مستند Word نصي؟
  bool get isWord {
    const wordExtensions = {'doc', 'docx', 'rtf', 'odt'};
    return wordExtensions.contains(extension.toLowerCase());
  }

  /// هل الملف أرشيف مضغوط؟
  bool get isArchive {
    const archiveExtensions = {'zip', 'rar', '7z', 'tar', 'gz'};
    return archiveExtensions.contains(extension.toLowerCase());
  }

  /// هل الملف نص عادي أو برمجي؟
  bool get isText {
    const textExtensions = {'txt', 'json', 'xml', 'log', 'yaml', 'yml'};
    return textExtensions.contains(extension.toLowerCase());
  }

  AppPickedFile copyWith({
    String? id,
    String? path,
    String? name,
    int? sizeBytes,
    String? extension,
    Uint8List? bytes,
    String? mimeType,
  }) {
    return AppPickedFile(
      id: id ?? this.id,
      path: path ?? this.path,
      name: name ?? this.name,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      extension: extension ?? this.extension,
      bytes: bytes ?? this.bytes,
      mimeType: mimeType ?? this.mimeType,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppPickedFile &&
        other.id == id &&
        other.path == path &&
        other.sizeBytes == sizeBytes;
  }

  @override
  int get hashCode => Object.hash(id, path, sizeBytes);

  @override
  String toString() =>
      'AppPickedFile(id: $id, name: $name, size: $sizeFormatted, ext: $extension)';
}
