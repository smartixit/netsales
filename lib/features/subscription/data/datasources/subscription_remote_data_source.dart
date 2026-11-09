import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/features/subscription/data/models/provider_subscription_model.dart';

/// عقد مصدر البيانات البعيد لاشتراكات مزودي الشبكات والحصص
abstract interface class SubscriptionRemoteDataSource {
  /// جلب الاشتراك النشط الحالي لشبكة محددة
  Future<ApiResponse<ProviderSubscriptionModel?>> getActiveForNetwork(
    int networkId,
  );

  /// التفعيل المبكر للاشتراك المجدول التالي للشبكة
  Future<ApiResponse<ProviderSubscriptionModel>> activateEarlyForNetwork(
    int networkId,
  );

  /// تسجيل استهلاك ميزة محددة للشبكة
  Future<ApiResponse<void>> consumeFeature({
    required int networkId,
    required String featureName,
    int amount = 1,
  });
}
