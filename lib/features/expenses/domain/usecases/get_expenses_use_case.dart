import 'package:netsales/features/expenses/domain/entities/expense_entity.dart';
import 'package:netsales/features/expenses/domain/repositories/expense_repository.dart';

/// حالة استخدام جلب قائمة المصروفات التشغيلية (GetExpensesUseCase)
class GetExpensesUseCase {
  const GetExpensesUseCase(this._repository);

  final ExpenseRepository _repository;

  Future<List<ExpenseEntity>> call({
    int? networkId,
    String? fromDate,
    String? toDate,
    String? search,
    String? cursor,
    int? perPage,
  }) {
    return _repository.getExpenses(
      networkId: networkId,
      fromDate: fromDate,
      toDate: toDate,
      search: search,
      cursor: cursor,
      perPage: perPage,
    );
  }

  String? get nextCursor => _repository.nextCursor;
}
