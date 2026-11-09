import 'package:get/get.dart';
import 'package:netsales/features/subscription/data/datasources/subscription_remote_data_source.dart';
import 'package:netsales/features/subscription/data/datasources/subscription_remote_data_source_impl.dart';
import 'package:netsales/features/subscription/data/repositories/subscription_repository_impl.dart';
import 'package:netsales/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:netsales/features/subscription/domain/usecases/activate_early_subscription_use_case.dart';
import 'package:netsales/features/subscription/domain/usecases/consume_feature_use_case.dart';
import 'package:netsales/features/subscription/domain/usecases/get_active_network_subscription_use_case.dart';
import 'package:netsales/features/subscription/presentation/controllers/network_subscription_controller.dart';

/// ربط تبعيات شاشة اشتراكات الشبكة والحصص (NetworkSubscriptionBinding)
class NetworkSubscriptionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SubscriptionRemoteDataSource>(
      () => const SubscriptionRemoteDataSourceImpl(),
    );
    Get.lazyPut<SubscriptionRepository>(
      () =>
          SubscriptionRepositoryImpl(Get.find<SubscriptionRemoteDataSource>()),
    );
    Get.lazyPut<GetActiveNetworkSubscriptionUseCase>(
      () => GetActiveNetworkSubscriptionUseCase(
        Get.find<SubscriptionRepository>(),
      ),
    );
    Get.lazyPut<ActivateEarlySubscriptionUseCase>(
      () =>
          ActivateEarlySubscriptionUseCase(Get.find<SubscriptionRepository>()),
    );
    Get.lazyPut<ConsumeFeatureUseCase>(
      () => ConsumeFeatureUseCase(Get.find<SubscriptionRepository>()),
    );
    Get.lazyPut<NetworkSubscriptionController>(
      () => NetworkSubscriptionController(
        getActiveSubscriptionUseCase:
            Get.find<GetActiveNetworkSubscriptionUseCase>(),
        activateEarlyUseCase: Get.find<ActivateEarlySubscriptionUseCase>(),
        consumeFeatureUseCase: Get.find<ConsumeFeatureUseCase>(),
      ),
    );
  }
}
