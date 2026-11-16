import 'package:get/get.dart';
import 'package:netsales/core/di/register_lazy_if_absent.dart';
import 'package:netsales/features/catalog/data/datasources/package_catalog_remote_datasource.dart';
import 'package:netsales/features/catalog/data/datasources/package_catalog_remote_datasource_impl.dart';
import 'package:netsales/features/catalog/data/repositories/package_catalog_repository_impl.dart';
import 'package:netsales/features/catalog/domain/repositories/package_catalog_repository.dart';
import 'package:netsales/features/catalog/domain/usecases/get_packages_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_network_pos_list_use_case.dart';
import 'package:netsales/features/commercial/data/datasources/commercial_remote_data_source.dart';
import 'package:netsales/features/commercial/data/datasources/commercial_remote_data_source_impl.dart';
import 'package:netsales/features/commercial/data/repositories/commercial_repository_impl.dart';
import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_networks_use_case.dart';
import 'package:netsales/features/invoices/data/datasources/invoice_remote_data_source.dart';
import 'package:netsales/features/invoices/data/datasources/invoice_remote_data_source_impl.dart';
import 'package:netsales/features/invoices/data/repositories/invoice_repository_impl.dart';
import 'package:netsales/features/invoices/data/repositories/invoice_document_repository_impl.dart';
import 'package:netsales/features/invoices/data/services/invoice_document_service.dart';
import 'package:netsales/features/invoices/domain/repositories/invoice_repository.dart';
import 'package:netsales/features/invoices/domain/repositories/invoice_document_repository.dart';
import 'package:netsales/features/invoices/domain/usecases/get_invoice_details_use_case.dart';
import 'package:netsales/features/invoices/domain/usecases/invoice_document_use_case.dart';
import 'package:netsales/features/invoices/domain/usecases/get_network_invoices_use_case.dart';
import 'package:netsales/features/invoices/domain/usecases/get_pos_invoices_use_case.dart';
import 'package:netsales/features/invoices/domain/usecases/create_direct_sale_invoice_use_case.dart';
import 'package:netsales/features/invoices/presentation/controllers/network_direct_invoice_controller.dart';
import 'package:netsales/features/invoices/presentation/controllers/invoice_details_controller.dart';
import 'package:netsales/features/invoices/presentation/controllers/network_invoices_controller.dart';
import 'package:netsales/features/invoices/presentation/controllers/pos_invoices_controller.dart';

/// ربط اعتمادات ميزة الفواتير والمحاسبة (Invoicing & Accounting Binding)
class InvoiceBinding extends Bindings {
  @override
  void dependencies() {
    // 1. Data Source
    registerLazyIfAbsent<InvoiceRemoteDataSource>(
      () => const InvoiceRemoteDataSourceImpl(),
      fenix: true,
    );

    // 2. Commercial Data Source (للشبكات المصرح بها)
    if (!Get.isRegistered<CommercialRemoteDataSource>()) {
      registerLazyIfAbsent<CommercialRemoteDataSource>(
        () => const CommercialRemoteDataSourceImpl(),
        fenix: true,
      );
    }
    if (!Get.isRegistered<CommercialRepository>()) {
      registerLazyIfAbsent<CommercialRepository>(
        () => CommercialRepositoryImpl(Get.find<CommercialRemoteDataSource>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<GetMyNetworksUseCase>()) {
      registerLazyIfAbsent<GetMyNetworksUseCase>(
        () => GetMyNetworksUseCase(Get.find<CommercialRepository>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<GetNetworkPosListUseCase>()) {
      registerLazyIfAbsent<GetNetworkPosListUseCase>(
        () => GetNetworkPosListUseCase(Get.find<CommercialRepository>()),
        fenix: true,
      );
    }

    // Package catalog dependencies used by the Network direct invoice form.
    if (!Get.isRegistered<PackageCatalogRemoteDataSource>()) {
      registerLazyIfAbsent<PackageCatalogRemoteDataSource>(
        () => const PackageCatalogRemoteDataSourceImpl(),
        fenix: true,
      );
    }
    if (!Get.isRegistered<PackageCatalogRepository>()) {
      registerLazyIfAbsent<PackageCatalogRepository>(
        () => PackageCatalogRepositoryImpl(
          Get.find<PackageCatalogRemoteDataSource>(),
        ),
        fenix: true,
      );
    }
    if (!Get.isRegistered<GetPackagesUseCase>()) {
      registerLazyIfAbsent<GetPackagesUseCase>(
        () => GetPackagesUseCase(Get.find<PackageCatalogRepository>()),
        fenix: true,
      );
    }

    // 3. Repository
    registerLazyIfAbsent<InvoiceRepository>(
      () => InvoiceRepositoryImpl(
        remoteDataSource: Get.find<InvoiceRemoteDataSource>(),
      ),
      fenix: true,
    );

    // 4. Use Cases
    registerLazyIfAbsent<GetNetworkInvoicesUseCase>(
      () => GetNetworkInvoicesUseCase(Get.find<InvoiceRepository>()),
      fenix: true,
    );
    registerLazyIfAbsent<GetPosInvoicesUseCase>(
      () => GetPosInvoicesUseCase(Get.find<InvoiceRepository>()),
      fenix: true,
    );
    registerLazyIfAbsent<GetInvoiceDetailsUseCase>(
      () => GetInvoiceDetailsUseCase(Get.find<InvoiceRepository>()),
      fenix: true,
    );
    registerLazyIfAbsent<InvoiceDocumentService>(
      () => InvoiceDocumentService.instance,
      fenix: true,
    );
    registerLazyIfAbsent<InvoiceDocumentRepository>(
      () => InvoiceDocumentRepositoryImpl(
        documentService: Get.find<InvoiceDocumentService>(),
      ),
      fenix: true,
    );
    registerLazyIfAbsent<InvoiceDocumentUseCase>(
      () => InvoiceDocumentUseCase(Get.find<InvoiceDocumentRepository>()),
      fenix: true,
    );
    registerLazyIfAbsent<CreateDirectSaleInvoiceUseCase>(
      () => CreateDirectSaleInvoiceUseCase(Get.find<InvoiceRepository>()),
      fenix: true,
    );

    // 5. Controllers
    registerLazyIfAbsent<NetworkInvoicesController>(
      () => NetworkInvoicesController(
        getNetworkInvoicesUseCase: Get.find<GetNetworkInvoicesUseCase>(),
        getMyNetworksUseCase: Get.find<GetMyNetworksUseCase>(),
      ),
      fenix: true,
    );

    registerLazyIfAbsent<NetworkDirectInvoiceController>(
      () => NetworkDirectInvoiceController(
        getMyNetworksUseCase: Get.find<GetMyNetworksUseCase>(),
        getNetworkPosListUseCase: Get.find<GetNetworkPosListUseCase>(),
        getPackagesUseCase: Get.find<GetPackagesUseCase>(),
        createDirectSaleInvoiceUseCase:
            Get.find<CreateDirectSaleInvoiceUseCase>(),
      ),
      fenix: true,
    );

    registerLazyIfAbsent<PosInvoicesController>(
      () => PosInvoicesController(
        getPosInvoicesUseCase: Get.find<GetPosInvoicesUseCase>(),
      ),
      fenix: true,
    );

    registerLazyIfAbsent<InvoiceDetailsController>(
      () => InvoiceDetailsController(
        getInvoiceDetailsUseCase: Get.find<GetInvoiceDetailsUseCase>(),
        invoiceDocumentUseCase: Get.find<InvoiceDocumentUseCase>(),
      ),
      fenix: true,
    );
  }
}
