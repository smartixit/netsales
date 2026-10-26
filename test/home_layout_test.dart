// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:get/get.dart';
// import 'package:netsales/core/constants/app_permissions.dart';
// import 'package:netsales/core/models/role_model.dart';
// import 'package:netsales/core/models/user_model.dart';
// import 'package:netsales/core/models/user_session_model.dart';
// import 'package:netsales/core/services/permission_service.dart';
// import 'package:netsales/core/services/session_service.dart';
// import 'package:netsales/core/services/storage_service.dart';
// import 'package:netsales/core/services/theme_service.dart';
// import 'package:netsales/core/themes/app_themes.dart';
// import 'package:netsales/features/home/domain/entities/dashboard_overview_entity.dart';
// import 'package:netsales/features/home/domain/repositories/dashboard_repository.dart';
// import 'package:netsales/features/home/domain/usecases/get_dashboard_overview_use_case.dart';
// import 'package:netsales/features/home/presentation/controllers/dashboard_controller.dart';
// import 'package:netsales/features/home/presentation/controllers/home_layout_controller.dart';
// import 'package:netsales/features/home/presentation/models/home_quick_action.dart';
// import 'package:netsales/features/home/presentation/screens/home_layout_screen.dart';
// import 'package:netsales/features/home/presentation/widgets/home_quick_actions_sheet.dart';
// import 'package:netsales/features/operations/domain/entities/sale_invoice_entity.dart';
// import 'package:netsales/features/operations/domain/entities/voucher_request_entity.dart';
// import 'package:netsales/features/operations/domain/repositories/operations_repository.dart';
// import 'package:netsales/features/operations/domain/usecases/approve_voucher_request_use_case.dart';
// import 'package:netsales/features/operations/domain/usecases/cancel_voucher_request_use_case.dart';
// import 'package:netsales/features/operations/domain/usecases/get_sale_invoice_details_use_case.dart';
// import 'package:netsales/features/operations/domain/usecases/get_sale_invoices_use_case.dart';
// import 'package:netsales/features/operations/domain/usecases/get_voucher_request_details_use_case.dart';
// import 'package:netsales/features/operations/domain/usecases/get_voucher_requests_use_case.dart';
// import 'package:netsales/features/operations/domain/usecases/reject_voucher_request_use_case.dart';
// import 'package:netsales/features/operations/presentation/controllers/operations_controller.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class FakeDashboardRepository implements DashboardRepository {
//   @override
//   Future<DashboardOverviewEntity> getOverview({
//     String period = 'today',
//     int? networkId,
//     int? posId,
//     bool refresh = false,
//   }) async {
//     return const DashboardOverviewEntity(
//       roleKey: 'NETWORK_OWNER',
//       roleLabel: 'لوحة قيادة المزود',
//       period: 'today',
//       context: DashboardContextEntity(
//         networkId: 1,
//         networkName: 'شبكة النورس الحديثة',
//         networkCode: 'NET-001',
//       ),
//       liquidity: DashboardLiquidityEntity(
//         balance: 150000.0,
//         currency: 'YER',
//         status: 'ACTIVE',
//       ),
//       kpis: {
//         'total_sales_amount': 25000.0,
//         'invoices_count': 12,
//         'total_cards_sold': 50,
//       },
//       alerts: [],
//       recentActivities: [],
//       telemetry: DashboardTelemetryEntity(
//         syncedAt: '2026-10-22 20:00:00',
//         serverTime: '20:00:00',
//       ),
//     );
//   }
// }

// class FakeOperationsRepository implements OperationsRepository {
//   @override
//   Future<List<SaleInvoiceEntity>> getSaleInvoices({
//     int? networkId,
//     int? posId,
//     String? saleType,
//     String? search,
//     int perPage = 20,
//     int page = 1,
//   }) async => [];

//   @override
//   Future<SaleInvoiceEntity> getSaleInvoiceDetails(int id) =>
//       throw UnimplementedError();

//   @override
//   Future<List<VoucherRequestEntity>> getVoucherRequests({
//     int? networkId,
//     int? posId,
//     String? status,
//     String? search,
//     int perPage = 20,
//     int page = 1,
//   }) async => [];

//   @override
//   Future<VoucherRequestEntity> getVoucherRequestDetails(int id) =>
//       throw UnimplementedError();

//   @override
//   Future<VoucherRequestEntity> approveVoucherRequest(int id, {String? notes}) =>
//       throw UnimplementedError();

//   @override
//   Future<VoucherRequestEntity> rejectVoucherRequest(int id, {required String reason}) =>
//       throw UnimplementedError();

//   @override
//   Future<VoucherRequestEntity> cancelVoucherRequest(int id, {String? reason}) =>
//       throw UnimplementedError();
// }

// void main() {
//   TestWidgetsFlutterBinding.ensureInitialized();

