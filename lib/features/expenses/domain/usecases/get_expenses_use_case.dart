import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/expenses/domain/entities/expense_entity.dart';
import 'package:netsales/features/expenses/domain/repositories/expense_repository.dart';

class GetExpensesUseCase {
  final ExpenseRepository repository;

  const GetExpensesUseCase(this.repository);

  Future<PaginatedList<ExpenseEntity>> call({
    required int networkId,
    String? search,
    String? fromDate,
    String? toDate,
    String? cursor,
  }) {
    return repository.getExpenses(
      networkId: networkId,
      search: search,
      fromDate: fromDate,
      toDate: toDate,
      cursor: cursor,
    );
  }
}
