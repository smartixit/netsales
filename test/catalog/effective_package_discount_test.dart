import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/catalog/data/models/effective_package_discount_model.dart';
import 'package:netsales/features/catalog/domain/entities/effective_package_discount_entity.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/features/catalog/domain/repositories/package_catalog_repository.dart';
import 'package:netsales/features/catalog/domain/usecases/get_effective_package_discount_use_case.dart';
import 'package:netsales/features/catalog/domain/usecases/get_packages_use_case.dart';
import 'package:netsales/features/commercial/domain/entities/pos_entity.dart';
import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_pos_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_pos_networks_list_use_case.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/features/requests/domain/repositories/request_repository.dart';
import 'package:netsales/features/requests/domain/usecases/cancel_request_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/create_request_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/get_requests_use_case.dart';
import 'package:netsales/features/requests/presentation/controllers/pos_procurement_controller.dart';

class MockRequestRepo implements RequestRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<PaginatedList<RequestEntity>> getRequests({
    int? networkId,
    int? posId,
    String? status,
    String? search,
    String? cursor,
    int? perPage,
  }) async =>
      const PaginatedList(items: [], nextCursor: null);
}

class MockCommercialRepo implements CommercialRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockPackageRepo implements PackageCatalogRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  EffectivePackageDiscountEntity? mockEffectiveDiscount;
  bool shouldThrowDiscountError = false;
  int getEffectiveDiscountCallCount = 0;

  @override
  Future<EffectivePackageDiscountEntity> getEffectiveDiscount({
    required int networkId,
    required int posId,
    required int packageId,
  }) async {
    getEffectiveDiscountCallCount++;
    if (shouldThrowDiscountError) {
      throw AppException('خطأ في استرجاع الخصم المعتمد من الخادم');
    }
    return mockEffectiveDiscount ??
        const EffectivePackageDiscountEntity(
          discountCash: 10.0,
          discountCredit: 5.0,
          isCustom: true,
          originalPackagePrice: 1000.0,
          effectiveCashPrice: 900.0,
          effectiveCreditPrice: 950.0,
          cashSavings: 100.0,
          creditSavings: 50.0,
        );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PosProcurementController controller;
  late MockPackageRepo mockPackageRepo;

  const testPackage1 = PackageEntity(
    packageId: 101,
    networkId: 10,
    packageName: 'باقة الفئة الذهبية',
    packageBalance: 1000,
    packageVoucherCount: 51,
    packageVoucherPrice: 1000,
    packageDefaultCashDiscount: 5,
    packageDefaultCreditDiscount: 2,
    cashDiscountAmount: 50,
    creditDiscountAmount: 20,
    effectiveCashPrice: 950,
    effectiveCreditPrice: 980,
    status: true,
  );

  const testPackage2 = PackageEntity(
    packageId: 102,
    networkId: 10,
    packageName: 'باقة الفئة الفضية',
    packageBalance: 500,
    packageVoucherCount: 26,
    packageVoucherPrice: 500,
    packageDefaultCashDiscount: 4,
    packageDefaultCreditDiscount: 0,
    cashDiscountAmount: 20,
    creditDiscountAmount: 0,
    effectiveCashPrice: 480,
    effectiveCreditPrice: 500,
    status: true,
  );

  setUp(() {
    Get.reset();
    mockPackageRepo = MockPackageRepo();
    controller = PosProcurementController(
      getRequestsUseCase: GetRequestsUseCase(MockRequestRepo()),
      createRequestUseCase: CreateRequestUseCase(MockRequestRepo()),
      cancelRequestUseCase: CancelRequestUseCase(MockRequestRepo()),
      getMyPosUseCase: GetMyPosUseCase(MockCommercialRepo()),
      getPosNetworksListUseCase: GetPosNetworksListUseCase(MockCommercialRepo()),
      getPackagesUseCase: GetPackagesUseCase(mockPackageRepo),
      getEffectivePackageDiscountUseCase:
          GetEffectivePackageDiscountUseCase(mockPackageRepo),
    );
  });

  tearDown(() {
    Get.reset();
  });

  group('EffectivePackageDiscountModel Serialization', () {
    test('fromJson converts server payload to domain entity correctly', () {
      final json = {
        'discount_cash': 15.5,
        'discount_credit': 8.0,
        'is_custom': true,
        'original_package_price': 1200.0,
        'effective_cash_price': 1014.0,
        'effective_credit_price': 1104.0,
        'cash_savings': 186.0,
        'credit_savings': 96.0,
      };

      final model = EffectivePackageDiscountModel.fromJson(json);

      expect(model.discountCash, equals(15.5));
      expect(model.discountCredit, equals(8.0));
      expect(model.isCustom, isTrue);
      expect(model.originalPackagePrice, equals(1200.0));
      expect(model.effectiveCashPrice, equals(1014.0));
      expect(model.effectiveCreditPrice, equals(1104.0));
      expect(model.cashSavings, equals(186.0));
      expect(model.creditSavings, equals(96.0));
    });
  });

  group('2.4 Custom POS Package Discounts Integration in PosProcurementController', () {
    test('لا يتم جلب الخصم إذا كان سياق نقطة البيع أو الشبكة غير مكتمل', () async {
      controller.onPackageSelected(testPackage1);
      await Future<void>.delayed(Duration.zero);

      expect(mockPackageRepo.getEffectiveDiscountCallCount, equals(0));
      expect(controller.effectiveDiscount.value, isNull);
    });

    test('جلب الخصم الفعلي المعتمد تلقائياً عند اكتمال السياق (نقطة البيع + الشبكة + الباقة)', () async {
      controller.selectedPosId.value = 1;
      controller.onNetworkSelected(10);

      controller.onPackageSelected(testPackage1);
      await Future<void>.delayed(Duration.zero);

      expect(mockPackageRepo.getEffectiveDiscountCallCount, equals(1));
      expect(controller.effectiveDiscount.value, isNotNull);
      expect(controller.effectiveDiscount.value!.isCustom, isTrue);
      expect(controller.effectiveDiscount.value!.effectiveCashPrice, equals(900.0));
    });

    test('إعادة جلب الخصم الفعلي عند تغيير الباقة لنفس نقطة البيع والشبكة', () async {
      controller.selectedPosId.value = 1;
      controller.onNetworkSelected(10);

      // اختيار الباقة الأولى
      controller.onPackageSelected(testPackage1);
      await Future<void>.delayed(Duration.zero);
      expect(mockPackageRepo.getEffectiveDiscountCallCount, equals(1));

      // اختيار باقة أخرى -> إعادة جلب الخصم المعتمد للباقة الجديدة فوراً
      controller.onPackageSelected(testPackage2);
      await Future<void>.delayed(Duration.zero);
      expect(mockPackageRepo.getEffectiveDiscountCallCount, equals(2));
    });

    test('تصفير الخصم المعتمد فوراً عند تغيير نقطة البيع لمنع عرض سعر قديم', () async {
      controller.selectedPosId.value = 1;
      controller.onNetworkSelected(10);
      controller.onPackageSelected(testPackage1);
      await Future<void>.delayed(Duration.zero);
      expect(controller.effectiveDiscount.value, isNotNull);

      // تغيير نقطة البيع
      controller.myPosList.assignAll([
        const PosEntity(
          posId: 1,
          posUuid: 'pos-1',
          posName: 'POS 1',
          posPhoneNumber: '777000001',
          ownerId: 10,
          status: 'ACTIVE',
        ),
        const PosEntity(
          posId: 2,
          posUuid: 'pos-2',
          posName: 'POS 2',
          posPhoneNumber: '777000002',
          ownerId: 10,
          status: 'ACTIVE',
        ),
      ]);
      await controller.onPosSelected(2);

      // يجب تصفير الخصم السابق فوراً
      expect(controller.effectiveDiscount.value, isNull);
    });

    test('عند فشل جلب الخصم من الخادم يُسجل الخطأ دون احتساب أسعار تقديرية محلية', () async {
      controller.selectedPosId.value = 1;
      controller.onNetworkSelected(10);
      mockPackageRepo.shouldThrowDiscountError = true;

      controller.onPackageSelected(testPackage1);
      await Future<void>.delayed(Duration.zero);

      expect(controller.effectiveDiscount.value, isNull);
      expect(controller.discountError.value, isNotNull);
      expect(controller.discountError.value, contains('خطأ في استرجاع الخصم'));
    });
  });
}
