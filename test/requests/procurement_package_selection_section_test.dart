import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/enums/sale_type.dart';
import 'package:get/get.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/core/themes/app_themes.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/features/requests/domain/repositories/request_repository.dart';
import 'package:netsales/features/requests/domain/usecases/create_request_use_case.dart';
import 'package:netsales/features/requests/presentation/controllers/pos_new_procurement_order_controller.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_package_selection_section.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_sale_type_selector.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';
import 'package:netsales/widgets/feedback/skeletons/custom_state_skeleton_view.dart';
import 'package:netsales/widgets/indicators/custom_results_counter_bar.dart';

class _FakeRequestRepository implements RequestRepository {
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

const _testPackage = PackageEntity(
  packageId: 101,
  networkId: 10,
  packageName: 'باقة الاختبار',
  packageBalance: 1000,
  packageVoucherPrice: 100,
  packageVoucherCount: 100,
  packageDefaultCashDiscount: 0,
  packageDefaultCreditDiscount: 0,
  cashDiscountAmount: 0,
  creditDiscountAmount: 0,
  effectiveCashPrice: 100,
  effectiveCreditPrice: 100,
  status: true,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PosNewProcurementOrderController controller;

  setUp(() {
    Get.reset();
    final repository = _FakeRequestRepository();
    controller = PosNewProcurementOrderController(
      createRequestUseCase: CreateRequestUseCase(repository),
    );
  });

  tearDown(Get.reset);

  Widget buildTestableWidget() {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (context, _) => MaterialApp(
        theme: AppThemes.light,
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: const ProcurementPackageSelectionSection(),
          ),
        ),
      ),
    );
  }

  void configurePackageCatalog({required bool discountLoading}) {
    controller.selectedNetworkId.value = _testPackage.networkId;
    controller.availablePackages.assignAll([_testPackage]);
    controller.isLoadingPackages.value = false;
    controller.isLoadingMorePackages.value = false;
    controller.isLoadingPackageDiscounts.value = discountLoading;
    controller.packageErrorMessage.value = null;
    controller.packageDiscountError.value = null;
  }

  Future<void> tapAndPump(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await tester.pump(const Duration(milliseconds: 250));
  }

  testWidgets(
    'يعرض عداد نتائج الباقات أسفل البحث ويتحدث مع حالة البحث',
    (tester) async {
      Get.put(controller);
      configurePackageCatalog(discountLoading: false);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      final searchField = find.byType(CustomTextField).first;
      final counter = find.byType(CustomResultsCounterBar);

      expect(counter, findsOneWidget);
      expect(
        tester.getTopLeft(counter).dy,
        greaterThan(tester.getBottomLeft(searchField).dy),
      );
      expect(find.text('1 باقة محمّلة'), findsOneWidget);
      expect(find.text('الإجمالي: '), findsOneWidget);

      controller.packageSearchQuery.value = 'الاختبار';
      await tester.pump();

      expect(find.text('نتائج البحث: '), findsOneWidget);
      expect(find.text('1 باقة محمّلة'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'تستمر أزرار الكمية في العمل مع النقرات المتتابعة لكل الإجراءات',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      Get.put(controller);
      configurePackageCatalog(discountLoading: false);
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      final addCard = find.byIcon(Icons.add_rounded);
      for (var index = 0; index < 3; index++) {
        await tapAndPump(tester, addCard);
      }
      expect(controller.cartQuantityForPackage(_testPackage.packageId), 3);

      final removeCard = find.byIcon(Icons.remove_rounded);
      for (var index = 0; index < 2; index++) {
        await tapAndPump(tester, removeCard);
      }
      expect(controller.cartQuantityForPackage(_testPackage.packageId), 1);

      expect(find.text('ورقة'), findsOneWidget);
      await tapAndPump(tester, find.text('ورقة'));
      expect(controller.cartQuantityForPackage(_testPackage.packageId), 101);

      expect(find.text('نصف'), findsOneWidget);
      await tapAndPump(tester, find.text('نصف'));
      expect(controller.cartQuantityForPackage(_testPackage.packageId), 151);

      await tapAndPump(tester, find.text('تصفير'));
      expect(controller.cartQuantityForPackage(_testPackage.packageId), 0);
    },
  );

  testWidgets(
    'تظهر هياكل نصية للخصومات ثم تختفي عند اكتمال التحميل',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      Get.put(controller);
      configurePackageCatalog(discountLoading: true);
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();

      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.byType(CustomStateSkeletonView), findsWidgets);

      controller.isLoadingPackageDiscounts.value = false;
      await tester.pump();

      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.byType(CustomStateSkeletonView), findsNothing);
    },
  );

  testWidgets(
    'يحدث محدد النقدي والآجل نفسه عند النقر وعند تغيير الحالة من المتحكم',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      Get.put(controller);
      controller.selectedSaleType.value = SaleType.cash;

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          builder: (context, _) => MaterialApp(
            theme: AppThemes.light,
            home: const Scaffold(
              body: Padding(
                padding: EdgeInsets.all(16),
                child: ProcurementSaleTypeSelector(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      Color labelColor(String label) {
        final text = tester.widget<Text>(find.text(label));
        return text.style!.color!;
      }

      final selectedColor = AppThemes.light.colorScheme.primary;
      final inactiveColor = AppThemes.light.colorScheme.onSurfaceVariant;

      expect(labelColor('نقدي'), selectedColor);
      expect(labelColor('آجل'), inactiveColor);

      await tester.tap(find.text('آجل'));
      await tester.pumpAndSettle();

      expect(controller.selectedSaleType.value, SaleType.credit);
      expect(labelColor('آجل'), selectedColor);
      expect(labelColor('نقدي'), inactiveColor);

      controller.selectedSaleType.value = SaleType.cash;
      await tester.pumpAndSettle();

      expect(labelColor('نقدي'), selectedColor);
      expect(labelColor('آجل'), inactiveColor);
    },
  );

}
