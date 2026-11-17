import 'package:get/get.dart';
import 'package:netsales/core/di/register_lazy_if_absent.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_pos_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/cancel_request_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/delete_request_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/get_requests_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/get_request_status_summary_use_case.dart';
import 'package:netsales/features/requests/presentation/bindings/procurement_request_binding.dart';
import 'package:netsales/features/requests/presentation/controllers/pos_procurement_orders_controller.dart';

/// Route-scoped dependencies for the POS procurement orders collection.
class PosProcurementOrdersBinding extends Bindings {
  @override
  void dependencies() {
    ProcurementRequestBinding().dependencies();

    registerLazyIfAbsent<PosProcurementOrdersController>(
      () => PosProcurementOrdersController(
        getRequestsUseCase: Get.find<GetRequestsUseCase>(),
        getRequestStatusSummaryUseCase: Get.find<GetRequestStatusSummaryUseCase>(),
        getMyPosUseCase: Get.find<GetMyPosUseCase>(),
        cancelRequestUseCase: Get.find<CancelRequestUseCase>(),
        deleteRequestUseCase: Get.find<DeleteRequestUseCase>(),
      ),
    );
  }
}
