import 'package:get/get.dart';
import 'package:netsales/features/operations/data/datasources/operations_remote_data_source.dart';
import 'package:netsales/features/operations/data/datasources/operations_remote_data_source_impl.dart';
import 'package:netsales/features/operations/data/repositories/operations_repository_impl.dart';
import 'package:netsales/features/operations/domain/repositories/operations_repository.dart';
import 'package:netsales/features/operations/domain/usecases/approve_voucher_request_use_case.dart';
import 'package:netsales/features/operations/domain/usecases/get_sale_invoices_use_case.dart';
import 'package:netsales/features/operations/domain/usecases/get_voucher_requests_use_case.dart';
import 'package:netsales/features/operations/domain/usecases/reject_voucher_request_use_case.dart';
import 'package:netsales/features/operations/presentation/controllers/operations_controller.dart';

class OperationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OperationsRemoteDataSource>(
      () => OperationsRemoteDataSourceImpl(),
      fenix: true,
    );
    Get.lazyPut<OperationsRepository>(
      () => OperationsRepositoryImpl(Get.find<OperationsRemoteDataSource>()),
      fenix: true,
    );
    Get.lazyPut<GetSaleInvoicesUseCase>(
      () => GetSaleInvoicesUseCase(Get.find<OperationsRepository>()),
      fenix: true,
    );
    Get.lazyPut<GetVoucherRequestsUseCase>(
      () => GetVoucherRequestsUseCase(Get.find<OperationsRepository>()),
      fenix: true,
    );
    Get.lazyPut<ApproveVoucherRequestUseCase>(
      () => ApproveVoucherRequestUseCase(Get.find<OperationsRepository>()),
      fenix: true,
    );
    Get.lazyPut<RejectVoucherRequestUseCase>(
      () => RejectVoucherRequestUseCase(Get.find<OperationsRepository>()),
      fenix: true,
    );
    Get.lazyPut<OperationsController>(
      () => OperationsController(
        getSaleInvoicesUseCase: Get.find<GetSaleInvoicesUseCase>(),
        getVoucherRequestsUseCase: Get.find<GetVoucherRequestsUseCase>(),
        approveVoucherRequestUseCase: Get.find<ApproveVoucherRequestUseCase>(),
        rejectVoucherRequestUseCase: Get.find<RejectVoucherRequestUseCase>(),
      ),
      fenix: true,
    );
  }
}
