import 'package:get/get.dart';
import 'package:netsales/features/packages/data/datasources/packages_remote_data_source.dart';
import 'package:netsales/features/packages/data/datasources/packages_remote_data_source_impl.dart';
import 'package:netsales/features/packages/data/repositories/packages_repository_impl.dart';
import 'package:netsales/features/packages/domain/repositories/packages_repository.dart';
import 'package:netsales/features/packages/domain/usecases/create_voucher_package_discount_use_case.dart';
import 'package:netsales/features/packages/domain/usecases/create_voucher_package_use_case.dart';
import 'package:netsales/features/packages/domain/usecases/delete_voucher_package_discount_use_case.dart';
import 'package:netsales/features/packages/domain/usecases/delete_voucher_package_use_case.dart';
import 'package:netsales/features/packages/domain/usecases/get_effective_discount_use_case.dart';
import 'package:netsales/features/packages/domain/usecases/get_voucher_package_details_use_case.dart';
import 'package:netsales/features/packages/domain/usecases/get_voucher_package_discounts_use_case.dart';
import 'package:netsales/features/packages/domain/usecases/get_voucher_packages_use_case.dart';
import 'package:netsales/features/packages/domain/usecases/toggle_voucher_package_discount_status_use_case.dart';
import 'package:netsales/features/packages/domain/usecases/toggle_voucher_package_status_use_case.dart';
import 'package:netsales/features/packages/domain/usecases/update_voucher_package_discount_use_case.dart';
import 'package:netsales/features/packages/domain/usecases/update_voucher_package_use_case.dart';
import 'package:netsales/features/packages/presentation/controllers/packages_controller.dart';
import 'package:netsales/features/partners/data/datasources/partners_remote_data_source.dart';
import 'package:netsales/features/partners/data/datasources/partners_remote_data_source_impl.dart';
import 'package:netsales/features/partners/data/repositories/partners_repository_impl.dart';
import 'package:netsales/features/partners/domain/repositories/partners_repository.dart';
import 'package:netsales/features/partners/domain/usecases/get_networks_use_case.dart';
import 'package:netsales/features/partners/domain/usecases/get_pos_list_use_case.dart';

/// ============================================================================
/// رابط تبعيات باقات الكروت والخصومات (PackagesBinding)
/// ============================================================================
/// يربط سلسلة الاعتمادية النظيفة بالترتيب الإلزامي:
/// DataSource -> Repository -> UseCases -> Controller.
class PackagesBinding extends Bindings {
  @override
  void dependencies() {
    // 1. Data Source
    Get.lazyPut<PackagesRemoteDataSource>(
      () => const PackagesRemoteDataSourceImpl(),
    );

    // 2. Repository
    Get.lazyPut<PackagesRepository>(
      () => PackagesRepositoryImpl(Get.find<PackagesRemoteDataSource>()),
    );

    // 3. Voucher Packages UseCases
    Get.lazyPut<GetVoucherPackagesUseCase>(
      () => GetVoucherPackagesUseCase(Get.find<PackagesRepository>()),
    );
    Get.lazyPut<GetVoucherPackageDetailsUseCase>(
      () => GetVoucherPackageDetailsUseCase(Get.find<PackagesRepository>()),
    );
    Get.lazyPut<CreateVoucherPackageUseCase>(
      () => CreateVoucherPackageUseCase(Get.find<PackagesRepository>()),
    );
    Get.lazyPut<UpdateVoucherPackageUseCase>(
      () => UpdateVoucherPackageUseCase(Get.find<PackagesRepository>()),
    );
    Get.lazyPut<ToggleVoucherPackageStatusUseCase>(
      () => ToggleVoucherPackageStatusUseCase(Get.find<PackagesRepository>()),
    );
    Get.lazyPut<DeleteVoucherPackageUseCase>(
      () => DeleteVoucherPackageUseCase(Get.find<PackagesRepository>()),
    );

    // 4. Voucher Package Discounts UseCases
    Get.lazyPut<GetVoucherPackageDiscountsUseCase>(
      () => GetVoucherPackageDiscountsUseCase(Get.find<PackagesRepository>()),
    );
    Get.lazyPut<CreateVoucherPackageDiscountUseCase>(
      () => CreateVoucherPackageDiscountUseCase(Get.find<PackagesRepository>()),
    );
    Get.lazyPut<UpdateVoucherPackageDiscountUseCase>(
      () => UpdateVoucherPackageDiscountUseCase(Get.find<PackagesRepository>()),
    );
    Get.lazyPut<ToggleVoucherPackageDiscountStatusUseCase>(
      () => ToggleVoucherPackageDiscountStatusUseCase(
        Get.find<PackagesRepository>(),
      ),
    );
    Get.lazyPut<DeleteVoucherPackageDiscountUseCase>(
      () => DeleteVoucherPackageDiscountUseCase(Get.find<PackagesRepository>()),
    );
    Get.lazyPut<GetEffectiveDiscountUseCase>(
      () => GetEffectiveDiscountUseCase(Get.find<PackagesRepository>()),
    );

    // 5. Partners Dependencies (للاختيار الذكي لنقاط البيع والوكلاء)
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
    if (!Get.isRegistered<GetPosListUseCase>()) {
      Get.lazyPut<GetPosListUseCase>(
        () => GetPosListUseCase(Get.find<PartnersRepository>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<GetNetworksUseCase>()) {
      Get.lazyPut<GetNetworksUseCase>(
        () => GetNetworksUseCase(Get.find<PartnersRepository>()),
        fenix: true,
      );
    }

    // 6. Controller
    Get.lazyPut<PackagesController>(
      () => PackagesController(
        getVoucherPackagesUseCase: Get.find<GetVoucherPackagesUseCase>(),
        getVoucherPackageDetailsUseCase:
            Get.find<GetVoucherPackageDetailsUseCase>(),
        createVoucherPackageUseCase: Get.find<CreateVoucherPackageUseCase>(),
        updateVoucherPackageUseCase: Get.find<UpdateVoucherPackageUseCase>(),
        toggleVoucherPackageStatusUseCase:
            Get.find<ToggleVoucherPackageStatusUseCase>(),
        deleteVoucherPackageUseCase: Get.find<DeleteVoucherPackageUseCase>(),
        getVoucherPackageDiscountsUseCase:
            Get.find<GetVoucherPackageDiscountsUseCase>(),
        createVoucherPackageDiscountUseCase:
            Get.find<CreateVoucherPackageDiscountUseCase>(),
        updateVoucherPackageDiscountUseCase:
            Get.find<UpdateVoucherPackageDiscountUseCase>(),
        toggleVoucherPackageDiscountStatusUseCase:
            Get.find<ToggleVoucherPackageDiscountStatusUseCase>(),
        deleteVoucherPackageDiscountUseCase:
            Get.find<DeleteVoucherPackageDiscountUseCase>(),
        getEffectiveDiscountUseCase: Get.find<GetEffectiveDiscountUseCase>(),
        getPosListUseCase: Get.find<GetPosListUseCase>(),
        getNetworksUseCase: Get.find<GetNetworksUseCase>(),
      ),
    );
  }
}
