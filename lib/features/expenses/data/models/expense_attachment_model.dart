import 'package:netsales/features/expenses/domain/entities/expense_attachment_entity.dart';

/// نموذج بيانات مرفق المصروف التشغيلي من الـ API
class ExpenseAttachmentModel extends ExpenseAttachmentEntity {
  const ExpenseAttachmentModel({
    required super.attachmentId,
    required super.expenseId,
    required super.attachmentName,
    required super.attachmentPath,
    required super.attachmentSize,
    required super.attachmentMime,
    required super.fileUrl,
    super.createdAt,
    super.updatedAt,
  });

  factory ExpenseAttachmentModel.fromJson(Map<String, dynamic> json) {
    return ExpenseAttachmentModel(
      attachmentId: json['attachment_id'] as int? ?? 0,
      expenseId: json['expense_id'] as int? ?? 0,
      attachmentName: json['attachment_name'] as String? ?? '',
      attachmentPath: json['attachment_path'] as String? ?? '',
      attachmentSize: json['attachment_size'] as int? ?? 0,
      attachmentMime: json['attachment_mime'] as String? ?? '',
      fileUrl: json['file_url'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
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
}
