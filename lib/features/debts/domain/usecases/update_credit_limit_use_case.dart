import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/features/debts/domain/repositories/debts_repository.dart';
import 'package:netsales/features/partners/domain/entities/pos_wallet_entity.dart';

class UpdateCreditLimitUseCase {
  final DebtsRepository repository;

  const UpdateCreditLimitUseCase(this.repository);

  Future<ApiResponse<PosWalletEntity>> call({
    required int walletId,
    double? creditLimit,
  }) {
    return repository.updateCreditLimit(
      walletId: walletId,
      creditLimit: creditLimit,
    );
  }
}

