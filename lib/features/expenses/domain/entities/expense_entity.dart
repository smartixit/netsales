import 'package:netsales/core/utils/date_formatter.dart';
import 'package:netsales/features/expenses/domain/entities/expense_attachment_entity.dart';
import 'package:netsales/features/expenses/domain/entities/expense_item_entity.dart';

/// كائن الدومين النقي للمصروف التشغيلي (ExpenseEntity)
///
/// يمثل سند الصرف التشغيلي المخصوم من محفظة الشبكة في netsales_api.
class ExpenseEntity {
  const ExpenseEntity({
    required this.expenseId,
    required this.expenseUuid,
    required this.networkId,
    required this.expenseTotalAmount,
    this.expenseDate,
    this.createdById,
    this.createdByName,
    this.createdAt,
    this.updatedAt,
    this.networkName,
    this.networkLogo,
    this.networkPhoneNumber,
    this.items = const [],
    this.attachments = const [],
  });

  /// المعرف الرقمي الأساسي للمصروف
  final int expenseId;

  /// المعرف الفريد التجاري (UUID) المنشأ في الواجهة الخلفية
  final String expenseUuid;

  /// معرف الشبكة التابع لها المصروف
  final int networkId;

  /// المبلغ الإجمالي للمصروف
  final double expenseTotalAmount;

  /// تاريخ استحقاق / صرف المصروف
  final DateTime? expenseDate;

  /// معرف المستخدم الذي قام بتسجيل المصروف
  final int? createdById;

  /// اسم المستخدم الذي قام بتسجيل المصروف
  final String? createdByName;

  /// تاريخ ووقت التسجيل في النظام
  final DateTime? createdAt;

  /// تاريخ ووقت آخر تعديل
  final DateTime? updatedAt;

  /// اسم الشبكة التابعة
  final String? networkName;

  /// شعار الشبكة
  final String? networkLogo;

  /// هاتف الشبكة
  final String? networkPhoneNumber;

  /// بنود المصروف التفصيلية
  final List<ExpenseItemEntity> items;

  /// المرفقات والمستندات
  final List<ExpenseAttachmentEntity> attachments;

  /// المعرف المعروض المعتمد
  String get displayReference =>
      expenseUuid.isNotEmpty ? expenseUuid : '#$expenseId';

  /// التاريخ المنسق للعرض
  String get formattedExpenseDate {
    final d = expenseDate ?? createdAt;
    return d != null ? DateFormatter.date(d) : 'التاريخ غير متاح';
  }

  /// التاريخ والوقت المنسق للعرض
  String get formattedCreatedAt {
    final d = createdAt ?? expenseDate;
    return d != null ? DateFormatter.dateTime(d) : 'التاريخ غير متاح';
  }

  /// عدد البنود المسجلة
  int get itemsCount => items.length;

  /// عدد المرفقات المرفقة
  int get attachmentsCount => attachments.length;

  /// هل يتضمن المصروف مرفقات
  bool get hasAttachments => attachments.isNotEmpty;
}
