import 'package:get/get.dart';
import 'package:netsales/features/catalog/data/datasources/package_catalog_remote_datasource.dart';
import 'package:netsales/features/catalog/data/datasources/package_catalog_remote_datasource_impl.dart';
import 'package:netsales/features/catalog/data/repositories/package_catalog_repository_impl.dart';
import 'package:netsales/features/catalog/domain/repositories/package_catalog_repository.dart';
import 'package:netsales/features/catalog/domain/usecases/delete_package_use_case.dart';
import 'package:netsales/features/catalog/domain/usecases/get_packages_use_case.dart';
import 'package:netsales/features/catalog/domain/usecases/toggle_package_status_use_case.dart';
import 'package:netsales/features/catalog/presentation/controllers/package_catalog_controller.dart';
import 'package:netsales/features/commercial/data/datasources/commercial_remote_data_source.dart';
import 'package:netsales/features/commercial/data/datasources/commercial_remote_data_source_impl.dart';
import 'package:netsales/features/commercial/data/repositories/commercial_repository_impl.dart';
import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_networks_use_case.dart';

/// مصفوفة حقن التبعيات لقائمة كتالوج الباقات (Package Catalog Binding)
class PackageCatalogBinding extends Bindings {
  @override
  void dependencies() {
    // 1. Data Source & Repository
    if (!Get.isRegistered<PackageCatalogRemoteDataSource>()) {
      Get.lazyPut<PackageCatalogRemoteDataSource>(
        () => const PackageCatalogRemoteDataSourceImpl(),
      );
    }

    if (!Get.isRegistered<PackageCatalogRepository>()) {
      Get.lazyPut<PackageCatalogRepository>(
        () => PackageCatalogRepositoryImpl(
          Get.find<PackageCatalogRemoteDataSource>(),
        ),
      );
    }

    // Commercial dependency for networks
    if (!Get.isRegistered<CommercialRemoteDataSource>()) {
      Get.lazyPut<CommercialRemoteDataSource>(
        () => const CommercialRemoteDataSourceImpl(),
      );
    }
    if (!Get.isRegistered<CommercialRepository>()) {
      Get.lazyPut<CommercialRepository>(
        () => CommercialRepositoryImpl(Get.find<CommercialRemoteDataSource>()),
      );
    }
    if (!Get.isRegistered<GetMyNetworksUseCase>()) {
      Get.lazyPut<GetMyNetworksUseCase>(
        () => GetMyNetworksUseCase(Get.find<CommercialRepository>()),
      );
    }

    // 2. Use Cases
    Get.lazyPut<GetPackagesUseCase>(
      () => GetPackagesUseCase(Get.find<PackageCatalogRepository>()),
    );
    Get.lazyPut<TogglePackageStatusUseCase>(
      () => TogglePackageStatusUseCase(Get.find<PackageCatalogRepository>()),
    );
    Get.lazyPut<DeletePackageUseCase>(
      () => DeletePackageUseCase(Get.find<PackageCatalogRepository>()),
    );

    // 3. Controller
    Get.lazyPut<PackageCatalogController>(
      () => PackageCatalogController(
        getPackagesUseCase: Get.find<GetPackagesUseCase>(),
        togglePackageStatusUseCase: Get.find<TogglePackageStatusUseCase>(),
        deletePackageUseCase: Get.find<DeletePackageUseCase>(),
        getMyNetworksUseCase: Get.find<GetMyNetworksUseCase>(),
      ),
    );
  }
}
