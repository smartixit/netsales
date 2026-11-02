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

  // المسارات المحمية الرئيسية (Protected Dashboard & Home)
  static const String dashboard = '/dashboard';
  static const String homeLayout = '/home';

  // مساحات العمل التشغيلية (Operational Workspaces)
  static const String workspace = '/workspace';
  static const String networkWorkspace = '/workspace/network';
  static const String posWorkspace = '/workspace/pos';
  static const String unsupportedPlatform = '/unsupported-platform';

  // شاشات مساحة مزودي الشبكات (NETWORK Workspace Routes)
  static const String wholesaleInvoices = '/network/invoices';
  static const String supplyRequestsReview = '/network/supply-requests';
  static const String posDirectory = '/network/pos-directory';
  static const String voucherPackagesCatalog = '/voucher-packages';
  static const String customDiscounts = '/network/discounts';
  static const String networkWalletStatement = '/network-wallets';
  static const String networkDebts = '/network/debts';
  static const String operatingExpenses = '/expenses';
  static const String networkTeamManagement = '/network/team';
  static const String networkSubscription = '/network/subscription';

  // شاشات مساحة نقاط البيع (POS Workspace Routes)
  static const String procurementOrders = '/pos/procurement-orders';
  static const String newProcurementOrder = '/pos/procurement-orders/new';
  static const String purchaseInvoices = '/pos/invoices';
  static const String purchaseInvoiceDetails = '/sale-invoices/details';
  static const String linkedNetworksCatalog = '/pos/linked-networks';
  static const String posWalletStatement = '/pos-wallets';
  static const String posStaffManagement = '/pos/staff';

  // شاشات الأمان الموحدة
  static const String activeSessions = '/security/sessions';
  static const String securitySettings = '/security/settings';

  // قطاعات العمل المعتمدة (Business Domain Routes)
  static const String networks = '/networks';
  static const String networkDetails = '/networks/details';
  static const String networkWallets = '/network-wallets';

  static const String pos = '/pos';
  static const String posDetails = '/pos/details';
  static const String posWallets = '/pos-wallets';

  static const String voucherPackages = '/voucher-packages';
  static const String voucherDiscounts = '/voucher-discounts';

  static const String requests = '/requests';
  static const String requestDetails = '/requests/details';

  static const String sales = '/sales';
  static const String saleInvoices = '/sale-invoices';
  static const String saleInvoiceDetails = '/sale-invoices/details';
  static const String voucherRequestDetails = '/voucher-requests/details';

  static const String expenses = '/expenses';
  static const String bankAccounts = '/bank-accounts';
  static const String subscriptions = '/subscriptions';

  static const String support = '/support';
  static const String notifications = '/notifications';
  static const String systemLogs = '/system-logs';

  static const String profile = '/profile';
  static const String settings = '/settings';

  // مسار الرفض والتنبيه الأمني
  static const String unauthorized = '/unauthorized';

  // Not Found
  static const String notFound = '/not-found';
}
