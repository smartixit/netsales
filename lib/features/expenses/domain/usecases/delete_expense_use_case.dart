import 'package:netsales/features/expenses/domain/repositories/expense_repository.dart';

class DeleteExpenseUseCase {
  const DeleteExpenseUseCase(this.repository);

  final ExpenseRepository repository;

  Future<void> call(int expenseId) => repository.deleteExpense(expenseId);
}

