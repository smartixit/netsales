import 'package:netsales/features/expenses/data/models/expense_attachment_model.dart';
import 'package:netsales/features/expenses/data/models/expense_item_model.dart';
import 'package:netsales/features/expenses/domain/entities/expense_entity.dart';

/// نموذج بيانات المصروف التشغيلي (ExpenseModel)
///
/// يطابق تمثيل الـ JSON الصادر من `ExpenseResource.php` في الخادم.
class ExpenseModel extends ExpenseEntity {
  const ExpenseModel({
    required super.expenseId,
    required super.expenseUuid,
    required super.networkId,
    required super.expenseTotalAmount,
    super.expenseDate,
    super.createdById,
    super.createdByName,
    super.createdAt,
    super.updatedAt,
    super.networkName,
    super.networkLogo,
    super.networkPhoneNumber,
    super.items = const [],
    super.attachments = const [],
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final itemsList = rawItems is List
        ? rawItems
              .whereType<Map<String, dynamic>>()
              .map(ExpenseItemModel.fromJson)
              .toList()
        : <ExpenseItemModel>[];

    final rawAttachments = json['attachments'];
    final attachmentsList = rawAttachments is List
        ? rawAttachments
              .whereType<Map<String, dynamic>>()
              .map(ExpenseAttachmentModel.fromJson)
              .toList()
        : <ExpenseAttachmentModel>[];

    // استخراج اسم وبيانات الشبكة والمستخدم المنشئ إن توفرت في العلاقات المحملة
    final network = json['network'] is Map<String, dynamic>
        ? json['network'] as Map<String, dynamic>
        : null;
    final createdByUser = json['created_by_user'] is Map<String, dynamic>
        ? json['created_by_user'] as Map<String, dynamic>
        : null;

    final networkName =
        network?['name']?.toString() ?? network?['network_name']?.toString();
    final networkLogo =
        network?['logo_url']?.toString() ?? network?['logo']?.toString();
    final networkPhoneNumber =
        network?['phone']?.toString() ?? network?['phone_number']?.toString();

    final createdByName =
        createdByUser?['full_name']?.toString() ??
        createdByUser?['name']?.toString();

    return ExpenseModel(
      expenseId: json['expense_id'] is int
          ? json['expense_id'] as int
          : int.tryParse(json['expense_id']?.toString() ?? '0') ?? 0,
      expenseUuid: json['expense_uuid']?.toString() ?? '',
      networkId: json['network_id'] is int
          ? json['network_id'] as int
          : int.tryParse(json['network_id']?.toString() ?? '0') ?? 0,
      expenseTotalAmount: json['expense_total_amount'] is num
          ? (json['expense_total_amount'] as num).toDouble()
          : double.tryParse(json['expense_total_amount']?.toString() ?? '0') ??
                0.0,
      expenseDate: json['expense_date'] != null
          ? DateTime.tryParse(json['expense_date'].toString())
          : null,
      createdById: json['created_by'] is int
          ? json['created_by'] as int
          : int.tryParse(json['created_by']?.toString() ?? '0'),
      createdByName: createdByName,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      networkName: networkName,
      networkLogo: networkLogo,
      networkPhoneNumber: networkPhoneNumber,
      items: itemsList,
      attachments: attachmentsList,
    );
  }

  Map<String, dynamic> toJson() => {
    'expense_id': expenseId,
    'expense_uuid': expenseUuid,
    'network_id': networkId,
    'expense_total_amount': expenseTotalAmount,
    'expense_date': expenseDate?.toIso8601String(),
    'created_by': createdById,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
    'items': items
        .map(
          (e) => e is ExpenseItemModel
              ? e.toJson()
              : {
                  'item_id': e.itemId,
                  'expense_id': e.expenseId,
                  'item_statement': e.itemStatement,
                  'item_amount': e.itemAmount,
                },
        )
        .toList(),
    'attachments': attachments
        .map(
          (e) => e is ExpenseAttachmentModel
              ? e.toJson()
              : {
                  'attachment_id': e.attachmentId,
                  'expense_id': e.expenseId,
                  'attachment_name': e.attachmentName,
                  'attachment_path': e.attachmentPath,
                },
        )
        .toList(),
  };
}
