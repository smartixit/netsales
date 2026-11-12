import 'package:netsales/features/expenses/domain/entities/expense_entity.dart';

/// Output boundary for official operating-expense vouchers.
abstract interface class ExpenseDocumentRepository {
  Future<bool> exportAndSave(ExpenseEntity expense);

  Future<bool> share(ExpenseEntity expense);

  Future<bool> print(ExpenseEntity expense);
}
