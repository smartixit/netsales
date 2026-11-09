import 'package:netsales/features/workspace/domain/entities/network_workspace_overview_entity.dart';
import 'package:netsales/features/workspace/domain/repositories/network_workspace_repository.dart';

class GetNetworkWorkspaceOverviewUseCase {
  const GetNetworkWorkspaceOverviewUseCase(this._repository);

  final NetworkWorkspaceRepository _repository;

  Future<NetworkWorkspaceOverviewEntity> call(
    int networkId, {
    String period = '30d',
  }) {
    return _repository.getOverview(networkId, period: period);
  }
}
