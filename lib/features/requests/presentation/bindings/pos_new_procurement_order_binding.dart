import 'package:get/get.dart';
import 'package:netsales/core/di/register_lazy_if_absent.dart';
import 'package:netsales/features/catalog/domain/usecases/get_effective_package_discounts_for_pos_use_case.dart';
import 'package:netsales/features/catalog/domain/usecases/get_packages_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_pos_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_pos_networks_list_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/create_request_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/get_procurement_quote_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/update_request_use_case.dart';
import 'package:netsales/features/requests/presentation/bindings/procurement_request_binding.dart';
import 'package:netsales/features/requests/presentation/controllers/pos_new_procurement_order_controller.dart';

/// Route-scoped dependencies for creating or editing one procurement request.
class PosNewProcurementOrderBinding extends Bindings {
  @override
  void dependencies() {
    ProcurementRequestBinding().dependencies();

    registerLazyIfAbsent<PosNewProcurementOrderController>(
      () => PosNewProcurementOrderController(
        createRequestUseCase: Get.find<CreateRequestUseCase>(),
        updateRequestUseCase: Get.find<UpdateRequestUseCase>(),
        getMyPosUseCase: Get.find<GetMyPosUseCase>(),
        getPosNetworksListUseCase: Get.find<GetPosNetworksListUseCase>(),
        getPackagesUseCase: Get.find<GetPackagesUseCase>(),
        getEffectivePackageDiscountsForPosUseCase:
            Get.find<GetEffectivePackageDiscountsForPosUseCase>(),
        getProcurementQuoteUseCase: Get.find<GetProcurementQuoteUseCase>(),
      ),
    );
  }
}
