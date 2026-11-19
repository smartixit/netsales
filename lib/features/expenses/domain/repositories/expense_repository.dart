import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/expenses/domain/entities/expense_entity.dart';
import 'package:netsales/features/expenses/domain/entities/expense_summary_entity.dart';

/// العقد التجريدي لمستودع المصروفات التشغيلية
abstract class ExpenseRepository {
  /// جلب قائمة المصروفات التشغيلية مع الفلترة والترقيم بالمؤشر
  Future<PaginatedList<ExpenseEntity>> getExpenses({
    int? networkId,
    String? fromDate,
    String? toDate,
    String? search,
    String? cursor,
    int? perPage,
  });

  /// جلب تفاصيل مصروف تشغيلي محدد
  Future<ExpenseEntity> getExpenseDetails(int expenseId);

  /// جلب إحصائيات وملخص المصروفات التشغيلية
  Future<ExpenseSummaryEntity> getExpenseSummary({
    int? networkId,
    String? fromDate,
    String? toDate,
  });

  /// إنشاء مصروف تشغيلي جديد مع البنود والمرفقات والخصم السيادي من المحفظة
  Future<ExpenseEntity> createExpense({
    required int networkId,
    String? expenseDate,
    required List<Map<String, dynamic>> items,
    List<String> attachmentPaths = const [],
  });

  /// تحديث مصروف قائم مع تسوية فروق المبالغ بالمحفظة
  Future<ExpenseEntity> updateExpense({
    required int expenseId,
    String? expenseDate,
    List<Map<String, dynamic>>? items,
    List<String> attachmentPaths = const [],
  });

  /// حذف مصروف تشغيلي مع العكس المالي التلقائي
  Future<void> deleteExpense(int expenseId);

  /// حذف مرفق من المصروف
  Future<void> deleteExpenseAttachment({
    required int expenseId,
    required int attachmentId,
  });
}
