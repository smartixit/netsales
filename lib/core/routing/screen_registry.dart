import 'package:netsales/core/constants/app_permissions.dart';
import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/core/routing/app_routes.dart';

/// ============================================================================
/// حالة تنفيذ الشاشة في النظام (Screen Implementation State)
/// ============================================================================
enum ScreenImplementationState {
  implemented,
  placeholder,
  planned,
  notSupported,
}

/// ============================================================================
/// كائن تعريف الشاشة المؤسسية المعتمدة (Screen Metadata Descriptor)
/// ============================================================================
class ScreenDescriptor {
  final String screenId;
  final String route;
  final String titleAr;
  final String titleEn;
  final AppWorkspace workspace;
  final String? requiredPermission;
  final bool isReadOnlyVerified;
  final bool isBalanceMutation;
  final ScreenImplementationState implementationState;

  const ScreenDescriptor({
    required this.screenId,
    required this.route,
    required this.titleAr,
    required this.titleEn,
    required this.workspace,
    this.requiredPermission,
    this.isReadOnlyVerified = true,
    this.isBalanceMutation = false,
    this.implementationState = ScreenImplementationState.implemented,
  });
}

/// ============================================================================
/// سجل الشاشات والمسارات البرمجية المعتمدة لنظام NetSales (Screen Registry)
/// ============================================================================
/// يربط كل شاشة بكودها الفريد المتفق عليه في وثائق المعمارية (Phase 3.1 & Phase 4)
abstract final class ScreenRegistry {
  ScreenRegistry._();

