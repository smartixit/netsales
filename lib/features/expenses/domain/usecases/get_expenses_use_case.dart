import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/expenses/domain/entities/expense_entity.dart';
import 'package:netsales/features/expenses/domain/repositories/expense_repository.dart';

class GetExpensesUseCase {
  const GetExpensesUseCase(this.repository);

  final ExpenseRepository repository;

  Future<PaginatedList<ExpenseEntity>> call({
    required int networkId,
    String? search,
    String? fromDate,
    String? toDate,
    String? cursor,
    int perPage = 20,
  }) {
    return repository.getExpenses(
      networkId: networkId,
      search: search,
      fromDate: fromDate,
      toDate: toDate,
      cursor: cursor,
      perPage: perPage,
    );
  }
}
