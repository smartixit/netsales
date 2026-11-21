import 'package:netsales/features/expenses/domain/entities/expense_entity.dart';
import 'package:netsales/features/expenses/domain/repositories/expense_repository.dart';

/// حالة استخدام جلب تفاصيل مصروف تشغيلي محدد (GetExpenseDetailsUseCase)
class GetExpenseDetailsUseCase {
  const GetExpenseDetailsUseCase(this._repository);

  final ExpenseRepository _repository;

  Future<ExpenseEntity> call(int expenseId) {
    return _repository.getExpenseDetails(expenseId);
  }
}
