/// ============================================================================
/// ثوابت مسارات التطبيق (Application Routes)
/// ============================================================================
/// تُعرّف أسماء كافة المسارات في النظام لتفادي استخدام النصوص المباشرة في التوجيه.
abstract final class AppRoutes {
  AppRoutes._();

  // مسار البداية والتحقق الأولي
  static const String initial = '/';
  static const String splash = '/splash';

  // مسارات المصادقة العامة (Public / Auth Routes)
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
