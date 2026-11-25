import 'package:get/get.dart';
import 'package:netsales/features/commercial/domain/usecases/get_pos_page_use_case.dart';
import 'package:netsales/features/commercial/presentation/controllers/pos_directory_controller.dart';

class PosDirectoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PosDirectoryController>(
      () => PosDirectoryController(Get.find<GetPosPageUseCase>()),
    );
  }
}
