import 'package:netsales/core/models/app_picked_file_model.dart';
import 'package:netsales/features/expenses/domain/entities/expense_entity.dart';
import 'package:netsales/features/expenses/domain/repositories/expense_repository.dart';

class UpdateExpenseUseCase {
  const UpdateExpenseUseCase(this.repository);

  final ExpenseRepository repository;

  Future<ExpenseEntity> call({
    required int expenseId,
    required String expenseDate,
    required List<Map<String, dynamic>> items,
    required List<AppPickedFileModel> attachments,
  }) {
    return repository.updateExpense(
      expenseId: expenseId,
      expenseDate: expenseDate,
      items: items,
      attachments: attachments,
    );
  }
}

