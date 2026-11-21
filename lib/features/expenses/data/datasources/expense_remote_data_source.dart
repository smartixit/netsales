import 'package:netsales/core/models/app_picked_file_model.dart';
import 'package:netsales/features/expenses/data/models/expense_model.dart';
import 'package:netsales/features/expenses/data/models/expense_summary_model.dart';
import 'package:netsales/features/expenses/domain/entities/new_expense_item_input_entity.dart';

/// واجهة مصدر البيانات الشبكي للمصروفات (ExpenseRemoteDataSource)
abstract class ExpenseRemoteDataSource {
  /// جلب قائمة المصروفات مع الفلترة والترقيم بالمؤشر
  Future<List<ExpenseModel>> getExpenses({
    int? networkId,
    String? fromDate,
    String? toDate,
    String? search,
    String? cursor,
    int? perPage,
  });

  /// جلب ملخص وإحصائيات المصروفات
  Future<ExpenseSummaryModel> getExpenseSummary({
    int? networkId,
    String? fromDate,
    String? toDate,
  });

  /// جلب تفاصيل مصروف محدد مع بنوده ومرفقاته
  Future<ExpenseModel> getExpenseDetails(int expenseId);

  /// تسجيل مصروف تشغيلي جديد وخصم المبلغ من محفظة الشبكة
  Future<ExpenseModel> createExpense({
    required int networkId,
    DateTime? expenseDate,
    required List<NewExpenseItemInputEntity> items,
    List<AppPickedFileModel>? attachments,
    String? idempotencyKey,
  });

  /// تحديث بيانات مصروف تشغيلي مع تسوية فارق الرصيد في محفظة الشبكة وحذف المرفقات المحددة
  Future<ExpenseModel> updateExpense({
    required int expenseId,
    DateTime? expenseDate,
    List<NewExpenseItemInputEntity>? items,
    List<AppPickedFileModel>? attachments,
    List<int>? deletedAttachmentIds,
  });

  /// حذف مصروف تشغيلي ناعماً واسترداد مبلغه للمحفظة
  Future<void> deleteExpense(int expenseId);

  /// مؤشر الصفحة التالية
  String? get nextCursor;
}
