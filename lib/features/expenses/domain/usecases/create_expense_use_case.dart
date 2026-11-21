import 'package:netsales/core/models/app_picked_file_model.dart';
import 'package:netsales/features/expenses/domain/entities/expense_entity.dart';
import 'package:netsales/features/expenses/domain/entities/new_expense_item_input_entity.dart';
import 'package:netsales/features/expenses/domain/repositories/expense_repository.dart';

/// حالة استخدام تسجيل مصروف تشغيلي جديد وخصمه من المحفظة (CreateExpenseUseCase)
class CreateExpenseUseCase {
  const CreateExpenseUseCase(this._repository);

  final ExpenseRepository _repository;

  Future<ExpenseEntity> call({
    required int networkId,
    DateTime? expenseDate,
    required List<NewExpenseItemInputEntity> items,
    List<AppPickedFileModel>? attachments,
    String? idempotencyKey,
  }) {
    return _repository.createExpense(
      networkId: networkId,
      expenseDate: expenseDate,
      items: items,
      attachments: attachments,
      idempotencyKey: idempotencyKey,
    );
  }
}
