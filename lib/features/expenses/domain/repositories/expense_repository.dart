import 'package:netsales/core/models/app_picked_file_model.dart';
import 'package:netsales/features/expenses/domain/entities/expense_entity.dart';
import 'package:netsales/features/expenses/domain/entities/expense_summary_entity.dart';
import 'package:netsales/features/expenses/domain/entities/new_expense_item_input_entity.dart';

/// واجهة مستودع بيانات المصروفات التشغيلية (ExpenseRepository)
///
/// تفصل طبقة الدومين تماماً عن آليات التخزين والاتصال الشبكي.
abstract class ExpenseRepository {
  /// استرجاع قائمة المصروفات مع الفلترة والترقيم بالمؤشر
  Future<List<ExpenseEntity>> getExpenses({
    int? networkId,
    String? fromDate,
    String? toDate,
    String? search,
    String? cursor,
    int? perPage,
  });

  /// استرجاع ملخص وإحصائيات المصروفات
  Future<ExpenseSummaryEntity> getExpenseSummary({
    int? networkId,
    String? fromDate,
    String? toDate,
  });

  /// عرض تفاصيل مصروف تشغيلي محدد
  Future<ExpenseEntity> getExpenseDetails(int expenseId);

  /// تسجيل مصروف تشغيلي جديد مع البنود والمرفقات وخصم إلزامي من محفظة الشبكة
  Future<ExpenseEntity> createExpense({
    required int networkId,
    DateTime? expenseDate,
    required List<NewExpenseItemInputEntity> items,
    List<AppPickedFileModel>? attachments,
    String? idempotencyKey,
  });

  /// تحديث بيانات مصروف تشغيلي مع تسوية فارق الرصيد في محفظة الشبكة
  Future<ExpenseEntity> updateExpense({
    required int expenseId,
    DateTime? expenseDate,
    List<NewExpenseItemInputEntity>? items,
    List<AppPickedFileModel>? attachments,
  });

  /// حذف مصروف تشغيلي ناعماً مع استرداد المبلغ لمحفظة الشبكة
  Future<void> deleteExpense(int expenseId);

  /// مؤشر الصفحة التالية من آخر عملية استعلام
  String? get nextCursor;
}
