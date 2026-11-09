import 'package:netsales/features/expenses/domain/entities/expense_entity.dart';

class ExpenseModel extends ExpenseEntity {
  const ExpenseModel({
    required super.expenseId,
    required super.networkId,
    required super.expenseUuid,
    required super.totalAmount,
    super.expenseDate,
    super.networkName,
    super.createdByName,
    super.items,
    super.attachments,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    final network = json['network'];
    final creator = json['created_by_user'];
    final rawItems = json['items'];
    final rawAttachments = json['attachments'];
    return ExpenseModel(
      expenseId: (json['expense_id'] as num?)?.toInt() ?? 0,
      networkId: (json['network_id'] as num?)?.toInt() ?? 0,
      expenseUuid: json['expense_uuid'] as String? ?? '',
      totalAmount: (json['expense_total_amount'] as num?)?.toDouble() ?? 0,
      expenseDate: json['expense_date'] as String?,
      networkName: network is Map<dynamic, dynamic>
          ? network['network_name'] as String?
          : null,
      createdByName: creator is Map<dynamic, dynamic>
          ? creator['name'] as String?
          : null,
      items: rawItems is List
          ? rawItems
                .whereType<Map<dynamic, dynamic>>()
                .map(
                  (item) => ExpenseItemEntity(
                    itemId: (item['item_id'] as num?)?.toInt() ?? 0,
                    statement: item['item_statement'] as String? ?? '',
                    amount: (item['item_amount'] as num?)?.toDouble() ?? 0,
                  ),
                )
                .toList(growable: false)
          : const [],
      attachments: rawAttachments is List
          ? rawAttachments
                .whereType<Map<dynamic, dynamic>>()
                .map(
                  (item) => ExpenseAttachmentEntity(
                    attachmentId: (item['attachment_id'] as num?)?.toInt() ?? 0,
                    name: item['attachment_name'] as String? ?? '',
                    mimeType: item['attachment_mime'] as String?,
                    sizeBytes: (item['attachment_size'] as num?)?.toInt() ?? 0,
                    fileUrl: item['file_url'] as String?,
                  ),
                )
                .toList(growable: false)
          : const [],
    );
  }
}
