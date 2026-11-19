import 'package:netsales/features/expenses/data/models/expense_attachment_model.dart';
import 'package:netsales/features/expenses/data/models/expense_item_model.dart';
import 'package:netsales/features/expenses/domain/entities/expense_entity.dart';

/// نموذج بيانات المصروف التشغيلي من الـ API
class ExpenseModel extends ExpenseEntity {
  const ExpenseModel({
    required super.expenseId,
    required super.networkId,
    required super.expenseUuid,
    required super.expenseTotalAmount,
    super.expenseDate,
    super.createdBy,
    super.networkName,
    super.creatorName,
    super.createdAt,
    super.updatedAt,
    super.items = const [],
    super.attachments = const [],
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    // شبكة المصروف إن وجدت
    final networkObj = json['network'] as Map<String, dynamic>?;
    final networkName = networkObj?['network_name'] as String?;

    // المستخدم الذي أنشأ المصروف إن وجد
    final creatorObj = json['created_by_user'] as Map<String, dynamic>?;
    final creatorName = creatorObj?['user_full_name'] as String?;

    // البنود
    final rawItems = json['items'] as List<dynamic>? ?? const [];
    final items = rawItems
        .map((e) => ExpenseItemModel.fromJson(e as Map<String, dynamic>))
        .toList();

    // المرفقات
    final rawAttachments = json['attachments'] as List<dynamic>? ?? const [];
    final attachments = rawAttachments
        .map((e) => ExpenseAttachmentModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return ExpenseModel(
      expenseId: json['expense_id'] as int? ?? 0,
      networkId: json['network_id'] as int? ?? 0,
      expenseUuid: json['expense_uuid'] as String? ?? '',
      expenseTotalAmount:
          (json['expense_total_amount'] as num?)?.toDouble() ?? 0.0,
      expenseDate: json['expense_date'] != null
          ? DateTime.tryParse(json['expense_date'].toString())
          : null,
      createdBy: json['created_by'] as int?,
      networkName: networkName,
      creatorName: creatorName,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      items: items,
      attachments: attachments,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'expense_id': expenseId,
      'network_id': networkId,
      'expense_uuid': expenseUuid,
      'expense_total_amount': expenseTotalAmount,
      'expense_date': expenseDate?.toIso8601String(),
      'created_by': createdBy,
      'network_name': networkName,
      'creator_name': creatorName,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'items': items
          .map((e) => (e is ExpenseItemModel ? e : ExpenseItemModel(
                itemId: e.itemId,
                expenseId: e.expenseId,
                itemStatement: e.itemStatement,
                itemAmount: e.itemAmount,
                createdAt: e.createdAt,
                updatedAt: e.updatedAt,
              )).toJson())
          .toList(),
      'attachments': attachments
          .map((e) => (e is ExpenseAttachmentModel ? e : ExpenseAttachmentModel(
                attachmentId: e.attachmentId,
                expenseId: e.expenseId,
                attachmentName: e.attachmentName,
                attachmentPath: e.attachmentPath,
                attachmentSize: e.attachmentSize,
                attachmentMime: e.attachmentMime,
                fileUrl: e.fileUrl,
                createdAt: e.createdAt,
                updatedAt: e.updatedAt,
              )).toJson())
          .toList(),
    };
  }
}
