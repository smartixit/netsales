import 'package:get/get.dart';
import 'package:netsales/core/di/register_lazy_if_absent.dart';
import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/features/catalog/domain/usecases/get_packages_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_network_pos_list_use_case.dart';
import 'package:netsales/features/invoices/data/datasources/invoice_remote_data_source.dart';
import 'package:netsales/features/invoices/data/datasources/invoice_remote_data_source_impl.dart';
import 'package:netsales/features/invoices/data/repositories/invoice_document_repository_impl.dart';
import 'package:netsales/features/invoices/data/repositories/invoice_repository_impl.dart';
import 'package:netsales/features/invoices/domain/repositories/invoice_document_repository.dart';
import 'package:netsales/features/invoices/domain/repositories/invoice_repository.dart';
import 'package:netsales/features/invoices/domain/usecases/create_direct_sale_invoice_use_case.dart';
import 'package:netsales/features/invoices/domain/usecases/get_invoice_details_use_case.dart';
import 'package:netsales/features/invoices/domain/usecases/get_invoices_use_case.dart';
import 'package:netsales/features/invoices/domain/usecases/get_network_invoices_use_case.dart';
import 'package:netsales/features/invoices/domain/usecases/get_pos_invoices_use_case.dart';
import 'package:netsales/features/invoices/domain/usecases/invoice_document_use_case.dart';
import 'package:netsales/features/invoices/presentation/controllers/base_invoices_controller.dart';
import 'package:netsales/features/invoices/presentation/controllers/invoice_details_controller.dart';
import 'package:netsales/features/invoices/presentation/controllers/network_direct_invoice_controller.dart';
import 'package:netsales/features/invoices/presentation/controllers/network_invoices_controller.dart';
import 'package:netsales/features/invoices/presentation/controllers/pos_invoices_controller.dart';

/// ربط التبعيات لدورة حياة فواتير المبيعات والمشتريات (Invoices Module Binding)
class InvoiceBinding extends Bindings {
  @override
  void dependencies() {
    // 1. مصادر البيانات والمستودعات
    registerLazyIfAbsent<InvoiceRemoteDataSource>(
      () => const InvoiceRemoteDataSourceImpl(),
      fenix: true,
    );
    registerLazyIfAbsent<InvoiceRepository>(
      () => InvoiceRepositoryImpl(
        remoteDataSource: Get.find<InvoiceRemoteDataSource>(),
      ),
      fenix: true,
    );
    registerLazyIfAbsent<InvoiceDocumentRepository>(
      () => const InvoiceDocumentRepositoryImpl(),
      fenix: true,
    );

    // 2. حالات الاستخدام (Use Cases)
    registerLazyIfAbsent<GetInvoicesUseCase>(
      () => GetInvoicesUseCase(Get.find<InvoiceRepository>()),
      fenix: true,
    );
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
    registerLazyIfAbsent<CreateDirectSaleInvoiceUseCase>(
      () => CreateDirectSaleInvoiceUseCase(Get.find<InvoiceRepository>()),
      fenix: true,
    );
    registerLazyIfAbsent<InvoiceDocumentUseCase>(
      () => InvoiceDocumentUseCase(Get.find<InvoiceDocumentRepository>()),
      fenix: true,
    );

    // 3. المتحكمات (Controllers)
    registerLazyIfAbsent<NetworkInvoicesController>(
      () => NetworkInvoicesController(
        getNetworkInvoicesUseCase: Get.find<GetNetworkInvoicesUseCase>(),
        invoiceDocumentUseCase: Get.find<InvoiceDocumentUseCase>(),
      ),
      fenix: true,
    );

    registerLazyIfAbsent<PosInvoicesController>(
      () => PosInvoicesController(
        getPosInvoicesUseCase: Get.find<GetPosInvoicesUseCase>(),
        invoiceDocumentUseCase: Get.find<InvoiceDocumentUseCase>(),
      ),
      fenix: true,
    );

    // تسجيل BaseInvoicesController وفق مساحة العمل أو المسار الحالي
    registerLazyIfAbsent<BaseInvoicesController>(() {
      final currentRoute = Get.currentRoute;
      final isPos =
          currentRoute == AppRoutes.purchaseInvoices ||
          (Get.isRegistered<WorkspaceService>() &&
              WorkspaceService.to.activeWorkspace == AppWorkspace.pos);

      if (isPos) {
        return Get.find<PosInvoicesController>();
      }
      return Get.find<NetworkInvoicesController>();
    }, fenix: true);

    registerLazyIfAbsent<InvoiceDetailsController>(
      () => InvoiceDetailsController(
        getInvoiceDetailsUseCase: Get.find<GetInvoiceDetailsUseCase>(),
        invoiceDocumentUseCase: Get.find<InvoiceDocumentUseCase>(),
      ),
      fenix: true,
    );

    registerLazyIfAbsent<NetworkDirectInvoiceController>(
      () => NetworkDirectInvoiceController(
        createDirectSaleInvoiceUseCase:
            Get.find<CreateDirectSaleInvoiceUseCase>(),
        getPackagesUseCase: Get.isRegistered<GetPackagesUseCase>()
            ? Get.find<GetPackagesUseCase>()
            : null,
        getNetworkPosListUseCase: Get.isRegistered<GetNetworkPosListUseCase>()
            ? Get.find<GetNetworkPosListUseCase>()
            : null,
      ),
      fenix: true,
    );
  }
}
