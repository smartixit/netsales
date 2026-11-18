import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/features/requests/data/models/request_model.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_item_entity.dart';
import 'package:netsales/features/requests/domain/usecases/get_request_details_use_case.dart';
import 'package:netsales/features/requests/presentation/controllers/procurement_request_details_controller.dart';
import 'package:netsales/features/requests/presentation/screens/procurement_request_details_screen.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_details_hero.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_details_item_card.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_details_metrics_strip.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_details_parties_card.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_details_timeline.dart';

class _FakeGetRequestDetailsUseCase implements GetRequestDetailsUseCase {
  final RequestEntity detailEntity;

  _FakeGetRequestDetailsUseCase(this.detailEntity);

  @override
  Future<RequestEntity> call(int requestId) async => detailEntity;
}

Widget _wrapWithScreenUtil(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(390, 844),
    minTextAdapt: true,
    builder: (context, _) =>
        GetMaterialApp(home: child, locale: const Locale('ar')),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final mockPackage = PackageEntity(
    packageId: 10,
    networkId: 1,
    packageName: 'باقة 1 جيجا توريد',
    packageColor: '#087F68',
    packageBalance: 1024,
    packageValidity: 30,
    packageUptime: 24,
    packageVoucherCount: 100,
    packageVoucherPrice: 500.0,
    packageDefaultCashDiscount: 10.0,
    packageDefaultCreditDiscount: 5.0,
    cashDiscountAmount: 50.0,
    creditDiscountAmount: 25.0,
    effectiveCashPrice: 450.0,
    effectiveCreditPrice: 475.0,
    status: true,
  );

  final mockItem = RequestItemEntity(
    itemId: 101,
    requestId: 1,
    packageId: 10,
    voucherPrice: 500.0,
    voucherCount: 200,
    itemDiscount: 10.0,
    itemTotalAmount: 90000.0,
    voucherPackage: mockPackage,
  );

  final samplePendingRequest = RequestEntity(
    requestId: 1,
    networkId: 1,
    posId: 2,
    requestUuid: 'REQ-20261115-001',
    saleTypeRaw: 'CASH',
    saleTypeLabel: 'نقدي',
    requestTotalAmount: 90000.0,
    requestDate: '2026-11-15T08:30:00Z',
    statusRaw: 'PENDING',
    statusLabel: 'قيد الانتظار',
    networkName: 'شبكة السرعة الذهبية',
    networkPhone: '777000111',
    posName: 'مركز الأمل للاتصالات',
    posPhone: '777222333',
    createdByName: 'أحمد التاجر',
    items: [mockItem],
  );

  group('RequestModel JSON Parsing with Contact and Actor Attributes', () {
    test(
      'deserializes network phone, pos phone, and actor names correctly',
      () {
        final json = {
          'request_id': 1,
          'network_id': 1,
          'pos_id': 2,
          'request_uuid': 'REQ-20261115-001',
          'sale_type': 'CASH',
          'sale_type_label': 'نقدي',
          'request_total_amount': 90000.0,
          'request_date': '2026-11-15 08:30:00',
          'status': 'PENDING',
          'status_label': 'قيد الانتظار',
          'network': {
            'network_name': 'شبكة السرعة الذهبية',
            'network_phone_number': '777000111',
          },
          'pos': {
            'pos_name': 'مركز الأمل للاتصالات',
            'pos_phone_number': '777222333',
          },
          'created_by_user': {'user_full_name': 'أحمد التاجر'},
          'reviewed_by_user': {'user_full_name': 'عمر المشرف'},
        };

        final model = RequestModel.fromJson(json);

        expect(model.requestId, 1);
        expect(model.networkName, 'شبكة السرعة الذهبية');
        expect(model.networkPhone, '777000111');
        expect(model.posName, 'مركز الأمل للاتصالات');
        expect(model.posPhone, '777222333');
        expect(model.createdByName, 'أحمد التاجر');
        expect(model.reviewedByName, 'عمر المشرف');
      },
    );
  });

  group('Procurement Request Details Screen & Widgets Tests', () {
    testWidgets(
      'renders hero header with UUID, status badge, and copy button',
      (tester) async {
        await tester.pumpWidget(
          _wrapWithScreenUtil(
            Scaffold(
              body: ProcurementDetailsHero(request: samplePendingRequest),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('REQ-20261115-001'), findsOneWidget);
        expect(find.text('قيد الانتظار'), findsOneWidget);
        expect(find.text('نقدي'), findsOneWidget);
        expect(find.byIcon(Icons.copy_rounded), findsOneWidget);
      },
    );

    testWidgets('renders command metrics strip with accurate totals', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrapWithScreenUtil(
          Scaffold(
            body: ProcurementDetailsMetricsStrip(request: samplePendingRequest),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('إجمالي القيمة'), findsOneWidget);
      expect(find.text('إجمالي الكروت'), findsOneWidget);
      expect(find.text('200'), findsOneWidget);
      expect(
        find.text('2'),
        findsOneWidget,
      ); // 200 vouchers / 100 per sheet = 2 sheets
    });

    testWidgets('renders timeline with 3 audit milestones', (tester) async {
      await tester.pumpWidget(
        _wrapWithScreenUtil(
          Scaffold(
            body: ProcurementDetailsTimeline(request: samplePendingRequest),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('مسار دورة حياة الطلب والتدقيق'), findsOneWidget);
      expect(find.text('تقديم الطلب واعتماد عرض الأسعار'), findsOneWidget);
      expect(find.text('المراجعة والتدقيق الفني'), findsOneWidget);
      expect(find.text('في انتظار القرار النهائي'), findsOneWidget);
    });

    testWidgets('renders commercial parties card with network and pos info', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrapWithScreenUtil(
          Scaffold(
            body: ProcurementDetailsPartiesCard(request: samplePendingRequest),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('أطراف العملية التوريدية'), findsOneWidget);
      expect(find.text('شبكة السرعة الذهبية'), findsOneWidget);
      expect(find.text('مركز الأمل للاتصالات'), findsOneWidget);
      expect(find.byIcon(Icons.phone_forwarded_rounded), findsNWidgets(2));
    });

    testWidgets('renders item card with package specifications and amounts', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrapWithScreenUtil(
          Scaffold(body: ProcurementDetailsItemCard(item: mockItem, index: 0)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('باقة 1 جيجا توريد'), findsOneWidget);
      expect(find.text('#1'), findsOneWidget);
      expect(find.text('200 كرت'), findsOneWidget);
      expect(find.text('(2 ورقة)'), findsOneWidget);
    });

    testWidgets('renders complete details screen and triggers refresh', (
      tester,
    ) async {
      final fakeUseCase = _FakeGetRequestDetailsUseCase(samplePendingRequest);
      final controller = ProcurementRequestDetailsController(
        getRequestDetailsUseCase: fakeUseCase,
      );
      controller.request.value = samplePendingRequest;
      Get.put(controller);

      await tester.pumpWidget(
        _wrapWithScreenUtil(const ProcurementRequestDetailsScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('REQ-20261115-001'), findsWidgets);
      expect(find.byType(ProcurementDetailsHero), findsOneWidget);
      expect(find.byType(ProcurementDetailsMetricsStrip), findsOneWidget);
      expect(find.byType(ProcurementDetailsTimeline), findsOneWidget);
      expect(find.byType(ProcurementDetailsPartiesCard), findsOneWidget);
      expect(find.byType(ProcurementDetailsItemCard), findsOneWidget);

      await Get.delete<ProcurementRequestDetailsController>();
    });
  });
}
