import 'package:netsales/core/config/app_environment.dart';

/// ============================================================================
/// ثوابت مسارات واجهة برمجة التطبيقات (NetSales API V1 Endpoints)
/// ============================================================================
/// موثقة ومطابقة 100% لمسارات الباك إند المعتمدة في netsales_api (routes/api.php).
class ApiConstants {
  ApiConstants._();

  /// عنوان الـ API الأساسي — يُشتق ديناميكياً من بيئة التشغيل الحالية
  static String get baseUrl => AppEnvironment.apiBaseUrl;

  // ── مهلات الاتصال (Timeouts in milliseconds) ──
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 30000;
  static const int sendTimeout = 30000;

  // ──────────────────────────────────────────────
  // 1. فحص الحالة والجاهزية (Health Check)
  // ──────────────────────────────────────────────
  static const String healthCheck = '/auth/health-check';

  // ──────────────────────────────────────────────
  // 2. المصادقة والحساب الشخصي (Authentication & Profile)
  // ──────────────────────────────────────────────
  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  static const String authLogout = '/auth/logout';
  static const String authMe = '/auth/me';
  static const String authPermissions = '/auth/permissions';
  static const String authSessionCheck = '/auth/session/check';
  static const String auth2FA = '/auth/2fa';
  static const String auth2FAVerify = '/auth/2fa/verify';
  static const String authPasswordRequestReset = '/auth/password/request-reset';
  static const String authPasswordVerifyOtp = '/auth/password/verify-otp';
  static const String authPasswordReset = '/auth/password/reset';
  static const String authUpdateProfile = '/auth/update-profile';
  static const String authUpdatePassword = '/auth/update-password';
  static const String authUploadProfilePicture = '/auth/upload-profile-picture';
  static const String authDeleteProfilePicture = '/auth/profile-picture';

  // التحقق بخطوتين والـ OTP
  static const String otpSend = '/auth/otp/send';
  static const String otpVerify = '/auth/otp/verify';

  // ──────────────────────────────────────────────
  // 3. شبكات بيع الكروت (Networks)
  // ──────────────────────────────────────────────
  static const String networks = '/networks';
  static const String networksCounts = '/networks/counts';
  static const String networksTrashed = '/networks/trashed';
  static const String networksBatchDelete = '/networks/batch-delete';
  static const String networksBatchRestore = '/networks/batch-restore';
  static const String networksBatchForceDelete = '/networks/batch-force-delete';
  static String networkDetails(int id) => '$networks/$id';
  static String networkStatus(int id) => '$networks/$id/status';
  static String networkLogo(int id) => '$networks/$id/logo';

  // ──────────────────────────────────────────────
  // 4. نقاط البيع (POS - Points of Sale)
  // ──────────────────────────────────────────────
  static const String pos = '/pos';
  static const String posCounts = '/pos/counts';
  static const String posTrashed = '/pos/trashed';
  static const String posBatchDelete = '/pos/batch-delete';
  static const String posBatchRestore = '/pos/batch-restore';
  static const String posBatchForceDelete = '/pos/batch-force-delete';
  static String posDetails(int id) => '$pos/$id';
  static String posStatus(int id) => '$pos/$id/status';
  static String posByNetwork(int networkId) => '$pos/network/$networkId';

  // ──────────────────────────────────────────────
  // 5. ربط نقاط البيع بالشبكات (Network POS)
  // ──────────────────────────────────────────────
  static const String networkPos = '/network-pos';
  static const String networkPosCounts = '/network-pos/counts';
  static String networkPosStatus(int id) => '$networkPos/$id/status';
  static String networkPosByNetwork(int networkId) => '$networkPos/network/$networkId';
  static String networkPosByPos(int posId) => '$networkPos/pos/$posId';

  // ──────────────────────────────────────────────
  // 6. باقات الكروت (Voucher Packages)
  // ──────────────────────────────────────────────
  static const String voucherPackages = '/voucher-packages';
  static const String voucherPackagesTrashed = '/voucher-packages/trashed';
  static const String voucherPackagesBatchDelete = '/voucher-packages/batch-delete';
  static const String voucherPackagesBatchRestore = '/voucher-packages/batch-restore';
  static const String voucherPackagesBatchForceDelete = '/voucher-packages/batch-force-delete';
  static String voucherPackageDetails(int id) => '$voucherPackages/$id';
  static String voucherPackageStatus(int id) => '$voucherPackages/$id/status';
  static String voucherPackagesByNetwork(int networkId) => '$voucherPackages/network/$networkId';

  // ──────────────────────────────────────────────
  // 7. خصومات باقات الكروت لنقاط البيع (Voucher Package Discounts)
  // ──────────────────────────────────────────────
  static const String voucherPackageDiscounts = '/voucher-package-discounts';
  static String voucherPackageDiscountsByNetworkPos(int networkPosId) =>
      '$voucherPackageDiscounts/network-pos/$networkPosId';

