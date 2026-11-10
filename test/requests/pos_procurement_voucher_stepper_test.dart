import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_pos_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_pos_networks_list_use_case.dart';
import 'package:netsales/features/catalog/domain/repositories/package_catalog_repository.dart';
import 'package:netsales/features/catalog/domain/usecases/get_packages_use_case.dart';
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
  }) async {
    return const PaginatedList(items: [], nextCursor: null);
  }
}

class MockCommercialRepo implements CommercialRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockPackageRepo implements PackageCatalogRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PosProcurementController controller;
  const testPackage = PackageEntity(
    packageId: 10,
    networkId: 1,
    packageName: 'باقة 51 كرت',
    packageBalance: 1000,
    packageVoucherCount: 51,
    packageVoucherPrice: 100,
    packageDefaultCashDiscount: 0,
    packageDefaultCreditDiscount: 0,
    cashDiscountAmount: 0,
    creditDiscountAmount: 0,
    effectiveCashPrice: 100,
    effectiveCreditPrice: 100,
    status: true,
  );

  setUp(() {
    Get.reset();
    controller = PosProcurementController(
      getRequestsUseCase: GetRequestsUseCase(MockRequestRepo()),
      createRequestUseCase: CreateRequestUseCase(MockRequestRepo()),
      cancelRequestUseCase: CancelRequestUseCase(MockRequestRepo()),
      getMyPosUseCase: GetMyPosUseCase(MockCommercialRepo()),
      getPosNetworksListUseCase: GetPosNetworksListUseCase(MockCommercialRepo()),
      getPackagesUseCase: GetPackagesUseCase(MockPackageRepo()),
    );
    controller.onPackageSelected(testPackage);
  });

  tearDown(() {
    Get.reset();
  });

  group('PosProcurementController Voucher Quantity Stepper & Additive Logic', () {
    test('اختيار الباقة يعين افتراضياً سعة ورقة واحدة إذا كان الحقل فارغاً', () {
      expect(controller.requestedVoucherCount, equals(51));
      expect(controller.quantityController.text, equals('51'));
    });

    test('الإدخال التراكمي addVoucherQuantity يجمع الكروت المتكررة بدقة', () {
      controller.clearVoucherQuantity();
      expect(controller.requestedVoucherCount, equals(0));

      // نقرة أولى على +51
      controller.addVoucherQuantity(51);
      expect(controller.requestedVoucherCount, equals(51));
      expect(controller.quantityController.text, equals('51'));

      // نقرة ثانية على +51 (تراكمي)
      controller.addVoucherQuantity(51);
      expect(controller.requestedVoucherCount, equals(102));
      expect(controller.quantityController.text, equals('102'));

      // نقرة ثالثة على كبسولة نصف ورقة +26
      controller.addVoucherQuantity(26);
      expect(controller.requestedVoucherCount, equals(128));
      expect(controller.quantityController.text, equals('128'));
    });

    test('زر زيادة ورقة stepUpSheet يضيف سعة ورقة الباقة المحددة (51 كرت)', () {
      controller.clearVoucherQuantity();

      controller.stepUpSheet();
      expect(controller.requestedVoucherCount, equals(51));

      controller.stepUpSheet();
      expect(controller.requestedVoucherCount, equals(102));
    });

    test('زر إنقاص ورقة stepDownSheet يطرح سعة ورقة ولا ينزل أبداً تحت الصفر (Zero Clamp)', () {
      // نبدأ بـ 102 كرت (ورقتان)
      controller.setVoucherCount(102);

      // إنقاص ورقة -> 51
      controller.stepDownSheet();
      expect(controller.requestedVoucherCount, equals(51));

      // إنقاص ورقة -> 0
      controller.stepDownSheet();
      expect(controller.requestedVoucherCount, equals(0));
      expect(controller.quantityController.text, equals(''));

      // إنقاص ورقة إضافية والقيمة صفر -> يظل صفراً ولا يصبح سالباً أبداً
      controller.stepDownSheet();
      expect(controller.requestedVoucherCount, equals(0));
      expect(controller.quantityController.text, equals(''));
    });

    test('زر إنقاص ورقة stepDownSheet مع قيمة أقل من ورقة ينزل إلى صفر ولا يذهب للسالب', () {
      // نصف ورقة 26 كرت
      controller.setVoucherCount(26);

      // إنقاص ورقة كاملة (51 كرت) من 26 -> ينزل للصفر بحماية تامة
      controller.stepDownSheet();
      expect(controller.requestedVoucherCount, equals(0));
    });

    test('زر مسح الكمية clearVoucherQuantity يصفر الحقل فوراً', () {
      controller.setVoucherCount(500);
      expect(controller.requestedVoucherCount, equals(500));

      controller.clearVoucherQuantity();
      expect(controller.requestedVoucherCount, equals(0));
      expect(controller.quantityController.text, equals(''));
    });

    test('التحقق من صحة الإدخال validateVoucherQuantity يمنع القيم الفارغة أو الصفرية أو السالبة', () {
      expect(controller.validateVoucherQuantity(''), isNotNull);
      expect(controller.validateVoucherQuantity('0'), isNotNull);
      expect(controller.validateVoucherQuantity('-5'), isNotNull);
      expect(controller.validateVoucherQuantity('abc'), isNotNull);
      expect(controller.validateVoucherQuantity('51'), isNull);
      expect(controller.validateVoucherQuantity('100'), isNull);
    });
  });
}
