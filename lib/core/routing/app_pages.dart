import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_permissions.dart';
import 'package:netsales/core/routing/middlewares/auth_guard.dart';
import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/routing/middlewares/workspace_guard.dart';
import 'package:netsales/features/auth/presentation/bindings/active_sessions_binding.dart';
import 'package:netsales/features/auth/presentation/bindings/forgot_password_binding.dart';
import 'package:netsales/features/auth/presentation/bindings/login_binding.dart';
import 'package:netsales/features/auth/presentation/bindings/register_network_binding.dart';
import 'package:netsales/features/auth/presentation/bindings/register_pos_binding.dart';
import 'package:netsales/features/auth/presentation/bindings/reset_password_binding.dart';
import 'package:netsales/features/auth/presentation/bindings/two_factor_auth_binding.dart';
import 'package:netsales/features/auth/presentation/bindings/verify_otp_binding.dart';
import 'package:netsales/features/auth/presentation/screens/active_sessions_screen.dart';
import 'package:netsales/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:netsales/features/auth/presentation/screens/login_screen.dart';
import 'package:netsales/features/auth/presentation/screens/register_network_screen.dart';
import 'package:netsales/features/auth/presentation/screens/register_pos_screen.dart';
import 'package:netsales/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:netsales/features/auth/presentation/screens/two_factor_auth_screen.dart';
import 'package:netsales/features/auth/presentation/screens/verify_otp_screen.dart';
import 'package:netsales/features/catalog/presentation/bindings/package_catalog_binding.dart';
import 'package:netsales/features/catalog/presentation/screens/package_catalog_screen.dart';
import 'package:netsales/features/catalog/presentation/screens/package_details_screen.dart';
import 'package:netsales/features/catalog/presentation/screens/package_form_screen.dart';
import 'package:netsales/features/requests/presentation/bindings/procurement_request_binding.dart';
import 'package:netsales/features/requests/presentation/screens/network_supply_requests_review_screen.dart';
import 'package:netsales/features/requests/presentation/screens/pos_new_procurement_order_screen.dart';
import 'package:netsales/features/requests/presentation/screens/pos_procurement_orders_screen.dart';
import 'package:netsales/features/requests/presentation/screens/procurement_request_details_screen.dart';
import 'package:netsales/features/commercial/presentation/bindings/commercial_binding.dart';
import 'package:netsales/features/commercial/presentation/screens/network_pos_directory_screen.dart';
import 'package:netsales/features/commercial/presentation/screens/pos_linked_networks_screen.dart';
import 'package:netsales/features/invoices/presentation/bindings/invoice_binding.dart';
import 'package:netsales/features/invoices/presentation/screens/invoice_details_screen.dart';
import 'package:netsales/features/invoices/presentation/screens/network_wholesale_invoices_screen.dart';
import 'package:netsales/features/invoices/presentation/screens/network_direct_invoice_screen.dart';
import 'package:netsales/features/invoices/presentation/screens/pos_purchase_invoices_screen.dart';
import 'package:netsales/features/expenses/presentation/bindings/network_operating_expenses_binding.dart';
import 'package:netsales/features/expenses/presentation/screens/network_operating_expenses_screens.dart';
import 'package:netsales/features/finance/presentation/bindings/finance_binding.dart';
import 'package:netsales/features/finance/presentation/screens/network_wallet_dashboard_screen.dart';
import 'package:netsales/features/finance/presentation/screens/pos_debt_ledger_screen.dart';
import 'package:netsales/features/finance/presentation/screens/pos_wallet_dashboard_screen.dart';
import 'package:netsales/features/finance/presentation/screens/repayment_collection_screen.dart';
import 'package:netsales/features/finance/presentation/screens/repayment_details_screen.dart';
import 'package:netsales/features/finance/presentation/screens/repayment_history_screen.dart';
import 'package:netsales/features/onboarding/presentation/bindings/onboarding_binding.dart';
import 'package:netsales/features/onboarding/presentation/bindings/welcome_binding.dart';
import 'package:netsales/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:netsales/features/onboarding/presentation/screens/welcome_screen.dart';
import 'package:netsales/features/splash/presentation/bindings/splash_binding.dart';
import 'package:netsales/features/splash/presentation/screens/splash_screen.dart';
import 'package:netsales/features/workspace/presentation/bindings/network_workspace_binding.dart';
import 'package:netsales/features/workspace/presentation/bindings/pos_workspace_binding.dart';
import 'package:netsales/features/workspace/presentation/screens/network_workspace_shell.dart';
import 'package:netsales/features/workspace/presentation/screens/pos_workspace_shell.dart';
import 'package:netsales/features/workspace/presentation/screens/unsupported_platform_screen.dart';
import 'package:netsales/widgets/charts/showcase/charts_showcase_binding.dart';
import 'package:netsales/widgets/charts/showcase/charts_showcase_screen.dart';
import 'package:netsales/widgets/dashboard_metrics/showcase/dashboard_metrics_showcase_binding.dart';
import 'package:netsales/widgets/dashboard_metrics/showcase/dashboard_metrics_showcase_screen.dart';
import 'package:netsales/widgets/data_grid/showcase/data_grid_showcase_binding.dart';
import 'package:netsales/widgets/data_grid/showcase/data_grid_showcase_screen.dart';
import 'package:netsales/widgets/feedback/custom_not_found.dart';
import 'package:netsales/widgets/feedback/custom_unauthorized.dart';

