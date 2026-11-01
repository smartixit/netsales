import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/features/partners/domain/entities/network_pos_entity.dart';
import 'package:netsales/features/wallets/domain/repositories/wallets_repository.dart';

class GetPosLinkedNetworksUseCase {
  final WalletsRepository repository;

  const GetPosLinkedNetworksUseCase(this.repository);

  Future<ApiResponse<List<NetworkPosEntity>>> call(int posId) {
    return repository.getPosLinkedNetworks(posId);
  }
}

