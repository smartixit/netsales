import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/expenses/data/models/expense_model.dart';
import 'package:netsales/features/expenses/data/models/expense_summary_model.dart';

/// العقد البرمجي لمصدر البيانات البعيد للمصروفات التشغيلية
abstract class ExpenseRemoteDataSource {
  /// جلب قائمة المصروفات التشغيلية
  Future<PaginatedList<ExpenseModel>> getExpenses({
    int? networkId,
    String? fromDate,
    String? toDate,
    String? search,
    String? cursor,
    int? perPage,
  });

  /// جلب تفاصيل مصروف محدد
  Future<ExpenseModel> getExpenseDetails(int expenseId);

  /// جلب ملخص وإحصائيات المصروفات
  Future<ExpenseSummaryModel> getExpenseSummary({
    int? networkId,
    String? fromDate,
    String? toDate,
  });

  /// إنشاء مصروف تشغيلي جديد
  Future<ExpenseModel> createExpense({
    required int networkId,
    String? expenseDate,
    required List<Map<String, dynamic>> items,
    List<String> attachmentPaths = const [],
  });

  /// تحديث مصروف قائم
  Future<ExpenseModel> updateExpense({
    required int expenseId,
    String? expenseDate,
    List<Map<String, dynamic>>? items,
    List<String> attachmentPaths = const [],
  });

  /// حذف ناعم للمصروف
  Future<void> deleteExpense(int expenseId);

  /// حذف مرفق من المصروف
  Future<void> deleteExpenseAttachment({
    required int expenseId,
    required int attachmentId,
  });
}
