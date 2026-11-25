import 'package:get/get.dart';
import 'package:netsales/features/commercial/domain/usecases/get_pos_details_use_case.dart';
import 'package:netsales/features/commercial/presentation/controllers/pos_details_controller.dart';
import 'package:netsales/features/commercial/domain/usecases/delete_pos_use_case.dart';

class PosDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PosDetailsController>(
      () => PosDetailsController(
        Get.find<GetPosDetailsUseCase>(),
        Get.find<DeletePosUseCase>(),
      ),
    );
  }
}
