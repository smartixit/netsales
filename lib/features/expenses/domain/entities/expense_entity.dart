import 'package:equatable/equatable.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/core/utils/date_formatter.dart';
import 'package:netsales/features/expenses/domain/entities/expense_attachment_entity.dart';
import 'package:netsales/features/expenses/domain/entities/expense_item_entity.dart';

/// كيان المصروف التشغيلي الرئيسي (Operating Expense Entity)
class ExpenseEntity extends Equatable {
  const ExpenseEntity({
    required this.expenseId,
    required this.networkId,
    required this.expenseUuid,
    required this.expenseTotalAmount,
    this.expenseDate,
    this.createdBy,
    this.networkName,
    this.creatorName,
    this.createdAt,
    this.updatedAt,
    this.items = const [],
    this.attachments = const [],
  });

  final int expenseId;
  final int networkId;
  final String expenseUuid;
  final double expenseTotalAmount;
  final DateTime? expenseDate;
  final int? createdBy;
  final String? networkName;
  final String? creatorName;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<ExpenseItemEntity> items;
  final List<ExpenseAttachmentEntity> attachments;

  /// مرجع المصروف الأصلي للعرض والنسخ (UUID المعتمد من الخادم أو المعرف الرقمي)
  String get displayReference {
    if (expenseUuid.trim().isNotEmpty) {
      return expenseUuid;
    }
    return '#$expenseId';
  }

  /// تاريخ المصروف المنسق للعرض
  String get formattedExpenseDate {
    if (expenseDate != null) {
      return DateFormatter.date(expenseDate!);
    }
    if (createdAt != null) {
      return DateFormatter.date(createdAt!);
    }
    return '-';
  }

  /// اسم الشبكة المعروض
  String get displayNetworkName {
    if (networkName != null && networkName!.trim().isNotEmpty) {
      return networkName!;
    }
    return 'شبكة #$networkId';
  }

  /// اسم المسؤول عن الصرف
  String get displayCreatorName {
    if (creatorName != null && creatorName!.trim().isNotEmpty) {
      return creatorName!;
    }
    return 'مسؤول الشبكة';
  }

  /// إجمالي المصروف منسقاً
  String get formattedTotalAmount =>
      AmountFormatter.format(expenseTotalAmount.toString());

  int get itemsCount => items.length;
  int get attachmentsCount => attachments.length;

  @override
  List<Object?> get props => [
        expenseId,
        networkId,
        expenseUuid,
        expenseTotalAmount,
        expenseDate,
        createdBy,
        networkName,
        creatorName,
        createdAt,
        updatedAt,
        items,
        attachments,
      ];
}
