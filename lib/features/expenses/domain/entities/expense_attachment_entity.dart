import 'package:equatable/equatable.dart';

/// كيان مرفق المصروف التشغيلي (Expense Attachment Entity)
class ExpenseAttachmentEntity extends Equatable {
  const ExpenseAttachmentEntity({
    required this.attachmentId,
    required this.expenseId,
    required this.attachmentName,
    required this.attachmentPath,
    required this.attachmentSize,
    required this.attachmentMime,
    required this.fileUrl,
    this.createdAt,
    this.updatedAt,
  });

  final int attachmentId;
  final int expenseId;
  final String attachmentName;
  final String attachmentPath;
  final int attachmentSize;
  final String attachmentMime;
  final String fileUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [
        attachmentId,
        expenseId,
        attachmentName,
        attachmentPath,
        attachmentSize,
        attachmentMime,
        fileUrl,
        createdAt,
        updatedAt,
      ];
}
