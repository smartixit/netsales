import 'package:get/get.dart';
import 'package:netsales/features/commercial/domain/usecases/get_network_details_use_case.dart';
import 'package:netsales/features/commercial/presentation/controllers/network_details_controller.dart';

class NetworkDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NetworkDetailsController>(
      () => NetworkDetailsController(Get.find<GetNetworkDetailsUseCase>()),
    );
  }
}
