import 'package:netsales/features/subscription/domain/repositories/subscription_repository.dart';

class ConsumeFeatureParams {
  final int networkId;
  final String featureName;
  final int amount;

  const ConsumeFeatureParams({
    required this.networkId,
    required this.featureName,
    this.amount = 1,
  });
}

/// حالة استخدام تسجيل استهلاك ميزة للشبكة (Consume Feature Use Case)
class ConsumeFeatureUseCase {
  const ConsumeFeatureUseCase(this._repository);

  final SubscriptionRepository _repository;

  Future<void> execute(ConsumeFeatureParams params) {
    return _repository.consumeFeature(
      networkId: params.networkId,
      featureName: params.featureName,
      amount: params.amount,
    );
  }
}

