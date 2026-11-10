import 'package:netsales/features/finance/domain/repositories/finance_repository.dart';

class UpdatePosCreditLimitUseCase {
  final FinanceRepository repository;

  const UpdatePosCreditLimitUseCase(this.repository);

  Future<void> call({
    required int posWalletId,
    required double? creditLimit,
  }) {
    return repository.updatePosCreditLimit(
      posWalletId: posWalletId,
      creditLimit: creditLimit,
    );
  }
}

