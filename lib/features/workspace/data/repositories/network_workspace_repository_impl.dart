import 'package:netsales/features/workspace/data/datasources/network_workspace_remote_data_source.dart';
import 'package:netsales/features/workspace/domain/entities/network_workspace_overview_entity.dart';
import 'package:netsales/features/workspace/domain/repositories/network_workspace_repository.dart';

class NetworkWorkspaceRepositoryImpl implements NetworkWorkspaceRepository {
  const NetworkWorkspaceRepositoryImpl(this._remoteDataSource);

  final NetworkWorkspaceRemoteDataSource _remoteDataSource;

  @override
  Future<NetworkWorkspaceOverviewEntity> getOverview(
    int networkId, {
    required String period,
  }) {
    return _remoteDataSource.getOverview(networkId, period: period);
  }
}
