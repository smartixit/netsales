import 'package:netsales/features/expenses/domain/entities/expense_entity.dart';

class ExpenseModel extends ExpenseEntity {
  const ExpenseModel({
    required super.expenseId,
    required super.networkId,
    required super.expenseUuid,
    required super.totalAmount,
    super.expenseDate,
    super.networkName,
    super.items,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    final network = json['network'];
    final rawItems = json['items'];
    return ExpenseModel(
      expenseId: json['expense_id'] as int? ?? 0,
      networkId: json['network_id'] as int? ?? 0,
      expenseUuid: json['expense_uuid'] as String? ?? '',
      totalAmount: (json['expense_total_amount'] as num?)?.toDouble() ?? 0,
      expenseDate: json['expense_date'] as String?,
      networkName: network is Map<String, dynamic>
          ? network['network_name'] as String?
          : null,
      items: rawItems is List
          ? rawItems
              .whereType<Map<String, dynamic>>()
              .map((item) => ExpenseItemEntity(
                    itemId: item['item_id'] as int? ?? 0,
                    statement: item['item_statement'] as String? ?? '',
                    amount: (item['item_amount'] as num?)?.toDouble() ?? 0,
                  ))
              .toList(growable: false)
          : const [],
    );
  }
}
