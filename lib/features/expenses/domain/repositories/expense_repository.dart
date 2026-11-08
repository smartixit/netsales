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
}
