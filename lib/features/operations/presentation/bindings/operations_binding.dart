import 'package:get/get.dart';
import 'package:netsales/features/operations/data/datasources/operations_remote_data_source.dart';
import 'package:netsales/features/operations/data/datasources/operations_remote_data_source_impl.dart';
import 'package:netsales/features/operations/data/repositories/operations_repository_impl.dart';
import 'package:netsales/features/operations/domain/repositories/operations_repository.dart';
import 'package:netsales/features/operations/domain/usecases/approve_voucher_request_use_case.dart';
import 'package:netsales/features/operations/domain/usecases/cancel_voucher_request_use_case.dart';
import 'package:netsales/features/operations/domain/usecases/get_sale_invoice_details_use_case.dart';
import 'package:netsales/features/operations/domain/usecases/get_sale_invoices_use_case.dart';
import 'package:netsales/features/operations/domain/usecases/get_voucher_request_details_use_case.dart';
import 'package:netsales/features/operations/domain/usecases/get_voucher_requests_use_case.dart';
import 'package:netsales/features/operations/domain/usecases/reject_voucher_request_use_case.dart';
import 'package:netsales/features/operations/domain/usecases/create_sale_invoice_use_case.dart';
import 'package:netsales/features/operations/domain/usecases/create_voucher_request_use_case.dart';
import 'package:netsales/features/operations/presentation/controllers/operations_controller.dart';
import 'package:netsales/features/packages/data/datasources/packages_remote_data_source.dart';
import 'package:netsales/features/packages/data/datasources/packages_remote_data_source_impl.dart';
import 'package:netsales/features/packages/data/repositories/packages_repository_impl.dart';
import 'package:netsales/features/packages/domain/repositories/packages_repository.dart';
import 'package:netsales/features/packages/domain/usecases/get_voucher_packages_use_case.dart';
import 'package:netsales/features/partners/data/datasources/partners_remote_data_source.dart';
import 'package:netsales/features/partners/data/datasources/partners_remote_data_source_impl.dart';
import 'package:netsales/features/partners/data/repositories/partners_repository_impl.dart';
import 'package:netsales/features/partners/domain/repositories/partners_repository.dart';
import 'package:netsales/features/partners/domain/usecases/get_network_pos_list_use_case.dart';
import 'package:netsales/features/partners/domain/usecases/get_networks_use_case.dart';

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
    Get.lazyPut<ApproveVoucherRequestUseCase>(
      () => ApproveVoucherRequestUseCase(Get.find<OperationsRepository>()),
      fenix: true,
    );
    Get.lazyPut<RejectVoucherRequestUseCase>(
      () => RejectVoucherRequestUseCase(Get.find<OperationsRepository>()),
      fenix: true,
    );
    Get.lazyPut<GetSaleInvoiceDetailsUseCase>(
      () => GetSaleInvoiceDetailsUseCase(Get.find<OperationsRepository>()),
      fenix: true,
    );
    Get.lazyPut<GetVoucherRequestsUseCase>(
      () => GetVoucherRequestsUseCase(Get.find<OperationsRepository>()),
      fenix: true,
    );
    Get.lazyPut<GetVoucherRequestDetailsUseCase>(
      () => GetVoucherRequestDetailsUseCase(Get.find<OperationsRepository>()),
      fenix: true,
    );
    Get.lazyPut<CancelVoucherRequestUseCase>(
      () => CancelVoucherRequestUseCase(Get.find<OperationsRepository>()),
      fenix: true,
    );
    Get.lazyPut<CreateVoucherRequestUseCase>(
      () => CreateVoucherRequestUseCase(Get.find<OperationsRepository>()),
      fenix: true,
    );
    Get.lazyPut<CreateSaleInvoiceUseCase>(
      () => CreateSaleInvoiceUseCase(Get.find<OperationsRepository>()),
      fenix: true,
    );

    // تسجيل التبعيات المساعدة للفوترة وتوريد الكروت إن لم تكن مسجلة مسبقاً
    if (!Get.isRegistered<PackagesRemoteDataSource>()) {
      Get.lazyPut<PackagesRemoteDataSource>(
        () => const PackagesRemoteDataSourceImpl(),
        fenix: true,
      );
    }
    if (!Get.isRegistered<PackagesRepository>()) {
      Get.lazyPut<PackagesRepository>(
        () => PackagesRepositoryImpl(Get.find<PackagesRemoteDataSource>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<GetVoucherPackagesUseCase>()) {
      Get.lazyPut<GetVoucherPackagesUseCase>(
        () => GetVoucherPackagesUseCase(Get.find<PackagesRepository>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<PartnersRemoteDataSource>()) {
      Get.lazyPut<PartnersRemoteDataSource>(
        () => const PartnersRemoteDataSourceImpl(),
        fenix: true,
      );
    }
    if (!Get.isRegistered<PartnersRepository>()) {
      Get.lazyPut<PartnersRepository>(
        () => PartnersRepositoryImpl(Get.find<PartnersRemoteDataSource>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<GetNetworksUseCase>()) {
      Get.lazyPut<GetNetworksUseCase>(
        () => GetNetworksUseCase(Get.find<PartnersRepository>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<GetNetworkPosListUseCase>()) {
      Get.lazyPut<GetNetworkPosListUseCase>(
        () => GetNetworkPosListUseCase(Get.find<PartnersRepository>()),
        fenix: true,
      );
    }

    Get.lazyPut<OperationsController>(
      () => OperationsController(
        getSaleInvoicesUseCase: Get.find<GetSaleInvoicesUseCase>(),
        getVoucherRequestsUseCase: Get.find<GetVoucherRequestsUseCase>(),
        approveVoucherRequestUseCase: Get.find<ApproveVoucherRequestUseCase>(),
        rejectVoucherRequestUseCase: Get.find<RejectVoucherRequestUseCase>(),
        getSaleInvoiceDetailsUseCase: Get.find<GetSaleInvoiceDetailsUseCase>(),
        getVoucherRequestDetailsUseCase:
            Get.find<GetVoucherRequestDetailsUseCase>(),
        cancelVoucherRequestUseCase: Get.find<CancelVoucherRequestUseCase>(),
        createVoucherRequestUseCase: Get.find<CreateVoucherRequestUseCase>(),
        createSaleInvoiceUseCase: Get.find<CreateSaleInvoiceUseCase>(),
      ),
      fenix: true,
    );
  }
}
