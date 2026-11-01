import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/features/wallets/domain/entities/network_wallet_entity.dart';
import 'package:netsales/features/wallets/domain/repositories/wallets_repository.dart';

class GetNetworkWalletUseCase {
  final WalletsRepository repository;

  const GetNetworkWalletUseCase(this.repository);

  Future<ApiResponse<NetworkWalletEntity>> call(int networkId) {
    return repository.getNetworkWallet(networkId);
  }
}

