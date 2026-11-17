import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/catalog/data/models/effective_package_discount_model.dart';
import 'package:netsales/features/catalog/domain/entities/effective_package_discount_entity.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/features/catalog/domain/repositories/package_catalog_repository.dart';
import 'package:netsales/features/catalog/domain/usecases/get_effective_package_discounts_for_pos_use_case.dart';
import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_pos_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_pos_networks_list_use_case.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/features/requests/domain/repositories/request_repository.dart';
import 'package:netsales/features/requests/domain/usecases/cancel_request_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/create_request_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/get_requests_use_case.dart';
import 'package:netsales/features/requests/presentation/controllers/pos_procurement_controller.dart';

class _RequestRepository implements RequestRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _CommercialRepository implements CommercialRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _PackageRepository implements PackageCatalogRepository {
  int batchCalls = 0;
  int singleCalls = 0;

  @override
  Future<List<EffectivePackageDiscountEntity>> getEffectiveDiscountsForPos({
    required int networkId,
    required int posId,
  }) async {
    batchCalls++;
    expect(networkId, 10);
    expect(posId, 20);
    return const [
      EffectivePackageDiscountEntity(
        packageId: 101,
        discountCash: 15,
        discountCredit: 8,
        isCustom: true,
        originalPackagePrice: 1200,
        effectiveCashPrice: 1020,
        effectiveCreditPrice: 1104,
        cashSavings: 180,
        creditSavings: 96,
      ),
    ];
  }

  @override
  Future<EffectivePackageDiscountEntity> getEffectiveDiscount({
    required int networkId,
    required int posId,
    required int packageId,
  }) async {
    singleCalls++;
    throw StateError('Per-package pricing calls are obsolete in procurement.');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const package = PackageEntity(
    packageId: 101,
    networkId: 10,
    packageName: 'باقة الفئة الذهبية',
    packageBalance: 1000,
    packageVoucherCount: 50,
    packageVoucherPrice: 1200,
    packageDefaultCashDiscount: 5,
    packageDefaultCreditDiscount: 2,
    cashDiscountAmount: 60,
    creditDiscountAmount: 24,
    effectiveCashPrice: 1140,
    effectiveCreditPrice: 1176,
    status: true,
  );

  test('discount model preserves package identity and active status', () {
    final model = EffectivePackageDiscountModel.fromJson({
      'package_id': 101,
      'is_effective_now': true,
      'discount_cash': 15,
      'discount_credit': 8,
      'is_custom': true,
      'original_package_price': 1200,
      'effective_cash_price': 1020,
      'effective_credit_price': 1104,
      'cash_savings': 180,
      'credit_savings': 96,
    });

    expect(model.packageId, 101);
    expect(model.isEffectiveNow, isTrue);
    expect(model.isCustom, isTrue);
    expect(model.effectiveCashPrice, 1020);
    expect(model.effectiveCreditPrice, 1104);
  });

  test('loads all POS discounts once and indexes them by package', () async {
    Get.reset();
    final repository = _PackageRepository();
    final controller = PosProcurementController(
      getRequestsUseCase: GetRequestsUseCase(_RequestRepository()),
      createRequestUseCase: CreateRequestUseCase(_RequestRepository()),
      cancelRequestUseCase: CancelRequestUseCase(_RequestRepository()),
      getMyPosUseCase: GetMyPosUseCase(_CommercialRepository()),
      getPosNetworksListUseCase: GetPosNetworksListUseCase(_CommercialRepository()),
      getEffectivePackageDiscountsForPosUseCase:
          GetEffectivePackageDiscountsForPosUseCase(repository),
    );
    controller.selectedNetworkId.value = 10;
    controller.selectedPosId.value = 20;

    await controller.loadEffectivePackageDiscounts();

    expect(repository.batchCalls, 1);
    expect(repository.singleCalls, 0);
    expect(controller.discountForPackage(101)?.isCustom, isTrue);
    expect(controller.discountForPackage(101)?.effectiveCashPrice, 1020);
    expect(controller.discountForPackage(999), isNull);

    controller.onClose();
    Get.reset();
  });

  test('quantity edits update the cart without calling the pricing API', () {
    Get.reset();
    final repository = _PackageRepository();
    final controller = PosProcurementController(
      getRequestsUseCase: GetRequestsUseCase(_RequestRepository()),
      createRequestUseCase: CreateRequestUseCase(_RequestRepository()),
      cancelRequestUseCase: CancelRequestUseCase(_RequestRepository()),
      getEffectivePackageDiscountsForPosUseCase:
          GetEffectivePackageDiscountsForPosUseCase(repository),
    );
    controller.selectedNetworkId.value = 10;
    controller.setPackageVoucherCount(package, 75);

    expect(controller.cartQuantityForPackage(101), 75);
    expect(repository.batchCalls, 0);
    expect(repository.singleCalls, 0);

    controller.onClose();
    Get.reset();
  });
}
