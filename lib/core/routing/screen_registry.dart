import 'package:netsales/core/constants/app_permissions.dart';
import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/core/routing/app_routes.dart';

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

  const ScreenDescriptor({
    required this.screenId,
    required this.route,
    required this.titleAr,
    required this.titleEn,
    required this.workspace,
    this.requiredPermission,
    this.isReadOnlyVerified = true,
    this.isBalanceMutation = false,
  });
}

/// ============================================================================
/// سجل الشاشات والمسارات البرمجية المعتمدة لنظام NetSales (Screen Registry)
/// ============================================================================
/// يربط كل شاشة بكودها الفريد المتفق عليه في وثيقة المعمارية (Phase 3/3.1/4)
abstract final class ScreenRegistry {
  ScreenRegistry._();

  static const List<ScreenDescriptor> allScreens = [
    // -------------------------------------------------------------------------
    // مسارات الهوية والمصادقة (AUTH Screens)
    // -------------------------------------------------------------------------
    ScreenDescriptor(
      screenId: 'AUTH-01',
      route: AppRoutes.login,
      titleAr: 'تسجيل الدخول',
      titleEn: 'Sign In',
      workspace: AppWorkspace.unsupported,
    ),
    ScreenDescriptor(
      screenId: 'AUTH-02',
      route: AppRoutes.twoFactorAuth,
      titleAr: 'التحقق بخطوتين',
      titleEn: 'Two-Factor Authentication',
      workspace: AppWorkspace.unsupported,
    ),
    ScreenDescriptor(
      screenId: 'AUTH-03',
      route: AppRoutes.resetPassword,
      titleAr: 'استعادة وتعيين كلمة المرور',
      titleEn: 'Password Reset',
      workspace: AppWorkspace.unsupported,
    ),
    ScreenDescriptor(
      screenId: 'AUTH-04',
      route: AppRoutes.registerNetwork,
      titleAr: 'تسجيل مزود شبكة جديد',
      titleEn: 'Network Provider Registration',
      workspace: AppWorkspace.unsupported,
    ),
    ScreenDescriptor(
      screenId: 'AUTH-05',
      route: AppRoutes.registerPos,
      titleAr: 'تسجيل نقطة بيع جديدة',
      titleEn: 'Point of Sale Registration',
      workspace: AppWorkspace.unsupported,
    ),
    ScreenDescriptor(
      screenId: 'AUTH-06',
      route: AppRoutes.unsupportedPlatform,
      titleAr: 'بوابة توجيه إدارة المنصة العامة',
      titleEn: 'Platform Admin Windows Desktop Gateway',
      workspace: AppWorkspace.unsupported,
    ),

    // -------------------------------------------------------------------------
    // شاشات مساحة عمل مزود الشبكة (NETWORK Workspace Screens)
    // -------------------------------------------------------------------------
    ScreenDescriptor(
      screenId: 'NET-01',
      route: AppRoutes.networkWorkspace,
      titleAr: 'لوحة قيادة وتوزيع مزود الشبكة',
      titleEn: 'Network Operations Dashboard',
      workspace: AppWorkspace.network,
      requiredPermission: AppPermissions.networksView,
    ),
    ScreenDescriptor(
      screenId: 'NET-02',
      route: AppRoutes.wholesaleInvoices,
      titleAr: 'فواتير مبيعات الجملة والتوزيع',
      titleEn: 'Wholesale Sales Invoices',
      workspace: AppWorkspace.network,
      requiredPermission: AppPermissions.salesView,
    ),
    ScreenDescriptor(
      screenId: 'NET-03',
      route: AppRoutes.saleInvoiceDetails,
      titleAr: 'تفاصيل فاتورة مبيعات الجملة',
      titleEn: 'Wholesale Invoice Details',
      workspace: AppWorkspace.network,
      requiredPermission: AppPermissions.salesView,
    ),
    ScreenDescriptor(
      screenId: 'NET-04',
      route: AppRoutes.supplyRequestsReview,
      titleAr: 'مراجعة واعتماد طلبات التوريد',
      titleEn: 'Supply Requests Review Hub',
      workspace: AppWorkspace.network,
      requiredPermission: AppPermissions.requestsView,
    ),
    ScreenDescriptor(
      screenId: 'NET-05',
      route: AppRoutes.voucherRequestDetails,
      titleAr: 'تفاصيل وبنود طلب التوريد',
      titleEn: 'Supply Request Details',
      workspace: AppWorkspace.network,
      requiredPermission: AppPermissions.requestsView,
    ),
    ScreenDescriptor(
      screenId: 'NET-06',
      route: AppRoutes.posDirectory,
      titleAr: 'دليل وكلاء نقاط البيع المرتبطين',
      titleEn: 'Point of Sale Directory',
      workspace: AppWorkspace.network,
      requiredPermission: AppPermissions.posView,
    ),
    ScreenDescriptor(
      screenId: 'NET-08',
      route: AppRoutes.voucherPackagesCatalog,
      titleAr: 'كتالوج باقات الكروت وأسعار الجملة',
      titleEn: 'Voucher Packages Catalog',
      workspace: AppWorkspace.network,
      requiredPermission: AppPermissions.voucherPackagesView,
    ),
    ScreenDescriptor(
      screenId: 'NET-09',
      route: AppRoutes.customDiscounts,
      titleAr: 'عمولات وخصومات الوكلاء المخصصة',
      titleEn: 'Custom POS Discounts',
      workspace: AppWorkspace.network,
      requiredPermission: AppPermissions.voucherPackagesView,
    ),
    ScreenDescriptor(
      screenId: 'NET-10',
      route: AppRoutes.networkWalletStatement,
      titleAr: 'كشف حركات محفظة الشبكة والحسابات',
      titleEn: 'Network Wallet & Ledger Statement',
      workspace: AppWorkspace.network,
      requiredPermission: AppPermissions.networkWalletsView,
    ),
    ScreenDescriptor(
      screenId: 'NET-11',
      route: AppRoutes.operatingExpenses,
      titleAr: 'سندات المصروفات التشغيلية',
      titleEn: 'Operating Expenses Disbursals',
      workspace: AppWorkspace.network,
      requiredPermission: AppPermissions.expensesView,
    ),
    ScreenDescriptor(
      screenId: 'NET-12',
      route: AppRoutes.networkTeamManagement,
      titleAr: 'إدارة فريق عمل وموظفي الشبكة',
      titleEn: 'Network Staff & Memberships',
      workspace: AppWorkspace.network,
      requiredPermission: AppPermissions.usersView,
    ),
    ScreenDescriptor(
      screenId: 'NET-13',
      route: AppRoutes.networkSubscription,
      titleAr: 'اشتراك الشبكة وحصص الاستهلاك',
      titleEn: 'Network Cloud Subscription & Quotas',
      workspace: AppWorkspace.network,
      requiredPermission: AppPermissions.networksView,
    ),

    // -------------------------------------------------------------------------
    // شاشات مساحة عمل نقطة البيع والوكيل (POS Workspace Screens)
    // -------------------------------------------------------------------------
    ScreenDescriptor(
      screenId: 'POS-01',
      route: AppRoutes.posWorkspace,
      titleAr: 'لوحة قيادة ومشتريات نقطة البيع',
      titleEn: 'POS Organization Dashboard',
      workspace: AppWorkspace.pos,
      requiredPermission: AppPermissions.posView,
    ),
    ScreenDescriptor(
      screenId: 'POS-02',
      route: AppRoutes.procurementOrders,
      titleAr: 'سجل طلبات توريد وشراء الكروت',
      titleEn: 'Procurement Supply Orders',
      workspace: AppWorkspace.pos,
      requiredPermission: AppPermissions.requestsView,
    ),
    ScreenDescriptor(
      screenId: 'POS-03',
      route: AppRoutes.newProcurementOrder,
      titleAr: 'إنشاء طلب توريد كروت جديد',
      titleEn: 'New Procurement Order',
      workspace: AppWorkspace.pos,
      requiredPermission: AppPermissions.requestsCreate,
      isBalanceMutation: true,
    ),
    ScreenDescriptor(
      screenId: 'POS-04',
      route: AppRoutes.purchaseInvoices,
      titleAr: 'فواتير المشتريات وسندات الاستلام',
      titleEn: 'Purchase Invoices & Receipts',
      workspace: AppWorkspace.pos,
      requiredPermission: AppPermissions.salesView,
    ),
    ScreenDescriptor(
      screenId: 'POS-05',
      route: AppRoutes.purchaseInvoiceDetails,
      titleAr: 'تفاصيل فاتورة الشراء والسند',
      titleEn: 'Purchase Invoice Details',
      workspace: AppWorkspace.pos,
      requiredPermission: AppPermissions.salesView,
    ),
    ScreenDescriptor(
      screenId: 'POS-06',
      route: AppRoutes.linkedNetworksCatalog,
      titleAr: 'دليل الشبكات المزودة وباقاتها',
      titleEn: 'Linked Networks & Packages Catalog',
      workspace: AppWorkspace.pos,
      requiredPermission: AppPermissions.networksView,
    ),
    ScreenDescriptor(
      screenId: 'POS-07',
      route: AppRoutes.posWalletStatement,
      titleAr: 'كشف الحساب الجاري والمديونية',
      titleEn: 'Current Account & Debt Statement',
      workspace: AppWorkspace.pos,
      requiredPermission: AppPermissions.posWalletsView,
    ),
    ScreenDescriptor(
      screenId: 'POS-08',
      route: AppRoutes.posStaffManagement,
      titleAr: 'إدارة موظفي ومحاسبي نقطة البيع',
      titleEn: 'POS Staff & Memberships',
      workspace: AppWorkspace.pos,
      requiredPermission: AppPermissions.usersView,
    ),

    // -------------------------------------------------------------------------
    // شاشات الأمان الموحدة لكافة البيئات (SEC Screens)
    // -------------------------------------------------------------------------
    ScreenDescriptor(
      screenId: 'SEC-01',
      route: AppRoutes.activeSessions,
      titleAr: 'مراقبة الجلسات والأجهزة النشطة',
      titleEn: 'Active Devices & Sessions',
      workspace: AppWorkspace.unsupported,
      requiredPermission: AppPermissions.authView,
    ),
    ScreenDescriptor(
      screenId: 'SEC-02',
      route: AppRoutes.securitySettings,
      titleAr: 'إعدادات الأمان وتغيير كلمة المرور',
      titleEn: 'Security & 2FA Settings',
      workspace: AppWorkspace.unsupported,
      requiredPermission: AppPermissions.authManage,
    ),
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
}

