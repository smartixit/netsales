import 'package:netsales/features/more/domain/entities/expense_entity.dart';
import 'package:netsales/features/more/domain/repositories/more_repository.dart';

/// ============================================================================
/// حالة استخدام جلب قائمة المصروفات التشغيلية (GetExpensesUseCase)
/// ============================================================================
class GetExpensesUseCase {
  final MoreRepository _repository;

  const GetExpensesUseCase(this._repository);

  Future<List<ExpenseEntity>> call({int page = 1, int perPage = 20}) =>
      _repository.getExpenses(page: page, perPage: perPage);
}
