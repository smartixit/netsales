import 'package:netsales/features/workspace/domain/entities/network_workspace_overview_entity.dart';

abstract interface class NetworkWorkspaceRepository {
  Future<NetworkWorkspaceOverviewEntity> getOverview(
    int networkId, {
    required String period,
  });
}
