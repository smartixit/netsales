import 'package:netsales/core/constants/api_constants.dart';
import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/core/services/api_service.dart';
import 'package:netsales/features/more/data/datasources/more_remote_data_source.dart';
import 'package:netsales/features/more/data/models/more_overview_model.dart';
import 'package:netsales/features/more/data/models/more_subscription_model.dart';
import 'package:netsales/features/more/data/models/more_wallet_model.dart';

/// ============================================================================
/// تطبيق مصدر البيانات البعيد لقطاع المزيد (MoreRemoteDataSourceImpl)
/// ============================================================================
class MoreRemoteDataSourceImpl implements MoreRemoteDataSource {
  const MoreRemoteDataSourceImpl();

  @override
  Future<ApiResponse<MoreOverviewModel>> getMoreOverview() async {
    return ApiService.instance.get<MoreOverviewModel>(
      ApiConstants.dashboardOverview,
      fromJson: (json) => MoreOverviewModel.fromJson(
        json is Map ? Map<String, dynamic>.from(json) : <String, dynamic>{},
      ),
    );
  }

  @override
  Future<ApiResponse<MoreWalletModel>> getWalletSummary() async {
    return ApiService.instance.get<MoreWalletModel>(
      ApiConstants.networkWallets,
      fromJson: (json) => MoreWalletModel.fromJson(
        json is Map ? Map<String, dynamic>.from(json) : <String, dynamic>{},
      ),
    );
  }

  @override
  Future<ApiResponse<MoreSubscriptionModel>> getActiveSubscription() async {
    return ApiService.instance.get<MoreSubscriptionModel>(
      ApiConstants.providerSubscriptions,
      fromJson: (json) => MoreSubscriptionModel.fromJson(
        json is Map ? Map<String, dynamic>.from(json) : <String, dynamic>{},
      ),
    );
  }

  @override
  Future<ApiResponse<void>> logout() async {
    return ApiService.instance.post<void>(
      ApiConstants.logout,
    );
  }
}
