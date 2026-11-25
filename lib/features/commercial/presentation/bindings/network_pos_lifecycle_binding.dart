import 'package:get/get.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/catalog/data/datasources/package_catalog_remote_datasource.dart';
import 'package:netsales/features/catalog/data/datasources/package_catalog_remote_datasource_impl.dart';
import 'package:netsales/features/catalog/data/repositories/package_catalog_repository_impl.dart';
import 'package:netsales/features/catalog/domain/repositories/package_catalog_repository.dart';
import 'package:netsales/features/catalog/domain/usecases/get_network_packages_use_case.dart';
import 'package:netsales/features/catalog/data/datasources/package_pos_discount_remote_data_source.dart';
import 'package:netsales/features/catalog/data/datasources/package_pos_discount_remote_data_source_impl.dart';
import 'package:netsales/features/catalog/data/repositories/package_pos_discount_repository_impl.dart';
import 'package:netsales/features/catalog/domain/repositories/package_pos_discount_repository.dart';
import 'package:netsales/features/catalog/domain/usecases/get_package_pos_discounts_for_pos_use_case.dart';
import 'package:netsales/features/catalog/domain/usecases/create_package_pos_discount_use_case.dart';
import 'package:netsales/features/catalog/domain/usecases/update_package_pos_discount_use_case.dart';
import 'package:netsales/features/catalog/domain/usecases/toggle_package_pos_discount_status_use_case.dart';
import 'package:netsales/features/catalog/domain/usecases/delete_package_pos_discount_use_case.dart';
import 'package:netsales/features/catalog/domain/usecases/get_trashed_package_pos_discounts_for_pos_use_case.dart';
import 'package:netsales/features/catalog/domain/usecases/restore_package_pos_discount_use_case.dart';
import 'package:netsales/features/commercial/presentation/controllers/network_pos_lifecycle_controller.dart';
import 'package:netsales/features/commercial/domain/usecases/activate_network_pos_agreement_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/create_network_pos_agreement_draft_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_network_pos_agreements_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_network_pos_events_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/terminate_network_pos_agreement_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_trashed_network_pos_links_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/restore_network_pos_link_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/update_network_pos_agreement_draft_use_case.dart';

class NetworkPosLifecycleBinding extends Bindings {
  @override
  void dependencies() {
    final id = int.tryParse(Get.parameters['id'] ?? '');
    final arguments = Get.arguments is Map ? Get.arguments as Map : const <dynamic, dynamic>{};
    if (id == null || id <= 0) return;
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
    if (!Get.isRegistered<GetNetworkPackagesUseCase>()) {
      Get.lazyPut<GetNetworkPackagesUseCase>(
        () => GetNetworkPackagesUseCase(Get.find<PackageCatalogRepository>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<PackagePosDiscountRemoteDataSource>()) {
      Get.lazyPut<PackagePosDiscountRemoteDataSource>(
        () => const PackagePosDiscountRemoteDataSourceImpl(),
        fenix: true,
      );
    }
    if (!Get.isRegistered<PackagePosDiscountRepository>()) {
      Get.lazyPut<PackagePosDiscountRepository>(
        () => PackagePosDiscountRepositoryImpl(
          Get.find<PackagePosDiscountRemoteDataSource>(),
        ),
        fenix: true,
      );
    }
    if (!Get.isRegistered<GetTrashedPackagePosDiscountsForPosUseCase>()) {
      Get.lazyPut<GetTrashedPackagePosDiscountsForPosUseCase>(
        () => GetTrashedPackagePosDiscountsForPosUseCase(Get.find<PackagePosDiscountRepository>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<RestorePackagePosDiscountUseCase>()) {
      Get.lazyPut<RestorePackagePosDiscountUseCase>(
        () => RestorePackagePosDiscountUseCase(Get.find<PackagePosDiscountRepository>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<GetPackagePosDiscountsForPosUseCase>()) {
      Get.lazyPut<GetPackagePosDiscountsForPosUseCase>(
        () => GetPackagePosDiscountsForPosUseCase(Get.find<PackagePosDiscountRepository>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<CreatePackagePosDiscountUseCase>()) {
      Get.lazyPut<CreatePackagePosDiscountUseCase>(
        () => CreatePackagePosDiscountUseCase(Get.find<PackagePosDiscountRepository>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<UpdatePackagePosDiscountUseCase>()) {
      Get.lazyPut<UpdatePackagePosDiscountUseCase>(
        () => UpdatePackagePosDiscountUseCase(Get.find<PackagePosDiscountRepository>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<TogglePackagePosDiscountStatusUseCase>()) {
      Get.lazyPut<TogglePackagePosDiscountStatusUseCase>(
        () => TogglePackagePosDiscountStatusUseCase(Get.find<PackagePosDiscountRepository>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<DeletePackagePosDiscountUseCase>()) {
      Get.lazyPut<DeletePackagePosDiscountUseCase>(
        () => DeletePackagePosDiscountUseCase(Get.find<PackagePosDiscountRepository>()),
        fenix: true,
      );
    }

    Get.lazyPut<NetworkPosLifecycleController>(
      () => NetworkPosLifecycleController(
        networkPosId: id,
        relationship: arguments['relationship'] is NetworkPosLinkEntity
            ? arguments['relationship'] as NetworkPosLinkEntity
            : null,
        networkId: (arguments['network_id'] as num?)?.toInt() ?? 0,
        posId: (arguments['pos_id'] as num?)?.toInt() ?? 0,
        getNetworkPackagesUseCase: Get.find<GetNetworkPackagesUseCase>(),
        getPackagePosDiscountsUseCase: Get.find<GetPackagePosDiscountsForPosUseCase>(),
        createPackagePosDiscountUseCase: Get.find<CreatePackagePosDiscountUseCase>(),
        updatePackagePosDiscountUseCase: Get.find<UpdatePackagePosDiscountUseCase>(),
        togglePackagePosDiscountStatusUseCase: Get.find<TogglePackagePosDiscountStatusUseCase>(),
        deletePackagePosDiscountUseCase: Get.find<DeletePackagePosDiscountUseCase>(),
        getTrashedPackagePosDiscountsUseCase: Get.find<GetTrashedPackagePosDiscountsForPosUseCase>(),
        restorePackagePosDiscountUseCase: Get.find<RestorePackagePosDiscountUseCase>(),
        entityId: (arguments['entity_id'] as num?)?.toInt() ?? 0,
        isNetworkScope: arguments['is_network'] == true,
        getTrashedLinksUseCase: Get.find<GetTrashedNetworkPosLinksUseCase>(),
        restoreLinkUseCase: Get.find<RestoreNetworkPosLinkUseCase>(),
        getAgreementsUseCase: Get.find<GetNetworkPosAgreementsUseCase>(),
        getEventsUseCase: Get.find<GetNetworkPosEventsUseCase>(),
        createDraftUseCase: Get.find<CreateNetworkPosAgreementDraftUseCase>(),
        updateDraftUseCase: Get.find<UpdateNetworkPosAgreementDraftUseCase>(),
        activateUseCase: Get.find<ActivateNetworkPosAgreementUseCase>(),
        terminateUseCase: Get.find<TerminateNetworkPosAgreementUseCase>(),
      ),
      tag: 'network-pos-lifecycle-$id',
    );
  }
}
