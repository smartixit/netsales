import 'package:netsales/features/more/domain/repositories/more_repository.dart';

/// ============================================================================
/// حالة استخدام تبديل حالة الحساب المصرفي (ToggleBankAccountStatusUseCase)
/// ============================================================================
class ToggleBankAccountStatusUseCase {
  final MoreRepository _repository;

  const ToggleBankAccountStatusUseCase(this._repository);

  Future<bool> call(int accountId) =>
      _repository.toggleBankAccountStatus(accountId);
}
