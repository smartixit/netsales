import 'package:netsales/features/subscription/domain/entities/provider_subscription_entity.dart';
import 'package:netsales/features/subscription/domain/repositories/subscription_repository.dart';

/// حالة استخدام جلب الاشتراك النشط للشبكة (Get Active Network Subscription Use Case)
class GetActiveNetworkSubscriptionUseCase {
  const GetActiveNetworkSubscriptionUseCase(this._repository);

  final SubscriptionRepository _repository;

  Future<ProviderSubscriptionEntity?> execute(int networkId) {
    return _repository.getActiveForNetwork(networkId);
  }
}