  static const List<ScreenDescriptor> allScreens = [
    // -------------------------------------------------------------------------
    // مسارات الهوية والمصادقة (AUTH Screens)
    // -------------------------------------------------------------------------
    // ScreenDescriptor(
    //   screenId: 'AUTH-01',
    //   route: AppRoutes.unsupportedPlatform,
    //   titleAr: 'تسجيل الدخول',
    //   titleEn: 'Sign In',
    //   workspace: AppWorkspace.unsupported,
    //   implementationState: ScreenImplementationState.implemented,
    // ),
    // ScreenDescriptor(
    //   screenId: 'AUTH-02',
    //   route: AppRoutes.twoFactorAuth,
    //   titleAr: 'التحقق بخطوتين',
    //   titleEn: 'Two-Factor Authentication',
    //   workspace: AppWorkspace.unsupported,
    //   implementationState: ScreenImplementationState.implemented,
    // ),
    // ScreenDescriptor(
    //   screenId: 'AUTH-03',
    //   route: AppRoutes.resetPassword,
    //   titleAr: 'استعادة وتعيين كلمة المرور',
    //   titleEn: 'Password Reset',
    //   workspace: AppWorkspace.unsupported,
    //   implementationState: ScreenImplementationState.implemented,
    // ),
    // ScreenDescriptor(
    //   screenId: 'AUTH-04',
    //   route: AppRoutes.registerNetwork,
    //   titleAr: 'تسجيل مزود شبكة جديد',
    //   titleEn: 'Network Provider Registration',
    //   workspace: AppWorkspace.unsupported,
    //   implementationState: ScreenImplementationState.implemented,
    // ),
    // ScreenDescriptor(
    //   screenId: 'AUTH-05',
    //   route: AppRoutes.registerPos,
    //   titleAr: 'تسجيل نقطة بيع جديدة',
    //   titleEn: 'Point of Sale Registration',
    //   workspace: AppWorkspace.unsupported,
    //   implementationState: ScreenImplementationState.implemented,
    // ),
    // ScreenDescriptor(
    //   screenId: 'AUTH-06',
    //   route: AppRoutes.unsupportedPlatform,
    //   titleAr: 'بوابة توجيه إدارة المنصة العامة',
    //   titleEn: 'Platform Admin Windows Desktop Gateway',
    //   workspace: AppWorkspace.unsupported,
    //   implementationState: ScreenImplementationState.implemented,
    // ),

    // -------------------------------------------------------------------------
    // شاشات مساحة عمل مزود الشبكة (NETWORK Workspace Screens - Phase 3.1 / 4)
    // -------------------------------------------------------------------------
    ScreenDescriptor(
      screenId: 'NET-01',
      route: AppRoutes.networkWorkspace,
      titleAr: 'لوحة قيادة وتوزيع مزود الشبكة',
      titleEn: 'Network Dashboard',
      workspace: AppWorkspace.network,
      requiredPermission: AppPermissions.networksView,
      implementationState: ScreenImplementationState.implemented,
    ),
    ScreenDescriptor(
      screenId: 'NET-02',
      route: AppRoutes.supplyRequestsReview,
      titleAr: 'مراجعة واعتماد طلبات التوريد',
      titleEn: 'Supply Requests',
      workspace: AppWorkspace.network,
      requiredPermission: AppPermissions.requestsView,
      implementationState: ScreenImplementationState.implemented,
    ),
    ScreenDescriptor(
      screenId: 'NET-03',
      route: AppRoutes.wholesaleInvoices,
      titleAr: 'فواتير مبيعات الجملة والتوزيع',
      titleEn: 'Wholesale Invoices',
      workspace: AppWorkspace.network,
      requiredPermission: AppPermissions.salesView,
      implementationState: ScreenImplementationState.implemented,
    ),
    ScreenDescriptor(
      screenId: 'NET-04',
      route: AppRoutes.networkWalletStatement,
      titleAr: 'كشف حركات محفظة الشبكة والحسابات',
      titleEn: 'Network Wallet Statement',
      workspace: AppWorkspace.network,
      requiredPermission: AppPermissions.networkWalletsView,
      implementationState: ScreenImplementationState.implemented,
    ),
    ScreenDescriptor(
      screenId: 'NET-05',
      route: AppRoutes.posDirectory,
      titleAr: 'دليل وكلاء نقاط البيع المرتبطين',
      titleEn: 'Affiliated POS Directory',
      workspace: AppWorkspace.network,
      requiredPermission: AppPermissions.posView,
      implementationState: ScreenImplementationState.implemented,
    ),
    ScreenDescriptor(
      screenId: 'NET-06',
      route: AppRoutes.voucherPackagesCatalog,
      titleAr: 'كتالوج باقات الكروت وأسعار الجملة',
      titleEn: 'Voucher Package Catalog',
      workspace: AppWorkspace.network,
      requiredPermission: AppPermissions.voucherPackagesView,
      implementationState: ScreenImplementationState.implemented,
    ),
    ScreenDescriptor(
      screenId: 'NET-07',
      route: AppRoutes.operatingExpenses,
      titleAr: 'سندات المصروفات التشغيلية',
      titleEn: 'Operational Expenses',
      workspace: AppWorkspace.network,
      requiredPermission: AppPermissions.expensesView,
      implementationState: ScreenImplementationState.implemented,
    ),
    ScreenDescriptor(
      screenId: 'NET-11',
      route: AppRoutes.networkReports,
      titleAr: 'التقارير وكشوف حساب اشتراك المنصة',
      titleEn: 'Network Reports and Platform Subscription Statements',
      workspace: AppWorkspace.network,
      requiredPermission: AppPermissions.networksReport,
      implementationState: ScreenImplementationState.implemented,
    ),
    ScreenDescriptor(
      screenId: 'NET-12',
      route: AppRoutes.networkSubscriptionBilling,
      titleAr: 'اشتراكات الشبكة وفواتيرها',
      titleEn: 'Network Platform Subscriptions and Invoices',
      workspace: AppWorkspace.network,
      requiredPermission: AppPermissions.subscriptionsView,
      implementationState: ScreenImplementationState.implemented,
    ),
    ScreenDescriptor(
      screenId: 'NET-12',
      route: AppRoutes.networkSubscriptionBilling,
      titleAr: 'اشتراكات الشبكة وفواتيرها',
      titleEn: 'Network Platform Subscriptions and Invoices',
      workspace: AppWorkspace.network,
      requiredPermission: AppPermissions.subscriptionsView,
      implementationState: ScreenImplementationState.implemented,
    ),
    ScreenDescriptor(
      screenId: 'NET-08',
      route: AppRoutes.networkTeamManagement,
      titleAr: 'إدارة فريق عمل وموظفي الشبكة',
      titleEn: 'Network Staff',
      workspace: AppWorkspace.network,
      requiredPermission: AppPermissions.usersView,
      implementationState: ScreenImplementationState.implemented,
    ),
    ScreenDescriptor(
      screenId: 'NET-10',
      route: AppRoutes.voucherRequestDetails,
      titleAr: 'تفاصيل وبنود طلب التوريد',
      titleEn: 'Supply Request Details',
      workspace: AppWorkspace.network,
      requiredPermission: AppPermissions.requestsView,
      implementationState: ScreenImplementationState.implemented,
    ),
    ScreenDescriptor(
      screenId: 'NET-11',
      route: AppRoutes.saleInvoiceDetails,
      titleAr: 'تفاصيل فاتورة مبيعات الجملة',
      titleEn: 'Wholesale Invoice Details',
      workspace: AppWorkspace.network,
      requiredPermission: AppPermissions.salesView,
      implementationState: ScreenImplementationState.implemented,
    ),
    ScreenDescriptor(
      screenId: 'NET-12',
      route: AppRoutes.networkCreateSaleInvoice,
      titleAr: 'إنشاء فاتورة مبيعات مباشرة',
      titleEn: 'Create Direct Sale Invoice',
      workspace: AppWorkspace.network,
      requiredPermission: AppPermissions.salesCreate,
      isBalanceMutation: true,
      implementationState: ScreenImplementationState.implemented,
    ),
    ScreenDescriptor(
      screenId: 'NET-13',
      route: AppRoutes.repaymentCollection,
      titleAr: 'تحصيل سداد مديونيات نقاط البيع',
      titleEn: 'Collect POS Debt Repayments',
      workspace: AppWorkspace.network,
      requiredPermission: AppPermissions.posWalletsCreate,
      isBalanceMutation: true,
      implementationState: ScreenImplementationState.implemented,
    ),
    ScreenDescriptor(
      screenId: 'NET-14',
      route: AppRoutes.repaymentHistory,
      titleAr: 'سجل سندات السداد والتسويات',
      titleEn: 'Repayment History',
      workspace: AppWorkspace.network,
      requiredPermission: AppPermissions.networkWalletsView,
      implementationState: ScreenImplementationState.implemented,
    ),

    // -------------------------------------------------------------------------
    // شاشات مساحة عمل نقطة البيع والوكيل (POS Workspace Screens - Phase 3.1 / 4)
    // -------------------------------------------------------------------------
    ScreenDescriptor(
      screenId: 'POS-01',
      route: AppRoutes.posWorkspace,
      titleAr: 'لوحة قيادة ومشتريات نقطة البيع',
      titleEn: 'POS Dashboard',
      workspace: AppWorkspace.pos,
      requiredPermission: AppPermissions.posView,
      implementationState: ScreenImplementationState.implemented,
    ),
    ScreenDescriptor(
      screenId: 'POS-02',
      route: AppRoutes.newProcurementOrder,
      titleAr: 'إنشاء طلب توريد كروت جديد',
      titleEn: 'New Procurement Order',
      workspace: AppWorkspace.pos,
      requiredPermission: AppPermissions.requestsCreate,
      isBalanceMutation: false,
      implementationState: ScreenImplementationState.implemented,
    ),
    ScreenDescriptor(
      screenId: 'POS-03',
      route: AppRoutes.purchaseInvoices,
      titleAr: 'فواتير مشتريات نقطة البيع',
      titleEn: 'Purchase Invoices',
      workspace: AppWorkspace.pos,
      requiredPermission: AppPermissions.salesView,
      implementationState: ScreenImplementationState.implemented,
    ),
    ScreenDescriptor(
      screenId: 'POS-04',
      route: AppRoutes.posWalletStatement,
      titleAr: 'كشف الحساب الجاري والمديونية',
      titleEn: 'POS Wallet Statement',
      workspace: AppWorkspace.pos,
      requiredPermission: AppPermissions.posWalletsView,
      implementationState: ScreenImplementationState.implemented,
    ),
    ScreenDescriptor(
      screenId: 'POS-05',
      route: AppRoutes.procurementOrders,
      titleAr: 'سجل ومتابعة طلبات التوريد',
      titleEn: 'Procurement Tracking',
      workspace: AppWorkspace.pos,
      requiredPermission: AppPermissions.requestsView,
      implementationState: ScreenImplementationState.implemented,
    ),
    ScreenDescriptor(
      screenId: 'POS-06',
      route: AppRoutes.linkedNetworksCatalog,
      titleAr: 'دليل الشبكات المزودة وباقاتها المعتمدة',
      titleEn: 'Linked Networks and Catalog',
      workspace: AppWorkspace.pos,
      requiredPermission: AppPermissions.networksView,
      implementationState: ScreenImplementationState.implemented,
    ),
    ScreenDescriptor(
      screenId: 'POS-07',
      route: AppRoutes.posStaffManagement,
      titleAr: 'إدارة موظفي ومحاسبي نقطة البيع',
      titleEn: 'POS Staff',
      workspace: AppWorkspace.pos,
      requiredPermission: AppPermissions.usersView,
      implementationState: ScreenImplementationState.implemented,
    ),
    ScreenDescriptor(
      screenId: 'POS-08',
      route: AppRoutes.voucherRequestDetails,
      titleAr: 'تفاصيل وتتبع طلب التوريد',
      titleEn: 'Procurement Order Details',
      workspace: AppWorkspace.pos,
      requiredPermission: AppPermissions.requestsView,
      implementationState: ScreenImplementationState.implemented,
    ),
    ScreenDescriptor(
      screenId: 'POS-09',
      route: AppRoutes.purchaseInvoiceDetails,
      titleAr: 'تفاصيل فاتورة الشراء والسند المالي',
      titleEn: 'Purchase Invoice Details',
      workspace: AppWorkspace.pos,
      requiredPermission: AppPermissions.salesView,
      implementationState: ScreenImplementationState.implemented,
    ),
    ScreenDescriptor(
      screenId: 'POS-10',
      route: AppRoutes.posDebtLedger,
      titleAr: 'كشف الذمم والفواتير المستحقة',
      titleEn: 'Debt Ledger and Outstanding Invoices',
      workspace: AppWorkspace.pos,
      requiredPermission: AppPermissions.posWalletsView,
      implementationState: ScreenImplementationState.implemented,
    ),

    // -------------------------------------------------------------------------
    // شاشات الأمان الموحدة لكافة البيئات (SEC Screens)
    // -------------------------------------------------------------------------
    // ScreenDescriptor(
    //   screenId: 'SEC-01',
    //   route: AppRoutes.activeSessions,
    //   titleAr: 'مراقبة الجلسات والأجهزة النشطة',
    //   titleEn: 'Active Devices & Sessions',
    //   workspace: AppWorkspace.unsupported,
    //   requiredPermission: AppPermissions.authView,
    //   implementationState: ScreenImplementationState.implemented,
    // ),
    // ScreenDescriptor(
    //   screenId: 'SEC-02',
    //   route: AppRoutes.securitySettings,
    //   titleAr: 'إعدادات الأمان وتغيير كلمة المرور',
    //   titleEn: 'Security & 2FA Settings',
    //   workspace: AppWorkspace.unsupported,
    //   requiredPermission: AppPermissions.authManage,
    //   implementationState: ScreenImplementationState.placeholder,
    // ),
  ];

  static ScreenDescriptor? findById(String screenId) {
    try {
      return allScreens.firstWhere((s) => s.screenId == screenId);
    } catch (_) {
      return null;
    }
  }

  static ScreenDescriptor? findByRoute(String route) {
    try {
      return allScreens.firstWhere((s) => s.route == route);
    } catch (_) {
      return null;
    }
  }

  /// التحقق مما إذا كان المستخدم يملك الصلاحية للوصول للشاشة المحددة بمسارها
  static bool hasAccessToRoute(String route, {required bool Function(String) can}) {
    final descriptor = findByRoute(route);
    if (descriptor == null || descriptor.requiredPermission == null) {
      return true;
    }
    return can(descriptor.requiredPermission!);
  }
}
