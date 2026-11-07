import 'package:get/get.dart';
import 'package:netsales/features/commercial/data/datasources/commercial_remote_data_source.dart';
import 'package:netsales/features/commercial/data/datasources/commercial_remote_data_source_impl.dart';
import 'package:netsales/features/commercial/data/repositories/commercial_repository_impl.dart';
import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_networks_use_case.dart';
import 'package:netsales/features/invoices/data/datasources/invoice_remote_data_source.dart';
import 'package:netsales/features/invoices/data/datasources/invoice_remote_data_source_impl.dart';
import 'package:netsales/features/invoices/data/repositories/invoice_repository_impl.dart';
import 'package:netsales/features/invoices/domain/repositories/invoice_repository.dart';
import 'package:netsales/features/invoices/domain/usecases/get_invoice_details_use_case.dart';
import 'package:netsales/features/invoices/domain/usecases/get_network_invoices_use_case.dart';
import 'package:netsales/features/invoices/domain/usecases/get_pos_invoices_use_case.dart';
import 'package:netsales/features/invoices/presentation/controllers/invoice_details_controller.dart';
import 'package:netsales/features/invoices/presentation/controllers/network_invoices_controller.dart';
import 'package:netsales/features/invoices/presentation/controllers/pos_invoices_controller.dart';

/// ربط اعتمادات ميزة الفواتير والمحاسبة (Invoicing & Accounting Binding)
class InvoiceBinding extends Bindings {
  @override
  void dependencies() {
    // 1. Data Source
    Get.lazyPut<InvoiceRemoteDataSource>(
      () => const InvoiceRemoteDataSourceImpl(),
      fenix: true,
    );

    // 2. Commercial Data Source (للشبكات المصرح بها)
    if (!Get.isRegistered<CommercialRemoteDataSource>()) {
      Get.lazyPut<CommercialRemoteDataSource>(
        () => const CommercialRemoteDataSourceImpl(),
        fenix: true,
      );
    }
    if (!Get.isRegistered<CommercialRepository>()) {
      Get.lazyPut<CommercialRepository>(
        () => CommercialRepositoryImpl(Get.find<CommercialRemoteDataSource>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<GetMyNetworksUseCase>()) {
      Get.lazyPut<GetMyNetworksUseCase>(
        () => GetMyNetworksUseCase(Get.find<CommercialRepository>()),
        fenix: true,
      );
    }

    // 3. Repository
    Get.lazyPut<InvoiceRepository>(
      () => InvoiceRepositoryImpl(
        remoteDataSource: Get.find<InvoiceRemoteDataSource>(),
      ),
      fenix: true,
    );

    // 4. Use Cases
    Get.lazyPut<GetNetworkInvoicesUseCase>(
      () => GetNetworkInvoicesUseCase(Get.find<InvoiceRepository>()),
      fenix: true,
    );
    Get.lazyPut<GetPosInvoicesUseCase>(
      () => GetPosInvoicesUseCase(Get.find<InvoiceRepository>()),
      fenix: true,
    );
    Get.lazyPut<GetInvoiceDetailsUseCase>(
      () => GetInvoiceDetailsUseCase(Get.find<InvoiceRepository>()),
      fenix: true,
    );

    // 5. Controllers
    Get.lazyPut<NetworkInvoicesController>(
      () => NetworkInvoicesController(
        getNetworkInvoicesUseCase: Get.find<GetNetworkInvoicesUseCase>(),
        getMyNetworksUseCase: Get.find<GetMyNetworksUseCase>(),
      ),
      fenix: true,
    );

    Get.lazyPut<PosInvoicesController>(
      () => PosInvoicesController(
        getPosInvoicesUseCase: Get.find<GetPosInvoicesUseCase>(),
      ),
      fenix: true,
    );

    Get.lazyPut<InvoiceDetailsController>(
      () => InvoiceDetailsController(
        getInvoiceDetailsUseCase: Get.find<GetInvoiceDetailsUseCase>(),
      ),
      fenix: true,
    );
  }
}
