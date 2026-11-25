import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/core/constants/app_permissions.dart';
import 'package:netsales/core/enums/role_scope.dart';
import 'package:netsales/core/services/permission_service.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/features/catalog/domain/usecases/get_packages_use_case.dart';
import 'package:netsales/features/requests/domain/entities/request_approval_result_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_item_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_modification_line_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_modification_preview_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_modification_preview_item_entity.dart';
import 'package:netsales/features/requests/domain/usecases/approve_request_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/get_request_details_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/get_requests_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/preview_request_modification_use_case.dart';
import 'package:netsales/features/requests/domain/usecases/reject_request_use_case.dart';
import 'package:netsales/features/requests/presentation/controllers/network_procurement_review_controller.dart';
import 'package:netsales/features/requests/presentation/widgets/network_request_modification_sheet.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';

class _FakeGetRequestsUseCase implements GetRequestsUseCase {
  @override
  Future<PaginatedList<RequestEntity>> call({
    int? networkId,
    int? posId,
    String? status,
    String? search,
    String? cursor,
    int? perPage,
  }) async => PaginatedList<RequestEntity>(items: [], nextCursor: null);
}

class _FakeApproveRequestUseCase implements ApproveRequestUseCase {
  @override
  Future<RequestApprovalResultEntity> call(
    int requestId, {
    String? requestNote,
    List<RequestModificationLineEntity>? items,
    double? paidAmount,
  }) async => throw UnimplementedError();
}

class _FakeRejectRequestUseCase implements RejectRequestUseCase {
  @override
  Future<RequestEntity> call(int requestId, String rejectionReason) async =>
      throw UnimplementedError();
}

class _FakePreviewRequestModificationUseCase
    implements PreviewRequestModificationUseCase {
  final RequestModificationPreviewEntity preview;
  _FakePreviewRequestModificationUseCase(this.preview);

  @override
  Future<RequestModificationPreviewEntity> call(
    int requestId,
    List<RequestModificationLineEntity> items,
  ) async => preview;
}

class _FakeGetPackagesUseCase implements GetPackagesUseCase {
  final List<PackageEntity> packages;
  _FakeGetPackagesUseCase(this.packages);

  @override
  Future<PaginatedList<PackageEntity>> call({
    int? networkId,
    int? posId,
    bool? status,
    String? search,
    String? cursor,
    int? perPage,
    List<int>? packageIds,
  }) async => PaginatedList<PackageEntity>(items: packages, nextCursor: null);
}

class _FakeGetRequestDetailsUseCase implements GetRequestDetailsUseCase {
  final RequestEntity detail;
  _FakeGetRequestDetailsUseCase(this.detail);

  @override
  Future<RequestEntity> call(int requestId) async => detail;
}

