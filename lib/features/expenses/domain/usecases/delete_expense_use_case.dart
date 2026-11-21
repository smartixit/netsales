import 'package:netsales/features/expenses/domain/repositories/expense_repository.dart';

/// حالة استخدام حذف مصروف تشغيلي ناعماً واسترداد مبلغه للمحفظة (DeleteExpenseUseCase)
class DeleteExpenseUseCase {
  const DeleteExpenseUseCase(this._repository);

  final ExpenseRepository _repository;

  Future<void> call(int expenseId) {
    return _repository.deleteExpense(expenseId);
  }
}
