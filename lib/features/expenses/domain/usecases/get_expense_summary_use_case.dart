import 'package:netsales/features/expenses/domain/entities/expense_summary_entity.dart';
import 'package:netsales/features/expenses/domain/repositories/expense_repository.dart';

/// حالة استخدام جلب ملخص وإحصائيات المصروفات (GetExpenseSummaryUseCase)
class GetExpenseSummaryUseCase {
  const GetExpenseSummaryUseCase(this._repository);

  final ExpenseRepository _repository;

  Future<ExpenseSummaryEntity> call({
    int? networkId,
    String? fromDate,
    String? toDate,
  }) {
    return _repository.getExpenseSummary(
      networkId: networkId,
      fromDate: fromDate,
      toDate: toDate,
    );
  }
}