//   setUp(() async {
//     Get.reset();
//     SharedPreferences.setMockInitialValues({});
//     await StorageService.instance.init();
//     Get.put<StorageService>(StorageService.instance, permanent: true);
//     await ThemeService.instance.init();
//     Get.put<ThemeService>(ThemeService.instance, permanent: true);
//     Get.put<PermissionService>(PermissionService.instance, permanent: true);
//     await SessionService.instance.init();
//     Get.put<SessionService>(SessionService.instance, permanent: true);

//     final fakeDashboardRepo = FakeDashboardRepository();
//     final getDashboardOverviewUseCase =
//         GetDashboardOverviewUseCase(fakeDashboardRepo);
//     final dashboardController = DashboardController(
//       getDashboardOverviewUseCase: getDashboardOverviewUseCase,
//     );
//     await dashboardController.loadDashboard();
//     Get.put<DashboardController>(dashboardController);

//     final fakeOpsRepo = FakeOperationsRepository();
//     final opsController = OperationsController(
//       getSaleInvoicesUseCase: GetSaleInvoicesUseCase(fakeOpsRepo),
//       getVoucherRequestsUseCase: GetVoucherRequestsUseCase(fakeOpsRepo),
//       getSaleInvoiceDetailsUseCase: GetSaleInvoiceDetailsUseCase(fakeOpsRepo),
//       getVoucherRequestDetailsUseCase:
//           GetVoucherRequestDetailsUseCase(fakeOpsRepo),
//       approveVoucherRequestUseCase: ApproveVoucherRequestUseCase(fakeOpsRepo),
//       rejectVoucherRequestUseCase: RejectVoucherRequestUseCase(fakeOpsRepo),
//       cancelVoucherRequestUseCase: CancelVoucherRequestUseCase(fakeOpsRepo),
//     );
//     await opsController.loadInvoices();
//     await opsController.loadRequests();
//     Get.put<OperationsController>(opsController);
//   });

//   Widget buildTestableWidget(Widget child) {
//     return ScreenUtilInit(
//       designSize: const Size(375, 812),
//       minTextAdapt: true,
//       builder: (context, _) => GetMaterialApp(
//         theme: AppThemes.light,
//         home: child,
//       ),
//     );
//   }

//   void setupPhoneScreen(WidgetTester tester) {
//     tester.view.physicalSize = const Size(1125, 2436);
//     tester.view.devicePixelRatio = 3.0;
//     addTearDown(tester.view.resetPhysicalSize);
//     addTearDown(tester.view.resetDevicePixelRatio);
//   }

//   group('HomeQuickAction Model Tests', () {
//     test('instantiates cleanly with all fields', () {
//       const action = HomeQuickAction(
//         id: 'test_action',
//         title: 'إجراء تجريبي',
//         description: 'وصف الإجراء',
//         icon: Icons.star,
//         requiredPermission: 'test.permission',
//         targetRoute: '/test-route',
//       );

//       expect(action.id, 'test_action');
//       expect(action.title, 'إجراء تجريبي');
//       expect(action.description, 'وصف الإجراء');
//       expect(action.icon, Icons.star);
//       expect(action.requiredPermission, 'test.permission');
//       expect(action.targetRoute, '/test-route');
//     });
//   });

//   group('HomeLayoutController Business Logic Tests', () {
//     test('initial tab index is 0 and changeTab updates correctly', () {
//       final controller = HomeLayoutController();
//       Get.put(controller);

//       expect(controller.selectedIndex.value, 0);

//       controller.changeTab(2);
//       expect(controller.selectedIndex.value, 2);

//       // اختبار تجاهل المؤشرات الخارجة عن النطاق
//       controller.changeTab(-1);
//       expect(controller.selectedIndex.value, 2);
//       controller.changeTab(99);
//       expect(controller.selectedIndex.value, 2);
//     });

//     test('permission-driven quick actions filter dynamically based on permissions', () {
//       final permissionService = PermissionService.to;
//       final controller = HomeLayoutController();
//       Get.put(controller);

//       // في البداية: لا توجد صلاحيات
//       permissionService.updateAccess(roleKey: 'TEST_USER', permissions: []);
//       expect(controller.availableQuickActions.isEmpty, isTrue);
//       expect(controller.hasQuickActions, isFalse);

//       // منح صلاحية إنشاء مبيعات فقط (sales.create)
//       permissionService.updateAccess(
//         roleKey: 'POS_AGENT',
//         permissions: [AppPermissions.salesCreate],
//       );
//       expect(controller.availableQuickActions.length, 1);
//       expect(controller.isSingleAction, isTrue);
//       expect(controller.primaryQuickAction?.id, 'create_sale_invoice');

