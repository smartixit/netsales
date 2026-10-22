import 'package:netsales/core/constants/api_constants.dart';
import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/core/services/api_service.dart';
import 'package:netsales/features/home/data/datasources/dashboard_remote_data_source.dart';
import 'package:netsales/features/home/data/models/dashboard_overview_model.dart';

/// ============================================================================
/// تطبيق مصدر البيانات البعيد للوحة القيادة عبر ApiService
/// ============================================================================
class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  const DashboardRemoteDataSourceImpl();

  @override
  Future<ApiResponse<DashboardOverviewModel>> getOverview({
    String period = 'today',
    int? networkId,
    int? posId,
    bool refresh = false,
  }) {
    final queryParameters = <String, dynamic>{
      'period': period,
      if (networkId != null) 'network_id': networkId,
      if (posId != null) 'pos_id': posId,
      if (refresh) 'refresh': true,
    };

    return ApiService.instance.get<DashboardOverviewModel>(
      ApiConstants.dashboardOverview,
      queryParameters: queryParameters,
      fromJson: (json) => DashboardOverviewModel.fromJson(json as Map<String, dynamic>),
    );
  }
}
