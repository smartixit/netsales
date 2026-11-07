import 'package:get/get.dart';
import 'package:netsales/features/catalog/data/datasources/package_catalog_remote_datasource.dart';
import 'package:netsales/features/catalog/data/datasources/package_catalog_remote_datasource_impl.dart';
import 'package:netsales/features/catalog/data/repositories/package_catalog_repository_impl.dart';
import 'package:netsales/features/catalog/domain/repositories/package_catalog_repository.dart';
import 'package:netsales/features/catalog/domain/usecases/create_package_use_case.dart';
import 'package:netsales/features/catalog/domain/usecases/delete_package_use_case.dart';
import 'package:netsales/features/catalog/domain/usecases/get_network_packages_use_case.dart';
import 'package:netsales/features/catalog/domain/usecases/get_package_details_use_case.dart';
import 'package:netsales/features/catalog/domain/usecases/get_packages_use_case.dart';
import 'package:netsales/features/catalog/domain/usecases/toggle_package_status_use_case.dart';
import 'package:netsales/features/catalog/domain/usecases/update_package_use_case.dart';
import 'package:netsales/features/catalog/presentation/controllers/package_catalog_controller.dart';
import 'package:netsales/features/commercial/data/datasources/commercial_remote_data_source.dart';
import 'package:netsales/features/commercial/data/datasources/commercial_remote_data_source_impl.dart';
import 'package:netsales/features/commercial/data/repositories/commercial_repository_impl.dart';
import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_networks_use_case.dart';

/// ربط التبعيات لميزة كتالوج باقات الكروت والأسعار التعاقدية
class PackageCatalogBinding extends Bindings {
  @override
  void dependencies() {
    // 1. Data Source
    Get.lazyPut<PackageCatalogRemoteDataSource>(
      () => const PackageCatalogRemoteDataSourceImpl(),
    );

    // 2. Repository
    Get.lazyPut<PackageCatalogRepository>(
      () => PackageCatalogRepositoryImpl(
        Get.find<PackageCatalogRemoteDataSource>(),
      ),
    );

    // 3. Commercial Dependencies for Network Selection
    if (!Get.isRegistered<CommercialRemoteDataSource>()) {
      Get.lazyPut<CommercialRemoteDataSource>(
        () => const CommercialRemoteDataSourceImpl(),
      );
    }
    if (!Get.isRegistered<CommercialRepository>()) {
      Get.lazyPut<CommercialRepository>(
        () => CommercialRepositoryImpl(
          Get.find<CommercialRemoteDataSource>(),
        ),
      );
    }
    if (!Get.isRegistered<GetMyNetworksUseCase>()) {
      Get.lazyPut(
        () => GetMyNetworksUseCase(Get.find<CommercialRepository>()),
      );
    }

    // 4. Use Cases
    Get.lazyPut(
      () => GetPackagesUseCase(Get.find<PackageCatalogRepository>()),
    );
    Get.lazyPut(
      () => GetNetworkPackagesUseCase(Get.find<PackageCatalogRepository>()),
    );
    Get.lazyPut(
      () => GetPackageDetailsUseCase(Get.find<PackageCatalogRepository>()),
    );
    Get.lazyPut(
      () => CreatePackageUseCase(Get.find<PackageCatalogRepository>()),
    );
    Get.lazyPut(
      () => UpdatePackageUseCase(Get.find<PackageCatalogRepository>()),
    );
    Get.lazyPut(
      () => TogglePackageStatusUseCase(Get.find<PackageCatalogRepository>()),
    );
    Get.lazyPut(
      () => DeletePackageUseCase(Get.find<PackageCatalogRepository>()),
    );

    // 5. Controller
    Get.lazyPut<PackageCatalogController>(
      () => PackageCatalogController(
        getPackagesUseCase: Get.find<GetPackagesUseCase>(),
        getNetworkPackagesUseCase: Get.find<GetNetworkPackagesUseCase>(),
        getPackageDetailsUseCase: Get.find<GetPackageDetailsUseCase>(),
        createPackageUseCase: Get.find<CreatePackageUseCase>(),
        updatePackageUseCase: Get.find<UpdatePackageUseCase>(),
        togglePackageStatusUseCase: Get.find<TogglePackageStatusUseCase>(),
        deletePackageUseCase: Get.find<DeletePackageUseCase>(),
        getMyNetworksUseCase: Get.find<GetMyNetworksUseCase>(),
      ),
    );
  }
}
