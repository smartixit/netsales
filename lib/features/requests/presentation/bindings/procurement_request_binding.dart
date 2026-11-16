import 'package:get/get.dart';
import 'package:netsales/features/catalog/data/datasources/package_catalog_remote_datasource.dart';
import 'package:netsales/features/catalog/data/datasources/package_catalog_remote_datasource_impl.dart';
import 'package:netsales/features/catalog/data/repositories/package_catalog_repository_impl.dart';
import 'package:netsales/features/catalog/domain/repositories/package_catalog_repository.dart';
import 'package:netsales/features/catalog/domain/usecases/get_effective_package_discount_use_case.dart';
import 'package:netsales/features/catalog/domain/usecases/get_packages_use_case.dart';
import 'package:netsales/features/commercial/data/datasources/commercial_remote_data_source.dart';
import 'package:netsales/features/commercial/data/datasources/commercial_remote_data_source_impl.dart';
import 'package:netsales/features/commercial/data/repositories/commercial_repository_impl.dart';
import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_networks_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_pos_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_pos_networks_list_use_case.dart';
import 'package:netsales/features/requests/data/datasources/request_remote_data_source.dart';
import 'package:netsales/features/requests/data/datasources/request_remote_data_source_impl.dart';
import 'package:netsales/features/requests/data/repositories/request_repository_impl.dart';
import 'package:netsales/features/requests/domain/repositories/request_repository.dart';
import 'package:netsales/features/requests/domain/usecases/approve_request_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/cancel_request_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/create_request_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/get_procurement_quote_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/get_request_details_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/get_requests_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/reject_request_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/preview_request_modification_use_case.dart';
import 'package:netsales/features/requests/presentation/controllers/network_procurement_review_controller.dart';
import 'package:netsales/features/requests/presentation/controllers/pos_procurement_controller.dart';
import 'package:netsales/features/requests/presentation/controllers/procurement_request_details_controller.dart';

/// ربط التبعيات لدورة حياة طلبات التوريد والشراء (Milestone 6 Binding)
class ProcurementRequestBinding extends Bindings {
  @override
  void dependencies() {
    // 1. Data Source & Repository (fenix: true للبقاء حياً عبر التنقل بين الشاشات)
    Get.lazyPut<RequestRemoteDataSource>(
      () => const RequestRemoteDataSourceImpl(),
      fenix: true,
    );
    Get.lazyPut<RequestRepository>(
      () => RequestRepositoryImpl(Get.find<RequestRemoteDataSource>()),
      fenix: true,
    );

    // 2. Commercial & Catalog Dependencies for Dropdowns
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
    if (!Get.isRegistered<GetMyPosUseCase>()) {
      Get.lazyPut(
        () => GetMyPosUseCase(Get.find<CommercialRepository>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<GetPosNetworksListUseCase>()) {
      Get.lazyPut(
        () => GetPosNetworksListUseCase(Get.find<CommercialRepository>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<GetMyNetworksUseCase>()) {
      Get.lazyPut(
        () => GetMyNetworksUseCase(Get.find<CommercialRepository>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<PackageCatalogRemoteDataSource>()) {
      Get.lazyPut<PackageCatalogRemoteDataSource>(
        () => const PackageCatalogRemoteDataSourceImpl(),
        fenix: true,
      );
    }
    if (!Get.isRegistered<PackageCatalogRepository>()) {
      Get.lazyPut<PackageCatalogRepository>(
        () => PackageCatalogRepositoryImpl(
          Get.find<PackageCatalogRemoteDataSource>(),
        ),
        fenix: true,
      );
    }
    if (!Get.isRegistered<GetPackagesUseCase>()) {
      Get.lazyPut<GetPackagesUseCase>(
        () => GetPackagesUseCase(Get.find<PackageCatalogRepository>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<GetEffectivePackageDiscountUseCase>()) {
      Get.lazyPut<GetEffectivePackageDiscountUseCase>(
        () => GetEffectivePackageDiscountUseCase(
          Get.find<PackageCatalogRepository>(),
        ),
        fenix: true,
      );
    }

    // 3. Request Use Cases (مع تحديد الصنف الصريح و fenix: true)
    Get.lazyPut<GetRequestsUseCase>(
      () => GetRequestsUseCase(Get.find<RequestRepository>()),
      fenix: true,
    );
    Get.lazyPut<GetRequestDetailsUseCase>(
      () => GetRequestDetailsUseCase(Get.find<RequestRepository>()),
      fenix: true,
    );
    Get.lazyPut<CreateRequestUseCase>(
      () => CreateRequestUseCase(Get.find<RequestRepository>()),
      fenix: true,
    );
    Get.lazyPut<CancelRequestUseCase>(
      () => CancelRequestUseCase(Get.find<RequestRepository>()),
      fenix: true,
    );
    Get.lazyPut<ApproveRequestUseCase>(
      () => ApproveRequestUseCase(Get.find<RequestRepository>()),
      fenix: true,
    );
    Get.lazyPut<RejectRequestUseCase>(
      () => RejectRequestUseCase(Get.find<RequestRepository>()),
      fenix: true,
    );
    Get.lazyPut<PreviewRequestModificationUseCase>(
      () => PreviewRequestModificationUseCase(Get.find<RequestRepository>()),
      fenix: true,
    );
    Get.lazyPut<GetProcurementQuoteUseCase>(
      () => GetProcurementQuoteUseCase(Get.find<RequestRepository>()),
      fenix: true,
    );

    // 4. Controllers
    Get.lazyPut<PosProcurementController>(
      () => PosProcurementController(
        getRequestsUseCase: Get.find<GetRequestsUseCase>(),
        createRequestUseCase: Get.find<CreateRequestUseCase>(),
        cancelRequestUseCase: Get.find<CancelRequestUseCase>(),
        getMyPosUseCase: Get.find<GetMyPosUseCase>(),
        getPosNetworksListUseCase: Get.find<GetPosNetworksListUseCase>(),
        getPackagesUseCase: Get.find<GetPackagesUseCase>(),
        getEffectivePackageDiscountUseCase:
            Get.find<GetEffectivePackageDiscountUseCase>(),
        getProcurementQuoteUseCase: Get.find<GetProcurementQuoteUseCase>(),
      ),
      fenix: true,
    );

    Get.lazyPut<NetworkProcurementReviewController>(
      () => NetworkProcurementReviewController(
        getRequestsUseCase: Get.find<GetRequestsUseCase>(),
        approveRequestUseCase: Get.find<ApproveRequestUseCase>(),
        rejectRequestUseCase: Get.find<RejectRequestUseCase>(),
        previewRequestModificationUseCase:
            Get.find<PreviewRequestModificationUseCase>(),
        getPackagesUseCase: Get.find<GetPackagesUseCase>(),
        getRequestDetailsUseCase: Get.find<GetRequestDetailsUseCase>(),
        getMyNetworksUseCase: Get.find<GetMyNetworksUseCase>(),
      ),
      fenix: true,
    );

    Get.lazyPut<ProcurementRequestDetailsController>(
      () => ProcurementRequestDetailsController(
        getRequestDetailsUseCase: Get.find<GetRequestDetailsUseCase>(),
      ),
      fenix: true,
    );
  }
}
