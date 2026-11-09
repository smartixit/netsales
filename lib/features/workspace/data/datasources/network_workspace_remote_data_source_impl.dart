import 'package:netsales/core/constants/api_constants.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/services/api_service.dart';
import 'package:netsales/features/workspace/data/datasources/network_workspace_remote_data_source.dart';
import 'package:netsales/features/workspace/data/models/network_workspace_overview_model.dart';

class NetworkWorkspaceRemoteDataSourceImpl
    implements NetworkWorkspaceRemoteDataSource {
  const NetworkWorkspaceRemoteDataSourceImpl();

  @override
  Future<NetworkWorkspaceOverviewModel> getOverview(
    int networkId, {
    required String period,
  }) async {
    final response = await ApiService.instance
        .get<NetworkWorkspaceOverviewModel>(
          ApiConstants.networkWorkspaceOverview(networkId),
          queryParameters: {'period': period},
          fromJson: NetworkWorkspaceOverviewModel.fromJson,
        );
    if (!response.success || response.data == null) {
      throw AppException(response.message);
    }
    return response.data!;
  }
}
