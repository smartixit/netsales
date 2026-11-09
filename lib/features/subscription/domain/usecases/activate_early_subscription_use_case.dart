import 'package:netsales/features/subscription/domain/entities/provider_subscription_entity.dart';
import 'package:netsales/features/subscription/domain/repositories/subscription_repository.dart';

/// حالة استخدام التفعيل المبكر للاشتراك المجدول (Activate Early Subscription Use Case)
class ActivateEarlySubscriptionUseCase {
  const ActivateEarlySubscriptionUseCase(this._repository);

  final SubscriptionRepository _repository;

  Future<ProviderSubscriptionEntity> execute(int networkId) {
    return _repository.activateEarlyForNetwork(networkId);
  }
}