//       // منح صلاحيتين (sales.create و requests.create)
//       permissionService.updateAccess(
//         roleKey: 'POS_AGENT',
//         permissions: [AppPermissions.salesCreate, AppPermissions.requestsCreate],
//       );
//       expect(controller.availableQuickActions.length, 2);
//       expect(controller.isSingleAction, isFalse);

//       // ترقية المستخدم إلى المشرف العام (SUPER_ADMIN) -> كافة إجراءات الكتالوج متاحة
//       permissionService.updateAccess(
//         roleKey: AppRoles.superAdmin,
//         permissions: [],
//       );
//       expect(controller.availableQuickActions.length, 6);
//       expect(controller.hasQuickActions, isTrue);
//     });

//     test('canPopTab resets tab index to 0 before allowing pop', () {
//       final controller = HomeLayoutController();
//       Get.put(controller);

//       // عندما يكون في تبويب غير 0 (مثلاً 2)، يجب أن يعيد المستخدم للتبويب 0 ويرجع false
//       controller.changeTab(2);
//       final canPopFromTab2 = controller.canPopTab();
//       expect(canPopFromTab2, isFalse);
//       expect(controller.selectedIndex.value, 0);

//       // عندما يكون بالفعل في التبويب 0، يرجع true ليتولى DoubleBackExitScope الخروج
//       final canPopFromTab0 = controller.canPopTab();
//       expect(canPopFromTab0, isTrue);
//     });
//   });

//   group('HomeLayoutScreen & Widget Integration Tests', () {
//     testWidgets('renders HomeLayoutScreen with AppBar, Tabs, and FloatingNavBar', (
//       tester,
//     ) async {
//       setupPhoneScreen(tester);

//       // تهيئة مستخدم نشط في الجلسة مع الصلاحيات المصاحبة
//       await SessionService.to.startSession(
//         user: const UserModel(
//           userId: 1,
//           userFullName: 'أحمد صالح اليماني',
//           userPhoneNumber: '777123456',
//           status: 'ACTIVE',
//           role: RoleModel(
//             roleId: 2,
//             roleName: 'مزود شبكة معتمد',
//             roleKey: AppRoles.networkOwner,
//           ),
//         ),
//         session: const UserSessionModel(
//           sessionId: 'session_123',
//           userId: 1,
//           deviceUuid: 'device_123',
//         ),
//         permissions: [
//           AppPermissions.salesCreate,
//           AppPermissions.requestsApprove,
//           AppPermissions.voucherPackagesCreate,
//         ],
//       );

//       final controller = HomeLayoutController();
//       Get.put(controller);

//       await tester.pumpWidget(
//         buildTestableWidget(
//           const HomeLayoutScreen(),
//         ),
//       );
//       await tester.pump();
//       await tester.pump(const Duration(milliseconds: 300));

//       // التحقق من ظهور ترويسة التطبيق واسم المستخدم المختصر ودوره
//       expect(find.text('أحمد صالح'), findsOneWidget);
//       expect(find.text('مزود شبكة معتمد'), findsOneWidget);

//       // التحقق من ظهور تسميات التبويبات الأربعة
//       expect(find.text('الرئيسية'), findsOneWidget);
//       expect(find.text('العمليات'), findsOneWidget);
//       expect(find.text('الشركاء'), findsOneWidget);
//       expect(find.text('المزيد'), findsOneWidget);

//       // النقر على تبويب العمليات وتغيير الصفحة
//       await tester.tap(find.text('العمليات'));
//       await tester.pump();
//       await tester.pump(const Duration(milliseconds: 300));
//       expect(controller.selectedIndex.value, 1);
//     });

//     testWidgets('center FAB opens HomeQuickActionsSheet when user has multiple permissions', (
//       tester,
//     ) async {
//       setupPhoneScreen(tester);

//       PermissionService.to.updateAccess(
//         roleKey: AppRoles.networkOwner,
//         permissions: [
//           AppPermissions.salesCreate,
//           AppPermissions.requestsApprove,
//         ],
//       );

//       final controller = HomeLayoutController();
//       Get.put(controller);

//       await tester.pumpWidget(
//         buildTestableWidget(
//           const HomeLayoutScreen(),
//         ),
//       );
//       await tester.pump();
//       await tester.pump(const Duration(milliseconds: 300));

//       // النقر على الزر المركزي العائم
//       await tester.tap(find.byKey(const ValueKey('nav_center_fab')));
//       await tester.pump();
//       await tester.pump(const Duration(milliseconds: 300));

//       // التحقق من فتح نافذة الإجراءات السريعة
//       expect(find.byType(HomeQuickActionsSheet), findsOneWidget);
//       expect(find.text('الإجراءات السريعة المباشرة'), findsOneWidget);
//       expect(find.text('إصدار فاتورة مبيعات'), findsOneWidget);
//       expect(find.text('اعتماد طلبات الكروت'), findsOneWidget);
//     });
//   });
// }
