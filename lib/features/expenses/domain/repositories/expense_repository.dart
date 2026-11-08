import 'package:netsales/core/models/app_picked_file_model.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/expenses/domain/entities/expense_entity.dart';

abstract interface class ExpenseRepository {
  Future<PaginatedList<ExpenseEntity>> getExpenses({
    required int networkId,
    String? search,
    String? fromDate,
    String? toDate,
    String? cursor,
    int perPage = 20,
  });

  Future<ExpenseEntity> getExpense(int expenseId);

  Future<ExpenseEntity> createExpense({
    required int networkId,
    required String expenseDate,
    required List<Map<String, dynamic>> items,
    required List<AppPickedFileModel> attachments,
  });

  Future<ExpenseEntity> updateExpense({
    required int expenseId,
    required String expenseDate,
    required List<Map<String, dynamic>> items,
    required List<AppPickedFileModel> attachments,
  });

  Future<void> deleteAttachment({
    required int expenseId,
    required int attachmentId,
  });
}
