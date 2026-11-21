import 'package:netsales/core/models/app_picked_file_model.dart';
import 'package:netsales/features/expenses/data/datasources/expense_remote_data_source.dart';
import 'package:netsales/features/expenses/domain/entities/expense_entity.dart';
import 'package:netsales/features/expenses/domain/entities/expense_summary_entity.dart';
import 'package:netsales/features/expenses/domain/entities/new_expense_item_input_entity.dart';
import 'package:netsales/features/expenses/domain/repositories/expense_repository.dart';

/// تطبيق مستودع المصروفات التشغيلية (ExpenseRepositoryImpl)
class ExpenseRepositoryImpl implements ExpenseRepository {
  const ExpenseRepositoryImpl({required this.remoteDataSource});

  final ExpenseRemoteDataSource remoteDataSource;

  @override
  String? get nextCursor => remoteDataSource.nextCursor;

  @override
  Future<List<ExpenseEntity>> getExpenses({
    int? networkId,
    String? fromDate,
    String? toDate,
    String? search,
    String? cursor,
    int? perPage,
  }) {
    return remoteDataSource.getExpenses(
      networkId: networkId,
      fromDate: fromDate,
      toDate: toDate,
      search: search,
      cursor: cursor,
      perPage: perPage,
    );
  }

  @override
  Future<ExpenseSummaryEntity> getExpenseSummary({
    int? networkId,
    String? fromDate,
    String? toDate,
  }) {
    return remoteDataSource.getExpenseSummary(
      networkId: networkId,
      fromDate: fromDate,
      toDate: toDate,
    );
  }

  @override
  Future<ExpenseEntity> getExpenseDetails(int expenseId) {
    return remoteDataSource.getExpenseDetails(expenseId);
  }

  @override
  Future<ExpenseEntity> createExpense({
    required int networkId,
    DateTime? expenseDate,
    required List<NewExpenseItemInputEntity> items,
    List<AppPickedFileModel>? attachments,
    String? idempotencyKey,
  }) {
    return remoteDataSource.createExpense(
      networkId: networkId,
      expenseDate: expenseDate,
      items: items,
      attachments: attachments,
      idempotencyKey: idempotencyKey,
    );
  }

  @override
  Future<ExpenseEntity> updateExpense({
    required int expenseId,
    DateTime? expenseDate,
    List<NewExpenseItemInputEntity>? items,
    List<AppPickedFileModel>? attachments,
    List<int>? deletedAttachmentIds,
  }) {
    return remoteDataSource.updateExpense(
      expenseId: expenseId,
      expenseDate: expenseDate,
      items: items,
      attachments: attachments,
      deletedAttachmentIds: deletedAttachmentIds,
    );
  }

  @override
  Future<void> deleteExpense(int expenseId) {
    return remoteDataSource.deleteExpense(expenseId);
  }
}
