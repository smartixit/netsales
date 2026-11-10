import 'package:netsales/features/expenses/domain/entities/expense_entity.dart';
import 'package:netsales/features/expenses/domain/repositories/expense_repository.dart';

class GetExpenseDetailsUseCase {
  const GetExpenseDetailsUseCase(this.repository);

  final ExpenseRepository repository;

  Future<ExpenseEntity> call(int id) => repository.getExpense(id);
}

