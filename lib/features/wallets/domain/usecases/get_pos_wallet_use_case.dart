import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/features/partners/domain/entities/pos_wallet_entity.dart';
import 'package:netsales/features/wallets/domain/repositories/wallets_repository.dart';

class GetPosWalletUseCase {
  final WalletsRepository repository;

  const GetPosWalletUseCase(this.repository);

  Future<ApiResponse<PosWalletEntity>> call({
    required int networkId,
    required int posId,
  }) {
    return repository.getPosWallet(networkId: networkId, posId: posId);
  }
}

