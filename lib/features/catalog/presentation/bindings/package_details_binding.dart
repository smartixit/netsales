import 'package:get/get.dart';
import 'package:netsales/features/catalog/data/datasources/package_catalog_remote_datasource.dart';
import 'package:netsales/features/catalog/data/datasources/package_catalog_remote_datasource_impl.dart';
import 'package:netsales/features/catalog/data/repositories/package_catalog_repository_impl.dart';
import 'package:netsales/features/catalog/domain/repositories/package_catalog_repository.dart';
import 'package:netsales/features/catalog/domain/usecases/delete_package_use_case.dart';
import 'package:netsales/features/catalog/domain/usecases/get_package_details_use_case.dart';
import 'package:netsales/features/catalog/domain/usecases/toggle_package_status_use_case.dart';
import 'package:netsales/features/catalog/presentation/controllers/package_details_controller.dart';

/// مصفوفة حقن التبعيات لشاشة تفاصيل باقة الكروت (Package Details Binding)
class PackageDetailsBinding extends Bindings {
  @override
  void dependencies() {
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

    Get.lazyPut<GetPackageDetailsUseCase>(
      () => GetPackageDetailsUseCase(Get.find<PackageCatalogRepository>()),
    );
    Get.lazyPut<TogglePackageStatusUseCase>(
      () => TogglePackageStatusUseCase(Get.find<PackageCatalogRepository>()),
    );
    Get.lazyPut<DeletePackageUseCase>(
      () => DeletePackageUseCase(Get.find<PackageCatalogRepository>()),
    );

    Get.lazyPut<PackageDetailsController>(
      () => PackageDetailsController(
        getPackageDetailsUseCase: Get.find<GetPackageDetailsUseCase>(),
        togglePackageStatusUseCase: Get.find<TogglePackageStatusUseCase>(),
        deletePackageUseCase: Get.find<DeletePackageUseCase>(),
      ),
    );
  }
}
