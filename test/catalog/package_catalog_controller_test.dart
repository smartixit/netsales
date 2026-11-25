import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/core/utils/package_spec_formatter.dart';
import 'package:netsales/features/catalog/domain/entities/create_package_input.dart';
import 'package:netsales/features/catalog/domain/entities/effective_package_discount_entity.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/features/catalog/domain/entities/update_package_input.dart';
import 'package:netsales/features/catalog/domain/repositories/package_catalog_repository.dart';
import 'package:netsales/features/catalog/domain/usecases/create_package_use_case.dart';
import 'package:netsales/features/catalog/domain/usecases/delete_package_use_case.dart';
import 'package:netsales/features/catalog/domain/usecases/get_packages_use_case.dart';
import 'package:netsales/features/catalog/domain/usecases/toggle_package_status_use_case.dart';
import 'package:netsales/features/catalog/domain/usecases/update_package_use_case.dart';
import 'package:netsales/features/catalog/presentation/controllers/package_catalog_controller.dart';
import 'package:netsales/features/catalog/presentation/controllers/package_form_controller.dart';
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
    int? posId,
    bool? status,
    String? search,
    String? cursor,
    int? perPage,
    List<int>? packageIds,
  }) async {
    if (shouldThrow) {
      throw const AppException('فشل الاتصال بالخادم', code: '500');
    }

    final filtered = items.where((p) {
      if (networkId != null && p.networkId != networkId) return false;
      if (status != null && p.status != status) return false;
      if (packageIds != null && !packageIds.contains(p.packageId)) return false;
      if (search != null && search.isNotEmpty) {
        if (!p.packageName.toLowerCase().contains(search.toLowerCase())) {
          return false;
        }
      }
      return true;
    }).toList();

    return PaginatedList<PackageEntity>(
      items: filtered,
      nextCursor: cursor == null && filtered.isNotEmpty
          ? 'cursor_page_2'
          : null,
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
      nextCursor: cursor == null && filtered.isNotEmpty
          ? 'cursor_page_2'
          : null,
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
  Future<PackageEntity> createPackage(CreatePackageInput input) async {
    final pkg = PackageEntity(
      packageId: items.length + 1,
      networkId: input.networkId,
      packageName: input.packageName,
      packageBalance: input.packageBalance,
      packageVoucherCount: input.packageVoucherCount,
      packageVoucherPrice: input.packageVoucherPrice,
      packageDefaultCashDiscount: input.packageDefaultCashDiscount,
      packageDefaultCreditDiscount: input.packageDefaultCreditDiscount,
      cashDiscountAmount: 50.0,
      creditDiscountAmount: 25.0,
      effectiveCashPrice: 950.0,
      effectiveCreditPrice: 975.0,
      status: input.status,
    );
    items.add(pkg);
    return pkg;
  }

  @override
  Future<PackageEntity> updatePackage(
    int packageId,
    UpdatePackageInput input,
  ) async {
    final index = items.indexWhere((p) => p.packageId == packageId);
    if (index >= 0) {
      final updated = PackageEntity(
        packageId: packageId,
        networkId: items[index].networkId,
        packageName: input.packageName ?? items[index].packageName,
        packageBalance: input.packageBalance ?? items[index].packageBalance,
        packageVoucherCount:
            input.packageVoucherCount ?? items[index].packageVoucherCount,
        packageVoucherPrice:
            input.packageVoucherPrice ?? items[index].packageVoucherPrice,
        packageDefaultCashDiscount:
            input.packageDefaultCashDiscount ??
            items[index].packageDefaultCashDiscount,
        packageDefaultCreditDiscount:
            input.packageDefaultCreditDiscount ??
            items[index].packageDefaultCreditDiscount,
        cashDiscountAmount: items[index].cashDiscountAmount,
        creditDiscountAmount: items[index].creditDiscountAmount,
        effectiveCashPrice: items[index].effectiveCashPrice,
        effectiveCreditPrice: items[index].effectiveCreditPrice,
        status: input.status ?? items[index].status,
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

  @override
  Future<List<EffectivePackageDiscountEntity>> getEffectiveDiscountsForPos({
    required int networkId,
    required int posId,
  }) async => const [];

  @override
  Future<EffectivePackageDiscountEntity> getEffectiveDiscount({
    required int networkId,
    required int posId,
    required int packageId,
  }) {
    throw UnimplementedError();
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
      packageBalance: 1024,
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
      packageBalance: 1024,
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
        togglePackageStatusUseCase: TogglePackageStatusUseCase(mockRepo),
        deletePackageUseCase: DeletePackageUseCase(mockRepo),
        getMyNetworksUseCase: GetMyNetworksUseCase(mockCommercialRepo),
      );
    });

    test(
      'Initial state after fetchPackages loads packages and sets cursor',
      () async {
        await controller.fetchPackages(refresh: true);

        expect(controller.packages.length, 2);
        expect(controller.isLoading.value, false);
        expect(controller.errorMessage.value, null);
        expect(controller.nextCursor.value, 'cursor_page_2');
        expect(controller.hasMore, true);
      },
    );

    test('loadMorePackages appends records and retains cursor state', () async {
      await controller.fetchPackages(refresh: true);
      expect(controller.packages.length, 2);

      // Trigger load more
      await controller.loadMorePackages();
      expect(controller.packages.length, 4);
      expect(controller.isLoadingMore.value, false);
    });

    test('fetchPackages handles failure and assigns errorMessage', () async {
      mockRepo.shouldThrow = true;
      controller.packages.clear();
      await controller.fetchPackages(refresh: true);

      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, isNotNull);
      expect(controller.packages.isEmpty, true);
    });

    test('onFilterKeySelected updates filter and refreshes packages', () async {
      controller.onFilterKeySelected('active');
      expect(controller.statusFilter.value, true);
      expect(controller.currentFilterKey, 'active');

      controller.onFilterKeySelected('inactive');
      expect(controller.statusFilter.value, false);
      expect(controller.currentFilterKey, 'inactive');

      controller.onFilterKeySelected('all');
      expect(controller.statusFilter.value, null);
      expect(controller.currentFilterKey, null);
    });

    test('toggleExpanded toggles expanded package id', () {
      expect(controller.expandedPackageId.value, null);

      controller.toggleExpanded(1);
      expect(controller.expandedPackageId.value, 1);

      controller.toggleExpanded(1);
      expect(controller.expandedPackageId.value, null);
    });

    test(
      'togglePackageStatus updates status in reactive packages list',
      () async {
        await controller.fetchPackages(refresh: true);
        expect(controller.packages.first.status, true);

        await controller.togglePackageStatus(controller.packages.first);
        expect(controller.packages.first.status, false);
      },
    );

    test('deletePackage removes item from reactive packages list', () async {
      await controller.fetchPackages(refresh: true);
      expect(controller.packages.length, 2);

      await controller.deletePackage(controller.packages.first);
      expect(controller.packages.length, 1);
      expect(controller.packages.any((p) => p.packageId == 1), false);
    });
  });

  group('PackageFormController Unit Conversion Tests', () {
    late MockCatalogRepository mockRepo;
    late PackageFormController formController;

    setUp(() {
      mockRepo = MockCatalogRepository([]);
      formController = PackageFormController(
        createPackageUseCase: CreatePackageUseCase(mockRepo),
        updatePackageUseCase: UpdatePackageUseCase(mockRepo),
      );
    });

    test('unit changes preserve the entered quantities without conversion', () {
      formController.selectedBalanceUnit.value = DataSizeUnit.gigabytes;
      formController.balanceController.text = '1.5';
      formController.setBalanceUnit(DataSizeUnit.megabytes);
      expect(formController.selectedBalanceUnit.value, DataSizeUnit.megabytes);
      expect(formController.balanceController.text, '1.5');
      expect(formController.liveBalanceInBytes.value, 1572864);

      formController.selectedUptimeUnit.value = TimeDurationUnit.hours;
      formController.uptimeController.text = '2.5';
      formController.setUptimeUnit(TimeDurationUnit.minutes);
      expect(formController.selectedUptimeUnit.value, TimeDurationUnit.minutes);
      expect(formController.uptimeController.text, '2.5');
      expect(formController.liveUptimeInMinutes.value, 3);

      formController.selectedValidityUnit.value = TimeDurationUnit.months;
      formController.validityController.text = '1.5';
      formController.setValidityUnit(TimeDurationUnit.days);
      expect(formController.selectedValidityUnit.value, TimeDurationUnit.days);
      expect(formController.validityController.text, '1.5');
      expect(formController.liveValidityInMinutes.value, 2160);
    });

    test('empty optional durations remain empty when their units change', () {
      formController.uptimeController.clear();
      formController.validityController.clear();

      formController.setUptimeUnit(TimeDurationUnit.days);
      formController.setValidityUnit(TimeDurationUnit.years);

      expect(formController.uptimeController.text, isEmpty);
      expect(formController.validityController.text, isEmpty);
      expect(formController.selectedUptimeUnit.value, TimeDurationUnit.days);
      expect(formController.selectedValidityUnit.value, TimeDurationUnit.years);
    });

    test('zero values remain zero when units change', () {
      formController.balanceController.text = '0';
      formController.uptimeController.text = '0';
      formController.validityController.text = '0';

      formController.setBalanceUnit(DataSizeUnit.bytes);
      formController.setUptimeUnit(TimeDurationUnit.minutes);
      formController.setValidityUnit(TimeDurationUnit.months);

      expect(formController.balanceController.text, '0');
      expect(formController.uptimeController.text, '0');
      expect(formController.validityController.text, '0');
    });

    test('new package preview starts with the canonical default color', () {
      expect(
        PackageFormController.defaultPackageColor,
        '0xFF0D7A5F',
      );
      expect(
        formController.livePreviewPackage.packageColor,
        PackageFormController.defaultPackageColor,
      );
    });

    test('live preview retains the selected package color', () {
      formController.selectedColor.value = '0xFF0D7A5F';

      expect(formController.livePreviewPackage.packageColor, '0xFF0D7A5F');
    });

    test('live pricing preview follows server two-decimal rounding', () {
      formController.liveBasePrice.value = 100.555;
      formController.liveCashDiscountRate.value = 12.345;
      formController.liveCreditDiscountRate.value = 5.0;

      final preview = formController.livePreviewPackage;

      expect(preview.packageVoucherPrice, 100.56);
      expect(preview.cashDiscountAmount, 12.42);
      expect(preview.effectiveCashPrice, 88.14);
      expect(preview.creditDiscountAmount, 5.03);
      expect(preview.effectiveCreditPrice, 95.53);
    });

    test('invalid negative values are not converted or overwritten', () {
      formController.balanceController.text = '-2';
      formController.uptimeController.text = '-3';
      formController.validityController.text = '-4';

      formController.setBalanceUnit(DataSizeUnit.megabytes);
      formController.setUptimeUnit(TimeDurationUnit.days);
      formController.setValidityUnit(TimeDurationUnit.weeks);

      expect(formController.balanceController.text, '-2');
      expect(formController.uptimeController.text, '-3');
      expect(formController.validityController.text, '-4');
    });
  });
}
