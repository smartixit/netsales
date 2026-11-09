import 'package:netsales/features/workspace/data/models/network_workspace_overview_model.dart';

abstract interface class NetworkWorkspaceRemoteDataSource {
  Future<NetworkWorkspaceOverviewModel> getOverview(
    int networkId, {
    required String period,
  });
}
