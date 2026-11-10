import 'package:netsales/features/subscription/domain/entities/provider_subscription_entity.dart';

/// عقد مستودع الاشتراكات والحصص (Subscription Repository Contract)
abstract interface class SubscriptionRepository {
  /// جلب الاشتراك النشط الحالي لشبكة محددة مع حصصها واستهلاكها
  Future<ProviderSubscriptionEntity?> getActiveForNetwork(int networkId);

  /// تفعيل الاشتراك المجدول في طابور الانتظار مبكراً للشبكة
  Future<ProviderSubscriptionEntity> activateEarlyForNetwork(int networkId);

  /// تسجيل استهلاك ميزة محددة للشبكة
  Future<void> consumeFeature({
    required int networkId,
    required String featureName,
    int amount = 1,
  });
}

