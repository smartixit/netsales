import 'package:netsales/features/more/domain/repositories/more_repository.dart';

/// ============================================================================
/// حالة استخدام إنشاء قيد مصروف تشغيلي (CreateExpenseUseCase)
/// ============================================================================
class CreateExpenseUseCase {
  final MoreRepository _repository;

  const CreateExpenseUseCase(this._repository);

  Future<bool> call({
    required int networkId,
    required double totalAmount,
    String? expenseDate,
    String? notes,
  }) =>
      _repository.createExpense(
        networkId: networkId,
        totalAmount: totalAmount,
        expenseDate: expenseDate,
        notes: notes,
      );
}
