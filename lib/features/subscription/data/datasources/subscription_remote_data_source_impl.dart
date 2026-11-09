import 'package:netsales/core/constants/api_constants.dart';
import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/core/services/api_service.dart';
import 'package:netsales/features/subscription/data/datasources/subscription_remote_data_source.dart';
import 'package:netsales/features/subscription/data/models/provider_subscription_model.dart';

class SubscriptionRemoteDataSourceImpl implements SubscriptionRemoteDataSource {
  const SubscriptionRemoteDataSourceImpl();

  @override
  Future<ApiResponse<ProviderSubscriptionModel?>> getActiveForNetwork(
    int networkId,
  ) {
    return ApiService.instance.get<ProviderSubscriptionModel?>(
      ApiConstants.providerSubscriptionActiveForNetwork(networkId),
      fromJson: (json) {
        if (json == null) return null;
        return ProviderSubscriptionModel.fromJson(
          Map<String, dynamic>.from(json as Map),
        );
      },
    );
  }

  @override
  Future<ApiResponse<ProviderSubscriptionModel>> activateEarlyForNetwork(
    int networkId,
  ) {
    return ApiService.instance.post<ProviderSubscriptionModel>(
      ApiConstants.providerSubscriptionActivateEarly(networkId),
      fromJson: (json) => ProviderSubscriptionModel.fromJson(
        Map<String, dynamic>.from(json as Map),
      ),
    );
  }

  @override
  Future<ApiResponse<void>> consumeFeature({
    required int networkId,
    required String featureName,
    int amount = 1,
  }) {
    return ApiService.instance.post<void>(
      ApiConstants.providerSubscriptionConsume(networkId),
      data: {'feature_name': featureName, 'amount': amount},
    );
  }
}
