import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/features/catalog/data/models/package_model.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/features/catalog/domain/repositories/package_catalog_repository.dart';
import 'package:netsales/features/catalog/domain/usecases/create_package_use_case.dart';
import 'package:netsales/features/catalog/domain/usecases/delete_package_use_case.dart';
import 'package:netsales/features/catalog/domain/usecases/get_package_details_use_case.dart';
import 'package:netsales/features/catalog/domain/usecases/get_packages_use_case.dart';
import 'package:netsales/features/catalog/domain/usecases/toggle_package_status_use_case.dart';
import 'package:netsales/features/catalog/domain/usecases/update_package_use_case.dart';

class MockPackageCatalogRepository implements PackageCatalogRepository {
  final List<PackageEntity> _packages = [];

  MockPackageCatalogRepository(List<PackageEntity> initial) {
    _packages.addAll(initial);
  }

  @override
  Future<List<PackageEntity>> getPackages({
    int? networkId,
    bool? status,
    String? search,
    int? perPage,
  }) async {
    return _packages.where((p) {
      if (networkId != null && p.networkId != networkId) return false;
      if (status != null && p.status != status) return false;
      if (search != null && search.isNotEmpty) {
        if (!p.packageName.toLowerCase().contains(search.toLowerCase())) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  @override
  Future<List<PackageEntity>> getNetworkPackages(
    int networkId, {
    bool? status,
    String? search,
    int? perPage,
  }) async {
    return _packages.where((p) {
      if (p.networkId != networkId) return false;
      if (status != null && p.status != status) return false;
      return true;
    }).toList();
  }

  @override
  Future<PackageEntity> getPackageDetails(int packageId) async {
    final pkg = _packages.cast<PackageEntity?>().firstWhere(
      (p) => p?.packageId == packageId,
      orElse: () => null,
    );
    if (pkg == null) {
      throw const AppException(
        'الباقة غير موجودة',
        code: '404',
      );
    }
    return pkg;
  }

  @override
  Future<PackageEntity> createPackage(Map<String, dynamic> data) async {
    final pkg = PackageEntity(
      packageId: _packages.length + 1,
      networkId: data['network_id'] as int? ?? 1,
      packageName: data['package_name'] as String? ?? 'New Package',
      packageBalance: (data['package_balance'] as num?)?.toDouble() ?? 5.0,
      packageVoucherCount: data['package_voucher_count'] as int? ?? 100,
      packageVoucherPrice: (data['package_voucher_price'] as num?)?.toDouble() ?? 1000.0,
      packageDefaultCashDiscount: (data['package_default_cash_discount'] as num?)?.toDouble() ?? 5.0,
      packageDefaultCreditDiscount: (data['package_default_credit_discount'] as num?)?.toDouble() ?? 2.5,
      cashDiscountAmount: 50.0,
      creditDiscountAmount: 25.0,
      effectiveCashPrice: 950.0,
      effectiveCreditPrice: 975.0,
      status: data['status'] as bool? ?? true,
    );
    _packages.add(pkg);
    return pkg;
  }

  @override
  Future<PackageEntity> updatePackage(int packageId, Map<String, dynamic> data) async {
    final index = _packages.indexWhere((p) => p.packageId == packageId);
    if (index >= 0) {
      final existing = _packages[index];
      final price = (data['package_voucher_price'] as num?)?.toDouble() ?? existing.packageVoucherPrice;
      final updated = PackageEntity(
        packageId: existing.packageId,
        networkId: existing.networkId,
        packageName: data['package_name'] as String? ?? existing.packageName,
        packageBalance: existing.packageBalance,
        packageVoucherCount: existing.packageVoucherCount,
        packageVoucherPrice: price,
        packageDefaultCashDiscount: existing.packageDefaultCashDiscount,
        packageDefaultCreditDiscount: existing.packageDefaultCreditDiscount,
        cashDiscountAmount: existing.cashDiscountAmount,
        creditDiscountAmount: existing.creditDiscountAmount,
        effectiveCashPrice: price - existing.cashDiscountAmount,
        effectiveCreditPrice: price - existing.creditDiscountAmount,
        status: existing.status,
      );
      _packages[index] = updated;
      return updated;
    }
    throw const AppException(
      'الباقة غير موجودة',
      code: '404',
    );
  }

  @override
  Future<bool> deletePackage(int packageId) async {
    final count = _packages.length;
    _packages.removeWhere((p) => p.packageId == packageId);
    return _packages.length < count;
  }

  @override
  Future<PackageEntity> togglePackageStatus(int packageId) async {
    final index = _packages.indexWhere((p) => p.packageId == packageId);
    if (index >= 0) {
      final existing = _packages[index];
      final updated = PackageEntity(
        packageId: existing.packageId,
        networkId: existing.networkId,
        packageName: existing.packageName,
        packageBalance: existing.packageBalance,
        packageVoucherCount: existing.packageVoucherCount,
        packageVoucherPrice: existing.packageVoucherPrice,
        packageDefaultCashDiscount: existing.packageDefaultCashDiscount,
        packageDefaultCreditDiscount: existing.packageDefaultCreditDiscount,
        cashDiscountAmount: existing.cashDiscountAmount,
        creditDiscountAmount: existing.creditDiscountAmount,
        effectiveCashPrice: existing.effectiveCashPrice,
        effectiveCreditPrice: existing.effectiveCreditPrice,
        status: !existing.status,
      );
      _packages[index] = updated;
      return updated;
    }
    throw const AppException(
      'الباقة غير موجودة',
      code: '404',
    );
  }
}

void main() {
  group('Voucher Package Models and Serialization Tests', () {
    test('PackageModel fromJson deserializes full backend resource correctly', () {
      final json = {
        'package_id': 101,
        'network_id': 5,
        'package_name': 'باقة النجوم 10 جيجا',
        'package_color': '#10B981',
        'package_balance': 10.0,
        'package_uptime': 30,
        'package_validity': 30,
        'package_voucher_count': 500,
        'package_voucher_price': 1500.0,
        'package_default_cash_discount': 10.0,
        'package_default_credit_discount': 5.0,
        'cash_discount_amount': 150.0,
        'credit_discount_amount': 75.0,
        'effective_cash_price': 1350.0,
        'effective_credit_price': 1425.0,
        'status': true,
        'created_by': 1,
        'created_at': '2026-11-01 10:00:00',
        'updated_at': '2026-11-02 12:00:00',
      };

      final model = PackageModel.fromJson(json);

      expect(model.packageId, 101);
      expect(model.networkId, 5);
      expect(model.packageName, 'باقة النجوم 10 جيجا');
      expect(model.packageColor, '#10B981');
      expect(model.packageBalance, 10.0);
      expect(model.packageUptime, 30);
      expect(model.packageValidity, 30);
      expect(model.packageVoucherCount, 500);
      expect(model.packageVoucherPrice, 1500.0);
      expect(model.packageDefaultCashDiscount, 10.0);
      expect(model.packageDefaultCreditDiscount, 5.0);
      expect(model.cashDiscountAmount, 150.0);
      expect(model.creditDiscountAmount, 75.0);
      expect(model.effectiveCashPrice, 1350.0);
      expect(model.effectiveCreditPrice, 1425.0);
      expect(model.status, true);
    });

    test('PackageModel toJson serializes request payload accurately without currency', () {
      final model = PackageModel(
        packageId: 101,
        networkId: 5,
        packageName: 'باقة النجوم 10 جيجا',
        packageColor: '#10B981',
        packageBalance: 10.0,
        packageUptime: 30,
        packageValidity: 30,
        packageVoucherCount: 500,
        packageVoucherPrice: 1500.0,
        packageDefaultCashDiscount: 10.0,
        packageDefaultCreditDiscount: 5.0,
        cashDiscountAmount: 150.0,
        creditDiscountAmount: 75.0,
        effectiveCashPrice: 1350.0,
        effectiveCreditPrice: 1425.0,
        status: true,
      );

      final json = model.toJson();

      expect(json['network_id'], 5);
      expect(json['package_name'], 'باقة النجوم 10 جيجا');
      expect(json['package_voucher_price'], 1500.0);
      expect(json['package_default_cash_discount'], 10.0);
      expect(json['package_default_credit_discount'], 5.0);
      expect(json.containsKey('currency'), isFalse);
    });
  });

  group('Voucher Package Domain UseCases Tests', () {
    late MockPackageCatalogRepository mockRepo;
    late GetPackagesUseCase getPackagesUseCase;
    late GetPackageDetailsUseCase getPackageDetailsUseCase;
    late CreatePackageUseCase createPackageUseCase;
    late UpdatePackageUseCase updatePackageUseCase;
    late DeletePackageUseCase deletePackageUseCase;
    late TogglePackageStatusUseCase togglePackageStatusUseCase;

    const samplePackage = PackageEntity(
      packageId: 1,
      networkId: 10,
      packageName: 'باقة الفجر 5 جيجا',
      packageBalance: 5.0,
      packageVoucherCount: 100,
      packageVoucherPrice: 1000.0,
      packageDefaultCashDiscount: 8.0,
      packageDefaultCreditDiscount: 4.0,
      cashDiscountAmount: 80.0,
      creditDiscountAmount: 40.0,
      effectiveCashPrice: 920.0,
      effectiveCreditPrice: 960.0,
      status: true,
    );

    setUp(() {
      mockRepo = MockPackageCatalogRepository([samplePackage]);
      getPackagesUseCase = GetPackagesUseCase(mockRepo);
      getPackageDetailsUseCase = GetPackageDetailsUseCase(mockRepo);
      createPackageUseCase = CreatePackageUseCase(mockRepo);
      updatePackageUseCase = UpdatePackageUseCase(mockRepo);
      deletePackageUseCase = DeletePackageUseCase(mockRepo);
      togglePackageStatusUseCase = TogglePackageStatusUseCase(mockRepo);
    });

    test('GetPackagesUseCase returns filtered package list', () async {
      final result = await getPackagesUseCase(networkId: 10);
      expect(result.length, 1);
      expect(result.first.packageName, 'باقة الفجر 5 جيجا');
    });

    test('GetPackageDetailsUseCase returns single package details', () async {
      final result = await getPackageDetailsUseCase(1);
      expect(result.packageId, 1);
      expect(result.packageVoucherPrice, 1000.0);
    });

    test('CreatePackageUseCase appends and returns newly created package', () async {
      final data = {
        'network_id': 10,
        'package_name': 'باقة المساء 20 جيجا',
        'package_balance': 20.0,
        'package_voucher_count': 200,
        'package_voucher_price': 2500.0,
        'package_default_cash_discount': 12.0,
        'package_default_credit_discount': 6.0,
        'status': true,
      };

      final result = await createPackageUseCase(data);
      expect(result.packageId, 2);

      final list = await getPackagesUseCase(networkId: 10);
      expect(list.length, 2);
    });

    test('UpdatePackageUseCase updates package entity in repository', () async {
      final data = {
        'package_name': 'باقة الفجر المطورة',
        'package_voucher_price': 1200.0,
      };

      final result = await updatePackageUseCase(1, data);
      expect(result.packageName, 'باقة الفجر المطورة');
      expect(result.packageVoucherPrice, 1200.0);
    });

    test('TogglePackageStatusUseCase toggles active state', () async {
      final toggled = await togglePackageStatusUseCase(1);
      expect(toggled.status, false);

      final refreshed = await getPackageDetailsUseCase(1);
      expect(refreshed.status, false);
    });

    test('DeletePackageUseCase removes package from repository', () async {
      final deleted = await deletePackageUseCase(1);
      expect(deleted, true);

      final list = await getPackagesUseCase(networkId: 10);
      expect(list.isEmpty, true);
    });
  });
}
