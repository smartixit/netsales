import 'package:get/get.dart';
import 'package:netsales/features/subscription_billing/data/network_billing_repository.dart';
import 'package:netsales/features/subscription_billing/presentation/network_subscription_billing_controller.dart';

class NetworkSubscriptionBillingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NetworkBillingRepository>(() => const NetworkBillingRepository());
    Get.lazyPut<NetworkSubscriptionBillingController>(
      () => NetworkSubscriptionBillingController(Get.find<NetworkBillingRepository>()),
    );
  }
}