Widget _wrapWithScreenUtil(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(390, 844),
    minTextAdapt: true,
    builder: (context, _) => GetMaterialApp(
      home: Scaffold(body: child),
      locale: const Locale('ar'),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final mockPackage1 = PackageEntity(
    packageId: 10,
    networkId: 1,
    packageName: 'باقة الذهب 5 جيجا',
    packageColor: '#087F68',
    packageBalance: 5120,
    packageValidity: 30,
    packageUptime: 24,
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

  final mockPackage2 = PackageEntity(
    packageId: 20,
    networkId: 1,
    packageName: 'باقة الفضة 2 جيجا',
    packageColor: '#123F49',
    packageBalance: 2048,
    packageValidity: 15,
    packageUptime: 12,
    packageVoucherCount: 50,
    packageVoucherPrice: 500.0,
    packageDefaultCashDiscount: 5.0,
    packageDefaultCreditDiscount: 2.0,
    cashDiscountAmount: 25.0,
    creditDiscountAmount: 10.0,
    effectiveCashPrice: 475.0,
    effectiveCreditPrice: 490.0,
    status: true,
  );

  final mockRequest = RequestEntity(
    requestId: 42,
    requestUuid: 'REQ-2026-TEST-0042',
    networkId: 1,
    posId: 7,
    statusRaw: 'PENDING',
    statusLabel: 'قيد الانتظار',
    requestTotalAmount: 90000.0,
    requestNote: 'يرجى سرعة الاعتماد',
    saleTypeRaw: 'CASH',
    saleTypeLabel: 'نقدي',
    networkName: 'شبكة السرعة الفائقة',
    posName: 'نقطة الأمل للتجارة',
    items: [
      RequestItemEntity(
        itemId: 101,
        requestId: 42,
        packageId: 10,
        voucherCount: 100,
        voucherPrice: 1000.0,
        itemDiscount: 10.0,
        itemTotalAmount: 90000.0,
        voucherPackage: mockPackage1,
      ),
    ],
  );

  final mockPreview = RequestModificationPreviewEntity(
    requestId: 42,
    requestUuid: 'REQ-2026-TEST-0042',
    originalTotalAmount: 90000.0,
    previewTotalAmount: 113750.0,
    grossTotalAmount: 125000.0,
    totalDiscountAmount: 11250.0,
    saleType: 'CASH',
    saleTypeLabel: 'نقدي',
    hasModifications: true,
    items: [
      RequestModificationPreviewItemEntity(
        packageId: 10,
        packageName: 'باقة الذهب 5 جيجا',
        voucherCount: 100,
        originalVoucherCount: 100,
        voucherPrice: 1000.0,
        itemDiscount: 10.0,
        itemTotalAmount: 90000.0,
        grossTotalAmount: 100000.0,
        discountAmount: 10000.0,
        source: 'REQUEST_ITEM',
        changeType: 'UNCHANGED',
      ),
      RequestModificationPreviewItemEntity(
        packageId: 20,
        packageName: 'باقة الفضة 2 جيجا',
        voucherCount: 50,
        originalVoucherCount: null,
        voucherPrice: 500.0,
        itemDiscount: 5.0,
        itemTotalAmount: 23750.0,
        grossTotalAmount: 25000.0,
        discountAmount: 1250.0,
        source: 'CATALOG_PACKAGE',
        changeType: 'ITEM_ADDED',
      ),
    ],
    removedItems: [],
  );

  late NetworkProcurementReviewController controller;

  setUp(() {
    Get.reset();
    PermissionService.instance.setWorkspaceContext(
      scope: RoleScope.network,
      tenantId: 1,
      roleKey: 'NETWORK_OWNER',
      permissions: const [
        AppPermissions.requestsView,
        AppPermissions.requestsPreviewModification,
        AppPermissions.requestsApprove,
      ],
    );
    controller = NetworkProcurementReviewController(
      getRequestsUseCase: _FakeGetRequestsUseCase(),
      approveRequestUseCase: _FakeApproveRequestUseCase(),
      rejectRequestUseCase: _FakeRejectRequestUseCase(),
      previewRequestModificationUseCase: _FakePreviewRequestModificationUseCase(
        mockPreview,
      ),
      getPackagesUseCase: _FakeGetPackagesUseCase([mockPackage1, mockPackage2]),
      getRequestDetailsUseCase: _FakeGetRequestDetailsUseCase(mockRequest),
    );
    Get.put<NetworkProcurementReviewController>(controller);
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets(
    'NetworkRequestModificationSheet renders hero overview card and proposed item cards',
    (tester) async {
      await controller.beginModification(mockRequest);

      await tester.pumpWidget(
        _wrapWithScreenUtil(
          const SingleChildScrollView(child: NetworkRequestModificationSheet()),
        ),
      );
      await tester.pumpAndSettle();

      // التحقق من ظهور الرقم المرجعي وشارة نوع البيع
      expect(find.textContaining('REQ-2026-TEST'), findsOneWidget);
      expect(find.text('نقدي'), findsOneWidget);

      // التحقق من أسماء أطراف العملية
      expect(find.text('نقطة الأمل للتجارة'), findsOneWidget);
      expect(find.text('شبكة السرعة الفائقة'), findsOneWidget);

      // التحقق من ظهور الباقة المقترحة وحاسبة الأوراق
      expect(find.text('باقة الذهب 5 جيجا'), findsOneWidget);
      expect(find.text('سعة الورقة: 100 كرت'), findsOneWidget);
      expect(find.text('ورقة واحدة'), findsOneWidget);
      expect(find.text('100'), findsOneWidget);

      // التحقق من ظهور قسم كتالوج الشبكة للباقة الثانية المتاحة
      expect(find.text('إضافة باقة من كتالوج الشبكة'), findsOneWidget);
      expect(find.text('باقة الفضة 2 جيجا'), findsOneWidget);

      // التحقق من قسم المعاينة التوجيهي الأولي
      expect(
        find.text('المعاينة لا تغيّر الطلب ولا تنشئ فاتورة'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'NetworkRequestModificationSheet updates quantity on stepper click and recalculates preview',
    (tester) async {
      await controller.beginModification(mockRequest);

      await tester.pumpWidget(
        _wrapWithScreenUtil(
          const SingleChildScrollView(child: NetworkRequestModificationSheet()),
        ),
      );
      await tester.pumpAndSettle();

      // النقر على ورقة كاملة
      final addSheetButton = find.text('ورقة');
      expect(addSheetButton, findsOneWidget);
      await tester.ensureVisible(addSheetButton);
      await tester.tap(addSheetButton);
      await tester.pumpAndSettle();

      // الكمية أصبحت 200 كرت (ورقتان)
      expect(controller.modificationLines.first.voucherCount, 200);
      expect(find.text('ورقتان'), findsOneWidget);
      expect(find.text('200'), findsOneWidget);

      // طلب المعاينة
      final previewSuccess = await controller.previewModification();
      expect(previewSuccess, isTrue);
      await tester.pumpAndSettle();

      // التحقق من ظهور بطاقات المقارنة المالية الثلاث
      expect(find.text('الطلب الأصلي'), findsOneWidget);
      expect(find.text('المقترح للاعتماد'), findsOneWidget);
      expect(find.text('إجمالي الخصم'), findsOneWidget);

      // التحقق من شارة البند المضاف
      expect(find.text('باقة مضافة'), findsOneWidget);
    },
  );

  testWidgets(
    'NetworkRequestModificationSheet renders skeleton loading without dummy data when isLoadingEditor is true',
    (tester) async {
      controller.editingRequest.value = mockRequest;
      controller.modificationLines.assignAll([
        const RequestModificationLineEntity(packageId: 10, voucherCount: 100),
      ]);
      controller.isLoadingEditor.value = true;

      await tester.pumpWidget(
        _wrapWithScreenUtil(
          const SingleChildScrollView(child: NetworkRequestModificationSheet()),
        ),
      );
      await tester.pump();

      // التحقق من ظهور بطاقة أطراف العملية بهويتها الحقيقية
      expect(find.textContaining('REQ-2026-TEST'), findsOneWidget);
      // التحقق من ظهور هيكل التحميل Skeleton الموحد للباقات
      expect(find.byType(CustomStateView), findsWidgets);
      // التأكد من عدم ظهور نصوص أو بيانات وهمية أثناء التحميل
      expect(find.text('باقة #10'), findsNothing);
    },
  );

  testWidgets(
    'NetworkRequestModificationFooter transitions progressively through states',
    (tester) async {
      await controller.beginModification(mockRequest);

      await tester.pumpWidget(
        _wrapWithScreenUtil(
          const Scaffold(
            bottomNavigationBar: NetworkRequestModificationFooter(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // الحالة 1: لا توجد تعديلات بعد -> يظهر فقط زر 'إغلاق'
      expect(find.text('إغلاق'), findsOneWidget);
      expect(find.text('معاينة التعديلات'), findsNothing);
      expect(find.text('اعتماد الطلب المعدل'), findsNothing);

      // الحالة 2: إجراء تعديل بالكمية -> يظهر 'تراجع' و 'معاينة التعديلات'
      controller.setModificationQuantity(10, 150);
      await tester.pumpAndSettle();

      expect(find.text('إغلاق'), findsNothing);
      expect(find.text('تراجع'), findsOneWidget);
      expect(find.text('معاينة التعديلات'), findsOneWidget);
      expect(find.text('اعتماد الطلب المعدل'), findsNothing);

      // الحالة 3: تنفيذ المعاينة -> يظهر 'اعتماد الطلب المعدل' وتختفي المعاينة
      await controller.previewModification();
      await tester.pumpAndSettle();

      expect(find.text('معاينة التعديلات'), findsNothing);
      expect(find.text('اعتماد الطلب المعدل'), findsOneWidget);
      expect(find.text('تراجع'), findsOneWidget);

      // تعديل إضافي بعد المعاينة -> تسقط المعاينة وتعود 'معاينة التعديلات'
      controller.setModificationQuantity(10, 200);
      await tester.pumpAndSettle();

      expect(find.text('معاينة التعديلات'), findsOneWidget);
      expect(find.text('اعتماد الطلب المعدل'), findsNothing);

      // النقر على 'تراجع' -> تعود الكميات للأصل ويعود زر 'إغلاق'
      await tester.tap(find.text('تراجع'));
      await tester.pumpAndSettle();

      expect(find.text('إغلاق'), findsOneWidget);
      expect(find.text('معاينة التعديلات'), findsNothing);
      expect(find.text('اعتماد الطلب المعدل'), findsNothing);
      expect(controller.modificationLines.first.voucherCount, 100);
    },
  );
}
