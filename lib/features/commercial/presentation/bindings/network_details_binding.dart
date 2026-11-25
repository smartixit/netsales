import 'package:get/get.dart';
import 'package:netsales/features/commercial/domain/usecases/get_network_details_use_case.dart';
import 'package:netsales/features/commercial/presentation/controllers/network_details_controller.dart';
import 'package:netsales/features/commercial/domain/usecases/delete_network_use_case.dart';

class NetworkDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NetworkDetailsController>(
      () => NetworkDetailsController(
        Get.find<GetNetworkDetailsUseCase>(),
        Get.find<DeleteNetworkUseCase>(),
      ),
    );
  }
}
