import 'package:get/get.dart';
import 'package:netsales/core/di/register_lazy_if_absent.dart';
import 'package:netsales/features/commercial/domain/usecases/get_trashed_networks_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/restore_network_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_networks_page_use_case.dart';
import 'package:netsales/features/commercial/presentation/controllers/network_directory_controller.dart';

class NetworkDirectoryBinding extends Bindings {
  @override
  void dependencies() {
    registerLazyIfAbsent<NetworkDirectoryController>(
      () => NetworkDirectoryController(
        Get.find<GetNetworksPageUseCase>(),
        Get.find<GetTrashedNetworksUseCase>(),
        Get.find<RestoreNetworkUseCase>(),
      ),
      fenix: true,
    );
  }
}