/// ============================================================================
/// سجل صفحات ومسارات التطبيق (Application Pages Register)
/// ============================================================================
abstract final class AppPages {
  AppPages._();

  static const String initial = AppRoutes.initial;

  static final List<GetPage<dynamic>> routes = [
    // 1. مسار البداية والفحص الأولي (Splash)
    GetPage(
      name: AppRoutes.initial,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
    ),

    // Not Found
    GetPage(name: AppRoutes.notFound, page: () => const CustomNotFound()),

    // Unauthorized Access Rejection (Deep Link Defense)
    GetPage(
      name: AppRoutes.unauthorized,
      page: () => const CustomUnauthorized(),
    ),

    // ========================================================================
    // 2. جولة التعريف والترحيب (Onboarding & Welcome)
    // ========================================================================
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingScreen(),
      binding: OnboardingBinding(),
      middlewares: [GuestGuard()],
    ),
    GetPage(
      name: AppRoutes.welcome,
      page: () => const WelcomeScreen(),
      binding: WelcomeBinding(),
      middlewares: [GuestGuard()],
    ),

    // ========================================================================
    // 3. مسارات المصادقة العامة (Auth Routes)
    // ========================================================================
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: LoginBinding(),
      middlewares: [GuestGuard()],
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordScreen(),
      binding: ForgotPasswordBinding(),
      middlewares: [GuestGuard()],
    ),
    GetPage(
      name: AppRoutes.verifyOtp,
      page: () => const VerifyOtpScreen(),
      binding: VerifyOtpBinding(),
    ),
    GetPage(
      name: AppRoutes.resetPassword,
      page: () => const ResetPasswordScreen(),
      binding: ResetPasswordBinding(),
    ),
    GetPage(
      name: AppRoutes.twoFactorAuth,
      page: () => const TwoFactorAuthScreen(),
      binding: TwoFactorAuthBinding(),
    ),
    GetPage(
      name: AppRoutes.registerNetwork,
      page: () => const RegisterNetworkScreen(),
      binding: RegisterNetworkBinding(),
      middlewares: [GuestGuard()],
    ),
    GetPage(
      name: AppRoutes.registerPos,
      page: () => const RegisterPosScreen(),
      binding: RegisterPosBinding(),
      middlewares: [GuestGuard()],
    ),

    // ========================================================================
    // 4. مسارات مساحات العمل التشغيلية المحمية (Workspace Shell Routes)
    // ========================================================================
    // مسار التوجيه الافتراضي للوحة التحكم (يتم اعتراضه وتوجيهه حسب مساحة المستخدم)
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const SizedBox.shrink(),
      middlewares: [AuthGuard(), WorkspaceGuard()],
    ),

    // مساحة عمل مزود شبكة الإنترنت (Network Workspace)
    GetPage(
      name: AppRoutes.networkWorkspace,
      page: () => const NetworkWorkspaceShell(),
      binding: NetworkWorkspaceBinding(),
      middlewares: [
        AuthGuard(),
        WorkspaceGuard(targetWorkspace: AppWorkspace.network),
      ],
    ),

    // مساحة عمل نقطة البيع والوكيل (POS Workspace)
    GetPage(
      name: AppRoutes.posWorkspace,
      page: () => const PosWorkspaceShell(),
      binding: PosWorkspaceBinding(),
      middlewares: [
        AuthGuard(),
        WorkspaceGuard(targetWorkspace: AppWorkspace.pos),
      ],
    ),

    // شاشة حظر وتوجيه حسابات إدارة المنصة العامة (Platform Scope Exclusion)
    GetPage(
      name: AppRoutes.unsupportedPlatform,
      page: () => const UnsupportedPlatformScreen(),
      middlewares: [AuthGuard()],
    ),

    // ========================================================================
    // 5. مسارات الأمان والجلسات المعتمدة (Security & Active Sessions)
    // ========================================================================
    GetPage(
      name: AppRoutes.activeSessions,
      page: () => const ActiveSessionsScreen(),
      binding: ActiveSessionsBinding(),
      middlewares: [AuthGuard()],
    ),

    // ========================================================================
    // 6. مسارات الكيانات والعلاقات التجارية (Commercial Entities & Relationships)
    // ========================================================================
    GetPage(
      name: AppRoutes.posDirectory,
      page: () => const NetworkPosDirectoryScreen(),
      binding: CommercialBinding(),
      middlewares: [
        AuthGuard(),
        WorkspaceGuard(targetWorkspace: AppWorkspace.network),
      ],
    ),
    GetPage(
      name: AppRoutes.linkedNetworksCatalog,
      page: () => const PosLinkedNetworksScreen(),
      binding: CommercialBinding(),
      middlewares: [
        AuthGuard(),
        WorkspaceGuard(targetWorkspace: AppWorkspace.pos),
      ],
    ),

    // ========================================================================
    // 7. مسارات كتالوج باقات الكروت والأسعار (Voucher Packages Catalog M5.1)
    // ========================================================================
    GetPage(
      name: AppRoutes.voucherPackagesCatalog,
      page: () => const PackageCatalogScreen(),
      binding: PackageCatalogBinding(),
      middlewares: [
        AuthGuard(),
        WorkspaceGuard(targetWorkspace: AppWorkspace.network),
      ],
    ),
    GetPage(
      name: AppRoutes.packageDetails,
      page: () => const PackageDetailsScreen(),
      binding: PackageCatalogBinding(),
      middlewares: [
        AuthGuard(),
        WorkspaceGuard(targetWorkspace: AppWorkspace.network),
      ],
    ),
    GetPage(
      name: AppRoutes.packageForm,
      page: () => const PackageFormScreen(),
      binding: PackageCatalogBinding(),
      middlewares: [
        AuthGuard(),
        WorkspaceGuard(targetWorkspace: AppWorkspace.network),
      ],
    ),

    // ========================================================================
    // 8. مسارات دورة حياة طلبات التوريد والمشتريات (Procurement Requests M6)
    // ========================================================================
    GetPage(
      name: AppRoutes.procurementOrders,
      page: () => const PosProcurementOrdersScreen(),
      binding: ProcurementRequestBinding(),
      middlewares: [
        AuthGuard(),
        WorkspaceGuard(targetWorkspace: AppWorkspace.pos),
      ],
    ),
    GetPage(
      name: AppRoutes.newProcurementOrder,
      page: () => const PosNewProcurementOrderScreen(),
      binding: ProcurementRequestBinding(),
      middlewares: [
        AuthGuard(),
        WorkspaceGuard(targetWorkspace: AppWorkspace.pos),
      ],
    ),
    GetPage(
      name: AppRoutes.supplyRequestsReview,
      page: () => const NetworkSupplyRequestsReviewScreen(),
      binding: ProcurementRequestBinding(),
      middlewares: [
        AuthGuard(),
        WorkspaceGuard(targetWorkspace: AppWorkspace.network),
      ],
    ),
    GetPage(
      name: AppRoutes.voucherRequestDetails,
      page: () => const ProcurementRequestDetailsScreen(),
      binding: ProcurementRequestBinding(),
      middlewares: [AuthGuard()],
    ),

    // ==========================================
    // 9. فواتير المبيعات والمشتريات والمحاسبة (Invoicing & Accounting)
    // ==========================================
    GetPage(
      name: AppRoutes.networkCreateSaleInvoice,
      page: () => const NetworkDirectInvoiceScreen(),
      binding: InvoiceBinding(),
      middlewares: [
        AuthGuard(),
        PermissionGuardMiddleware(
          requiredPermission: AppPermissions.salesCreate,
        ),
        WorkspaceGuard(targetWorkspace: AppWorkspace.network),
      ],
    ),
    GetPage(
      name: AppRoutes.wholesaleInvoices,
      page: () => const NetworkWholesaleInvoicesScreen(),
      binding: InvoiceBinding(),
      middlewares: [
        AuthGuard(),
        WorkspaceGuard(targetWorkspace: AppWorkspace.network),
      ],
    ),
    GetPage(
      name: AppRoutes.saleInvoiceDetails,
      page: () => const InvoiceDetailsScreen(isNetworkPerspective: true),
      binding: InvoiceBinding(),
      middlewares: [
        AuthGuard(),
        WorkspaceGuard(targetWorkspace: AppWorkspace.network),
      ],
    ),
    GetPage(
      name: AppRoutes.purchaseInvoices,
      page: () => const PosPurchaseInvoicesScreen(),
      binding: InvoiceBinding(),
      middlewares: [
        AuthGuard(),
        WorkspaceGuard(targetWorkspace: AppWorkspace.pos),
      ],
    ),
    GetPage(
      name: AppRoutes.purchaseInvoiceDetails,
      page: () => const InvoiceDetailsScreen(isNetworkPerspective: false),
      binding: InvoiceBinding(),
      middlewares: [
        AuthGuard(),
        WorkspaceGuard(targetWorkspace: AppWorkspace.pos),
      ],
    ),

    // ==========================================
    // 10. المحافظ المالية والديون والتسديدات (Finance, Wallets & Repayments M8)
    // ==========================================
    // كشف رصيد وحركات محفظة نقطة البيع (M8.1)
    GetPage(
      name: AppRoutes.posWalletStatement,
      page: () => const PosWalletDashboardScreen(),
      binding: FinanceBinding(),
      middlewares: [
        AuthGuard(),
        WorkspaceGuard(targetWorkspace: AppWorkspace.pos),
      ],
    ),
    // كشف أعمار الديون والفواتير المستحقة لنقطة البيع (M8.2)
    GetPage(
      name: AppRoutes.posDebtLedger,
      page: () => const PosDebtLedgerScreen(),
      binding: FinanceBinding(),
      middlewares: [
        AuthGuard(),
        WorkspaceGuard(targetWorkspace: AppWorkspace.pos),
      ],
    ),
    // نموذج تحصيل تسديد دين نقطة البيع (M8.3 Network)
    GetPage(
      name: AppRoutes.repaymentCollection,
      page: () => const RepaymentCollectionScreen(),
      binding: FinanceBinding(),
      middlewares: [
        AuthGuard(),
        WorkspaceGuard(targetWorkspace: AppWorkspace.network),
      ],
    ),
    // سجل سندات التسديد وتوزيعات FIFO (M8.3)
    GetPage(
      name: AppRoutes.repaymentHistory,
      page: () => const RepaymentHistoryScreen(),
      binding: FinanceBinding(),
      middlewares: [
        AuthGuard(),
        WorkspaceGuard(targetWorkspace: AppWorkspace.network),
      ],
    ),
    // تفاصيل سند التسديد وتوزيعات الفواتير (M8.3)
    GetPage(
      name: AppRoutes.repaymentDetails,
      page: () => const RepaymentDetailsScreen(),
      binding: FinanceBinding(),
      middlewares: [
        AuthGuard(),
        WorkspaceGuard(targetWorkspace: AppWorkspace.network),
      ],
    ),
    // لوحة تحكم وكشف حساب محفظة مزود الشبكة (M8.4 Network)
    GetPage(
      name: AppRoutes.networkWalletStatement,
      page: () => const NetworkWalletDashboardScreen(),
      binding: FinanceBinding(),
      middlewares: [
        AuthGuard(),
        WorkspaceGuard(targetWorkspace: AppWorkspace.network),
      ],
    ),

    // Developer-only visual verification; omitted from release builds.
    if (kDebugMode)
      GetPage<dynamic>(
        name: AppRoutes.dashboardMetricsShowcase,
        page: () => const DashboardMetricsShowcaseScreen(),
        binding: DashboardMetricsShowcaseBinding(),
      ),
    // Developer-only Syncfusion Charts showcase; omitted from release builds.
    if (kDebugMode)
      GetPage<dynamic>(
        name: AppRoutes.chartsShowcase,
        page: () => const ChartsShowcaseScreen(),
        binding: ChartsShowcaseBinding(),
      ),
    // Developer-only DataGrid showcase; omitted from release builds.
    if (kDebugMode)
      GetPage<dynamic>(
        name: AppRoutes.dataGridShowcase,
        page: () => const DataGridShowcaseScreen(),
        binding: DataGridShowcaseBinding(),
      ),
  ];
}
