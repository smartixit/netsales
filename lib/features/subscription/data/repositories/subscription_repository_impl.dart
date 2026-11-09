import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/features/subscription/data/datasources/subscription_remote_data_source.dart';
import 'package:netsales/features/subscription/domain/entities/provider_subscription_entity.dart';
import 'package:netsales/features/subscription/domain/repositories/subscription_repository.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionRemoteDataSource _remoteDataSource;

  const SubscriptionRepositoryImpl(this._remoteDataSource);

  @override
  Future<ProviderSubscriptionEntity?> getActiveForNetwork(int networkId) async {
    final response = await _remoteDataSource.getActiveForNetwork(networkId);
    if (!response.success) {
      throw AppException(response.message);
    }
    return response.data?.toEntity();
  }

  @override
  Future<ProviderSubscriptionEntity> activateEarlyForNetwork(
    int networkId,
  ) async {
    final response = await _remoteDataSource.activateEarlyForNetwork(networkId);
    if (!response.success || response.data == null) {
      throw AppException(response.message);
    }
    return response.data!.toEntity();
  }

  @override
  Future<void> consumeFeature({
    required int networkId,
    required String featureName,
    int amount = 1,
  }) async {
    final response = await _remoteDataSource.consumeFeature(
      networkId: networkId,
      featureName: featureName,
      amount: amount,
    );
    if (!response.success) {
      throw AppException(response.message);
    }
  }
}
