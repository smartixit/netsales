import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/features/catalog/domain/repositories/package_catalog_repository.dart';
import 'package:netsales/features/catalog/domain/usecases/create_package_use_case.dart';
import 'package:netsales/features/catalog/domain/usecases/delete_package_use_case.dart';
import 'package:netsales/features/catalog/domain/usecases/get_network_packages_use_case.dart';
import 'package:netsales/features/catalog/domain/usecases/get_package_details_use_case.dart';
import 'package:netsales/features/catalog/domain/usecases/get_packages_use_case.dart';
import 'package:netsales/features/catalog/domain/usecases/toggle_package_status_use_case.dart';
import 'package:netsales/features/catalog/domain/usecases/update_package_use_case.dart';
import 'package:netsales/features/catalog/presentation/controllers/package_catalog_controller.dart';
import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_networks_use_case.dart';

class MockCatalogRepository implements PackageCatalogRepository {
  List<PackageEntity> items;
  bool shouldThrow = false;

  MockCatalogRepository(this.items);

  @override
  Future<PaginatedList<PackageEntity>> getPackages({
    int? networkId,
    bool? status,
    String? search,
    String? cursor,
    int? perPage,
  }) async {
    if (shouldThrow) {
      throw const AppException('فشل الاتصال بالخادم', code: '500');
    }

    final filtered = items.where((p) {
      if (networkId != null && p.networkId != networkId) return false;
      if (status != null && p.status != status) return false;
      if (search != null && search.isNotEmpty) {
        if (!p.packageName.toLowerCase().contains(search.toLowerCase())) {
          return false;
        }
      }
      return true;
    }).toList();

    return PaginatedList<PackageEntity>(
      items: filtered,
      nextCursor: cursor == null && filtered.isNotEmpty ? 'cursor_page_2' : null,
    );
  }

  @override
  Future<PaginatedList<PackageEntity>> getNetworkPackages(
    int networkId, {
    bool? status,
    String? search,
    String? cursor,
    int? perPage,
  }) async {
    if (shouldThrow) {
      throw const AppException('فشل الاتصال بالخادم', code: '500');
    }

    final filtered = items.where((p) {
      if (p.networkId != networkId) return false;
      if (status != null && p.status != status) return false;
      if (search != null && search.isNotEmpty) {
        if (!p.packageName.toLowerCase().contains(search.toLowerCase())) {
          return false;
        }
      }
      return true;
    }).toList();

    return PaginatedList<PackageEntity>(
      items: filtered,
      nextCursor: cursor == null && filtered.isNotEmpty ? 'cursor_page_2' : null,
    );
  }

  @override
  Future<PackageEntity> getPackageDetails(int packageId) async {
    if (shouldThrow) {
      throw const AppException('الباقة غير موجودة', code: '404');
    }
    final pkg = items.cast<PackageEntity?>().firstWhere(
      (p) => p?.packageId == packageId,
      orElse: () => null,
    );
    if (pkg == null) {
      throw const AppException('الباقة غير موجودة', code: '404');
    }
    return pkg;
  }

  @override
  Future<PackageEntity> createPackage(Map<String, dynamic> data) async {
    final pkg = PackageEntity(
      packageId: items.length + 1,
      networkId: data['network_id'] as int? ?? 1,
      packageName: data['package_name'] as String? ?? 'New',
      packageBalance: 10.0,
      packageVoucherCount: 100,
      packageVoucherPrice:
          (data['package_voucher_price'] as num?)?.toDouble() ?? 1000.0,
      packageDefaultCashDiscount: 5.0,
      packageDefaultCreditDiscount: 2.5,
      cashDiscountAmount: 50.0,
      creditDiscountAmount: 25.0,
      effectiveCashPrice: 950.0,
      effectiveCreditPrice: 975.0,
      status: true,
    );
    items.add(pkg);
    return pkg;
  }

  @override
  Future<PackageEntity> updatePackage(
      int packageId, Map<String, dynamic> data) async {
    final index = items.indexWhere((p) => p.packageId == packageId);
    if (index >= 0) {
      final updated = PackageEntity(
        packageId: packageId,
        networkId: items[index].networkId,
        packageName:
            data['package_name'] as String? ?? items[index].packageName,
        packageBalance: items[index].packageBalance,
        packageVoucherCount: items[index].packageVoucherCount,
        packageVoucherPrice:
            (data['package_voucher_price'] as num?)?.toDouble() ??
                items[index].packageVoucherPrice,
        packageDefaultCashDiscount: items[index].packageDefaultCashDiscount,
        packageDefaultCreditDiscount: items[index].packageDefaultCreditDiscount,
        cashDiscountAmount: items[index].cashDiscountAmount,
        creditDiscountAmount: items[index].creditDiscountAmount,
        effectiveCashPrice: items[index].effectiveCashPrice,
        effectiveCreditPrice: items[index].effectiveCreditPrice,
        status: items[index].status,
      );
      items[index] = updated;
      return updated;
    }
    throw const AppException('الباقة غير موجودة', code: '404');
  }

  @override
  Future<bool> deletePackage(int packageId) async {
    final prevCount = items.length;
    items.removeWhere((p) => p.packageId == packageId);
    return items.length < prevCount;
  }

