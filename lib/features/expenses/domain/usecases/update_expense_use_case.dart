import 'package:netsales/features/expenses/domain/entities/expense_entity.dart';
import 'package:netsales/features/expenses/domain/repositories/expense_repository.dart';

/// حالة استخدام تحديث مصروف تشغيلي قائم
class UpdateExpenseUseCase {
  const UpdateExpenseUseCase(this._repository);

  final ExpenseRepository _repository;

  Future<ExpenseEntity> call({
    required int expenseId,
    String? expenseDate,
    List<Map<String, dynamic>>? items,
    List<String> attachmentPaths = const [],
  }) {
    return _repository.updateExpense(
      expenseId: expenseId,
      expenseDate: expenseDate,
      items: items,
      attachmentPaths: attachmentPaths,
    );
  }
}
