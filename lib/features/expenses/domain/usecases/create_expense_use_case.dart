import 'package:netsales/features/expenses/domain/entities/expense_entity.dart';
import 'package:netsales/features/expenses/domain/repositories/expense_repository.dart';

/// حالة استخدام تسجيل مصروف تشغيلي جديد
class CreateExpenseUseCase {
  const CreateExpenseUseCase(this._repository);

  final ExpenseRepository _repository;

  Future<ExpenseEntity> call({
    required int networkId,
    String? expenseDate,
    required List<Map<String, dynamic>> items,
    List<String> attachmentPaths = const [],
  }) {
    return _repository.createExpense(
      networkId: networkId,
      expenseDate: expenseDate,
      items: items,
      attachmentPaths: attachmentPaths,
    );
  }
}