  @override
  Future<PackageEntity> togglePackageStatus(int packageId) async {
    final index = items.indexWhere((p) => p.packageId == packageId);
    if (index >= 0) {
      final updated = PackageEntity(
        packageId: packageId,
        networkId: items[index].networkId,
        packageName: items[index].packageName,
        packageBalance: items[index].packageBalance,
        packageVoucherCount: items[index].packageVoucherCount,
        packageVoucherPrice: items[index].packageVoucherPrice,
        packageDefaultCashDiscount: items[index].packageDefaultCashDiscount,
        packageDefaultCreditDiscount: items[index].packageDefaultCreditDiscount,
        cashDiscountAmount: items[index].cashDiscountAmount,
        creditDiscountAmount: items[index].creditDiscountAmount,
        effectiveCashPrice: items[index].effectiveCashPrice,
        effectiveCreditPrice: items[index].effectiveCreditPrice,
        status: !items[index].status,
      );
      items[index] = updated;
      return updated;
    }
    throw const AppException('الباقة غير موجودة', code: '404');
  }
}

class MockCommercialRepository implements CommercialRepository {
  List<NetworkEntity> networks = [];

  MockCommercialRepository(this.networks);

  @override
  Future<List<NetworkEntity>> getMyNetworks() async => networks;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PackageCatalogController Reactive State Tests', () {
    late MockCatalogRepository mockRepo;
    late MockCommercialRepository mockCommercialRepo;
    late PackageCatalogController controller;

    final sample1 = const PackageEntity(
      packageId: 1,
      networkId: 10,
      packageName: 'باقة الفجر 5G',
      packageBalance: 5.0,
      packageVoucherCount: 100,
      packageVoucherPrice: 1000.0,
      packageDefaultCashDiscount: 10.0,
      packageDefaultCreditDiscount: 5.0,
      cashDiscountAmount: 100.0,
      creditDiscountAmount: 50.0,
      effectiveCashPrice: 900.0,
      effectiveCreditPrice: 950.0,
      status: true,
    );

    final sample2 = const PackageEntity(
      packageId: 2,
      networkId: 10,
      packageName: 'باقة الليل 10G',
      packageBalance: 10.0,
      packageVoucherCount: 200,
      packageVoucherPrice: 2000.0,
      packageDefaultCashDiscount: 15.0,
      packageDefaultCreditDiscount: 10.0,
      cashDiscountAmount: 300.0,
      creditDiscountAmount: 200.0,
      effectiveCashPrice: 1700.0,
      effectiveCreditPrice: 1800.0,
      status: false,
    );

    final sampleNetwork = const NetworkEntity(
      networkId: 10,
      ownerId: 1,
      networkName: 'شبكة صنعاء تيليكوم',
      networkPhoneNumber: '777000000',
    );

    setUp(() {
      mockRepo = MockCatalogRepository([sample1, sample2]);
      mockCommercialRepo = MockCommercialRepository([sampleNetwork]);

      controller = PackageCatalogController(
        getPackagesUseCase: GetPackagesUseCase(mockRepo),
        getNetworkPackagesUseCase: GetNetworkPackagesUseCase(mockRepo),
        getPackageDetailsUseCase: GetPackageDetailsUseCase(mockRepo),
        createPackageUseCase: CreatePackageUseCase(mockRepo),
        updatePackageUseCase: UpdatePackageUseCase(mockRepo),
        togglePackageStatusUseCase: TogglePackageStatusUseCase(mockRepo),
        deletePackageUseCase: DeletePackageUseCase(mockRepo),
        getMyNetworksUseCase: GetMyNetworksUseCase(mockCommercialRepo),
      );
      controller.onInit();
    });

    test('Initial state after onInit loads packages and cursor', () {
      expect(controller.packages.length, 2);
      expect(controller.filteredPackages.length, 2);
      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, null);
      expect(controller.nextCursor.value, 'cursor_page_2');
      expect(controller.hasMore, true);
    });

    test('loadPackages populates packages list and sets cursor correctly',
        () async {
      await controller.loadPackages(networkId: 10, isRefresh: true);

      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, null);
      expect(controller.packages.length, 2);
      expect(controller.filteredPackages.length, 2);
      expect(controller.nextCursor.value, 'cursor_page_2');
    });

    test('loadMorePackages appends records and prevents duplicate package IDs',
        () async {
      await controller.loadPackages(networkId: 10, isRefresh: true);
      expect(controller.packages.length, 2);

      // Trigger load more
      await controller.loadMorePackages();
      // Since mock returns same items, deduplication prevents duplicate records
      expect(controller.packages.length, 2);
      expect(controller.isLoadingMore.value, false);
    });

    test('loadPackages handles failure and assigns errorMessage', () async {
      mockRepo.shouldThrow = true;
      controller.packages.clear();
      await controller.loadPackages(networkId: 10);

      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, isNotNull);
      expect(controller.packages.isEmpty, true);
    });

    test('setStatusFilter reloads from server and resets pagination', () async {
      controller.setStatusFilter(true);
      await controller.loadPackages();

      expect(controller.statusFilter.value, true);
      expect(controller.filteredPackages.length, 1);
      expect(controller.filteredPackages.first.packageName, 'باقة الفجر 5G');
    });

    test('Deterministic network selection auto-selects if exactly 1 network',
        () async {
      await controller.loadAuthorizedNetworks();
      expect(controller.authorizedNetworks.length, 1);
      expect(controller.formNetworkId.value, 10);

      controller.initCreateForm();
      expect(controller.formNetworkId.value, 10);
    });

    test('selectPackage loads details correctly', () async {
      controller.selectPackage(sample1);
      expect(controller.selectedPackage.value?.packageId, 1);
      expect(controller.selectedPackage.value?.packageName, 'باقة الفجر 5G');
    });

    test('togglePackageStatus updates status and reactive lists', () async {
      await controller.togglePackageStatus(sample1);
      expect(controller.packages.first.status, false);
    });

    test('deletePackage removes item from reactive lists', () async {
      final success = await controller.deletePackage(1);
      expect(success, true);
      expect(controller.packages.length, 1);
      expect(controller.packages.any((p) => p.packageId == 1), false);
    });
  });
}
