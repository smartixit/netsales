import 'package:netsales/core/utils/date_formatter.dart';

/// كائن الدومين النقي لمرفق المصروف (ExpenseAttachmentEntity)
///
/// يمثل ملفاً ثبوتياً مرفقاً بسند الصرف التشغيلي (فاتورة، إيصال، عقد).
class ExpenseAttachmentEntity {
  const ExpenseAttachmentEntity({
    required this.attachmentId,
    required this.expenseId,
    required this.attachmentName,
    required this.attachmentPath,
    this.attachmentSize = 0,
    this.attachmentMime = '',
    this.fileUrl,
    this.createdAt,
    this.updatedAt,
  });

  /// المعرف الرقمي للمرفق
  final int attachmentId;

  /// معرف المصروف التابع له
  final int expenseId;

  /// اسم الملف الأصلي
  final String attachmentName;

  /// مسار التخزين الداخلي في الخادم
  final String attachmentPath;

  /// حجم الملف بالبايت
  final int attachmentSize;

  /// نوع الـ MIME للملف
  final String attachmentMime;

  /// رابط التحميل أو العرض المباشر المؤقت
  final String? fileUrl;

  /// تاريخ الرفع
  final DateTime? createdAt;

  /// تاريخ التعديل
  final DateTime? updatedAt;

  /// هل الملف صورة
  bool get isImage {
    final mime = attachmentMime.toLowerCase();
    final name = attachmentName.toLowerCase();
    return mime.startsWith('image/') ||
        name.endsWith('.png') ||
        name.endsWith('.jpg') ||
        name.endsWith('.jpeg') ||
        name.endsWith('.webp');
  }

  /// هل الملف مستند PDF
  bool get isPdf {
    final mime = attachmentMime.toLowerCase();
    final name = attachmentName.toLowerCase();
    return mime.contains('pdf') || name.endsWith('.pdf');
  }

  /// تنسيق حجم الملف للعرض البشري (KB / MB)
  String get formattedSize {
    if (attachmentSize <= 0) return '';
    if (attachmentSize < 1024) return '$attachmentSize B';
    if (attachmentSize < 1024 * 1024) {
      return '${(attachmentSize / 1024).toStringAsFixed(1)} KB';
    }
    return '${(attachmentSize / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  /// تاريخ الرفع المنسق
  String get formattedCreatedAt {
    return createdAt != null ? DateFormatter.dateTime(createdAt!) : '';
  }
}
