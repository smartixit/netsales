/// ============================================================================
/// ثوابت مسارات التطبيق (Application Routes)
/// ============================================================================
/// تُعرّف أسماء كافة المسارات في النظام لتفادي استخدام النصوص المباشرة في التوجيه.
abstract final class AppRoutes {
  AppRoutes._();

  // مسار البداية والتحقق الأولي
  static const String initial = '/splash';

  // مسارات المصادقة العامة (Public / Auth Routes)
  static const String onboarding = '/onboarding';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String registerNetwork = '/register-network';
  static const String registerPos = '/register-pos';
  static const String forgotPassword = '/forgot-password';
  static const String verifyOtp = '/verify-otp';
  static const String resetPassword = '/reset-password';
  static const String twoFactorAuth = '/two-factor-auth';

  // مسار الرفض والتنبيه الأمني
  static const String unauthorized = '/unauthorized';

  // Not Found
  static const String notFound = '/not-found';

  // ============================================================================
  // مسارات مساحات العمل التشغيلية المعتمدة (Workspace Routes)
  // ============================================================================
  /// مسار التوجيه المركزي العام بعد تسجيل الدخول (يتولى حارس WorkspaceGuard توجيهه)
  static const String dashboard = '/dashboard';

  /// مساحة عمل مزود شبكة الإنترنت المعتمد (Network Workspace)
  static const String networkWorkspace = '/network-workspace';

  /// مساحة عمل نقطة البيع والوكيل المعتمد (POS Workspace)
  static const String posWorkspace = '/pos-workspace';

  /// شاشة حظر وتوجيه حسابات إدارة المنصة العامة (Platform Scope Exclusion)
  static const String unsupportedPlatform = '/unsupported-platform';

  // ----------------------------------------------------------------------------
  // مسارات تشغيلية فرعية لمساحة عمل مزود الشبكة (Network Sub-Routes)
  // ----------------------------------------------------------------------------
  static const String supplyRequestsReview = '/network/supply-requests';
  static const String wholesaleInvoices = '/network/wholesale-invoices';
  static const String networkWalletStatement = '/network/wallet-statement';
  static const String posDirectory = '/network/pos-directory';
  static const String voucherPackagesCatalog = '/network/packages-catalog';
  static const String operatingExpenses = '/network/operating-expenses';
  static const String networkTeamManagement = '/network/team-management';
  static const String networkSubscription = '/network/subscription';
  static const String voucherRequestDetails =
      '/network/voucher-request-details';
  static const String saleInvoiceDetails = '/network/sale-invoice-details';

  // ----------------------------------------------------------------------------
  // مسارات تشغيلية فرعية لمساحة عمل نقطة البيع (POS Sub-Routes)
  // ----------------------------------------------------------------------------
  static const String newProcurementOrder = '/pos/new-procurement-order';
  static const String purchaseInvoices = '/pos/purchase-invoices';
  static const String posWalletStatement = '/pos/wallet-statement';
  static const String procurementOrders = '/pos/procurement-orders';
  static const String linkedNetworksCatalog = '/pos/linked-networks';
  static const String posStaffManagement = '/pos/staff-management';
  static const String purchaseInvoiceDetails = '/pos/purchase-invoice-details';

  // ----------------------------------------------------------------------------
  // مسارات الأمان الموحدة لكافة البيئات (Security Routes)
  // ----------------------------------------------------------------------------
  static const String activeSessions = '/security/active-sessions';
  static const String securitySettings = '/security/settings';
}
