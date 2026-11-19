import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/expenses/data/datasources/expense_remote_data_source.dart';
import 'package:netsales/features/expenses/domain/entities/expense_entity.dart';
import 'package:netsales/features/expenses/domain/entities/expense_summary_entity.dart';
import 'package:netsales/features/expenses/domain/repositories/expense_repository.dart';

/// تطبيق مستودع المصروفات التشغيلية
class ExpenseRepositoryImpl implements ExpenseRepository {
  const ExpenseRepositoryImpl(this._remoteDataSource);

  final ExpenseRemoteDataSource _remoteDataSource;

  @override
  Future<PaginatedList<ExpenseEntity>> getExpenses({
    int? networkId,
    String? fromDate,
    String? toDate,
    String? search,
    String? cursor,
    int? perPage,
  }) {
    return _remoteDataSource.getExpenses(
      networkId: networkId,
      fromDate: fromDate,
      toDate: toDate,
      search: search,
      cursor: cursor,
      perPage: perPage,
    );
  }

  @override
  Future<ExpenseEntity> getExpenseDetails(int expenseId) {
    return _remoteDataSource.getExpenseDetails(expenseId);
  }

  @override
  Future<ExpenseSummaryEntity> getExpenseSummary({
    int? networkId,
    String? fromDate,
    String? toDate,
  }) {
    return _remoteDataSource.getExpenseSummary(
      networkId: networkId,
      fromDate: fromDate,
      toDate: toDate,
    );
  }

  @override
  Future<ExpenseEntity> createExpense({
    required int networkId,
    String? expenseDate,
    required List<Map<String, dynamic>> items,
    List<String> attachmentPaths = const [],
  }) {
    return _remoteDataSource.createExpense(
      networkId: networkId,
      expenseDate: expenseDate,
      items: items,
      attachmentPaths: attachmentPaths,
    );
  }

  @override
  Future<ExpenseEntity> updateExpense({
    required int expenseId,
    String? expenseDate,
    List<Map<String, dynamic>>? items,
    List<String> attachmentPaths = const [],
  }) {
    return _remoteDataSource.updateExpense(
      expenseId: expenseId,
      expenseDate: expenseDate,
      items: items,
      attachmentPaths: attachmentPaths,
    );
  }

  @override
  Future<void> deleteExpense(int expenseId) {
    return _remoteDataSource.deleteExpense(expenseId);
  }

  @override
  Future<void> deleteExpenseAttachment({
    required int expenseId,
    required int attachmentId,
  }) {
    return _remoteDataSource.deleteExpenseAttachment(
      expenseId: expenseId,
      attachmentId: attachmentId,
    );
  }
}
