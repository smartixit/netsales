import 'package:netsales/features/more/domain/entities/bank_account_entity.dart';
import 'package:netsales/features/more/domain/repositories/more_repository.dart';

/// ============================================================================
/// حالة استخدام استرجاع الحسابات المصرفية (GetBankAccountsUseCase)
/// ============================================================================
class GetBankAccountsUseCase {
  final MoreRepository _repository;

  const GetBankAccountsUseCase(this._repository);

  Future<List<BankAccountEntity>> call() => _repository.getBankAccounts();
}
