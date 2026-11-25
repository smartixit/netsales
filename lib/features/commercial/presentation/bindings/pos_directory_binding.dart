import 'package:get/get.dart';
import 'package:netsales/core/di/register_lazy_if_absent.dart';
import 'package:netsales/features/commercial/domain/usecases/get_trashed_pos_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/restore_pos_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_pos_page_use_case.dart';
import 'package:netsales/features/commercial/presentation/controllers/pos_directory_controller.dart';

class PosDirectoryBinding extends Bindings {
  @override
  void dependencies() {
    registerLazyIfAbsent<PosDirectoryController>(
      () => PosDirectoryController(
        Get.find<GetPosPageUseCase>(),
        Get.find<GetTrashedPosUseCase>(),
        Get.find<RestorePosUseCase>(),
      ),
      fenix: true,
    );
  }
}