  // ──────────────────────────────────────────────
  // 8. فواتير ومبيعات الكروت (Sale Invoices)
  // ──────────────────────────────────────────────
  static const String saleInvoices = '/sale-invoices';
  static const String saleInvoicesStats = '/sale-invoices/stats';
  static String saleInvoiceDetails(int id) => '$saleInvoices/$id';
  static String saleInvoiceCancel(int id) => '$saleInvoices/$id/cancel';
  static String saleInvoicesByNetwork(int networkId) => '$saleInvoices/network/$networkId';
  static String saleInvoicesByPos(int posId) => '$saleInvoices/pos/$posId';

  // ──────────────────────────────────────────────
  // 9. محافظ الشبكات وسجلاتها (Network Wallets & Logs)
  // ──────────────────────────────────────────────
  static const String networkWallets = '/network-wallets';
  static const String networkWalletLogs = '/network-wallets/logs';
  static String networkWalletByNetwork(int networkId) => '$networkWallets/network/$networkId';

  // ──────────────────────────────────────────────
  // 10. محافظ نقاط البيع وسجلاتها (POS Wallets & Logs)
  // ──────────────────────────────────────────────
  static const String posWallets = '/pos-wallets';
  static const String posWalletLogs = '/pos-wallets/logs';
  static String posWalletByPos(int posId) => '$posWallets/pos/$posId';

  // ──────────────────────────────────────────────
  // 11. باقات واشتراكات مزودي الشبكات (Provider Subscriptions & Plans)
  // ──────────────────────────────────────────────
  static const String providerSubscriptions = '/provider-subscriptions';
  static String providerSubscriptionByNetwork(int networkId) =>
      '$providerSubscriptions/network/$networkId';

  static const String subscriptionPlans = '/subscription-plans';
  static const String subscriptionPlanRequests = '/subscription-plan-requests';

  // ──────────────────────────────────────────────
  // 12. تذاكر ورسائل الدعم الفني (Support Tickets)
  // ──────────────────────────────────────────────
  static const String supportTickets = '/support-tickets';
  static const String supportTicketMessages = '/support-tickets/messages';
  static String supportTicketDetails(int id) => '$supportTickets/$id';
  static String supportTicketClose(int id) => '$supportTickets/$id/close';

  // ──────────────────────────────────────────────
  // 13. المصروفات وبنودها (Expenses)
  // ──────────────────────────────────────────────
  static const String expenses = '/expenses';
  static String expenseDetails(int id) => '$expenses/$id';

  // ──────────────────────────────────────────────
  // 14. الحسابات البنكية (Bank Accounts)
  // ──────────────────────────────────────────────
  static const String bankAccounts = '/bank-accounts';
  static String bankAccountDetails(int id) => '$bankAccounts/$id';

  // ──────────────────────────────────────────────
  // 15. المحافظات والمديريات (Governorates & Directorates)
  // ──────────────────────────────────────────────
  static const String governorates = '/governorates';
  static const String governoratesCounts = '/governorates/counts';
  static String governorateDetails(int id) => '$governorates/$id';

  static const String directorates = '/directorates';
  static String directoratesByGovernorate(int governorateId) =>
      '$directorates/governorate/$governorateId';
  static String directorateDetails(int id) => '$directorates/$id';

  // ──────────────────────────────────────────────
  // 16. إعدادات الرسائل النصية للشبكات (Network SMS Settings)
  // ──────────────────────────────────────────────
  static const String smsSettings = '/sms-settings';
  static const String smsSettingsGlobal = '/sms-settings/global';
  static String smsSettingsNetwork(int networkId) => '$smsSettings/networks/$networkId';
  static String smsSettingsNetworkTest(int networkId) => '$smsSettings/networks/$networkId/test';

  // ──────────────────────────────────────────────
  // 17. النسخ الاحتياطي السحابي (Backups & Google Drive)
  // ──────────────────────────────────────────────
  static const String backups = '/backups';
  static const String backupsSettings = '/backups/settings';
  static const String backupsHealth = '/backups/health';
  static const String backupsRun = '/backups/run';
  static const String backupsConfig = '/backups/config';
  static const String backupsDriveAuth = '/backups/drive/auth';
  static const String backupsDriveToken = '/backups/drive/token';
  static const String backupsDriveDisconnect = '/backups/drive/disconnect';

  // ──────────────────────────────────────────────
  // 18. المستخدمون والأدوار والصلاحيات (Users & Access Control)
  // ──────────────────────────────────────────────
  static const String users = '/users';
  static const String roles = '/roles';
  static const String permissions = '/permissions';
  static const String userSessions = '/user-sessions';
  static const String userDevices = '/user-devices';

  // ──────────────────────────────────────────────
  // 19. الإشعارات وسجلات النظام (Notifications & System Logs)
  // ──────────────────────────────────────────────
  static const String notifications = '/notifications';
  static const String notificationsUnread = '/notifications/unread';
  static const String markNotificationAsRead = '/notifications/mark-as-read';
  static const String markAllNotificationsAsRead = '/notifications/read-all';
  static const String adminNotificationsSend = '/admin/notifications/send';
  static const String adminNotificationsUser = '/admin/notifications/user';

  static const String systemLogs = '/system-logs';
  static const String systemLogsStats = '/system-logs/stats';
  static const String scheduledTasks = '/scheduled-tasks';
  static const String securityBans = '/security-bans';
  static const String systemSettings = '/system-settings';
}
