import 'package:netsales/features/expenses/domain/entities/expense_attachment_entity.dart';

/// نموذج بيانات مرفق المصروف (ExpenseAttachmentModel)
///
/// يطابق تمثيل الـ JSON الصادر من `ExpenseAttachmentResource.php` في الخادم.
class ExpenseAttachmentModel extends ExpenseAttachmentEntity {
  const ExpenseAttachmentModel({
    required super.attachmentId,
    required super.expenseId,
    required super.attachmentName,
    required super.attachmentPath,
    super.attachmentSize = 0,
    super.attachmentMime = '',
    super.fileUrl,
    super.createdAt,
    super.updatedAt,
  });

  factory ExpenseAttachmentModel.fromJson(Map<String, dynamic> json) {
    return ExpenseAttachmentModel(
      attachmentId: json['attachment_id'] is int
          ? json['attachment_id'] as int
          : int.tryParse(json['attachment_id']?.toString() ?? '0') ?? 0,
      expenseId: json['expense_id'] is int
          ? json['expense_id'] as int
          : int.tryParse(json['expense_id']?.toString() ?? '0') ?? 0,
      attachmentName: json['attachment_name']?.toString() ?? '',
      attachmentPath: json['attachment_path']?.toString() ?? '',
      attachmentSize: json['attachment_size'] is int
          ? json['attachment_size'] as int
          : int.tryParse(json['attachment_size']?.toString() ?? '0') ?? 0,
      attachmentMime: json['attachment_mime']?.toString() ?? '',
      fileUrl: json['file_url']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'attachment_id': attachmentId,
    'expense_id': expenseId,
    'attachment_name': attachmentName,
    'attachment_path': attachmentPath,
    'attachment_size': attachmentSize,
    'attachment_mime': attachmentMime,
    'file_url': fileUrl,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };
}
