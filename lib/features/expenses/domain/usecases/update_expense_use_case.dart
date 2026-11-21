import 'package:netsales/core/models/app_picked_file_model.dart';
import 'package:netsales/features/expenses/domain/entities/expense_entity.dart';
import 'package:netsales/features/expenses/domain/entities/new_expense_item_input_entity.dart';
import 'package:netsales/features/expenses/domain/repositories/expense_repository.dart';

/// حالة استخدام تحديث بيانات مصروف تشغيلي مع تسوية فارق رصيد المحفظة (UpdateExpenseUseCase)
class UpdateExpenseUseCase {
  const UpdateExpenseUseCase(this.repository);

  final ExpenseRepository repository;

  Future<ExpenseEntity> call({
    required int expenseId,
    DateTime? expenseDate,
    List<NewExpenseItemInputEntity>? items,
    List<AppPickedFileModel>? attachments,
  }) {
    return repository.updateExpense(
      expenseId: expenseId,
      expenseDate: expenseDate,
      items: items,
      attachments: attachments,
    );
  }
}
