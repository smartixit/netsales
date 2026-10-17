
import 'package:netsales/core/config/app_environment.dart';

class ApiConstants {
  ApiConstants._();

  /// عنوان الـ API — يُشتق من البيئة الحالية (`AppEnvironment`).
  /// ممنوع كتابة عناوين صريحة هنا؛ استخدم `--dart-define=API_BASE_URL=...`.
  static String get baseUrl => AppEnvironment.apiBaseUrl;

  /// جذر الملفات والصور المرفوعة.

  // Connection timeout in milliseconds
  static const int connectTimeout = 15000;

  // Receive timeout in milliseconds
  static const int receiveTimeout = 30000;

  // Send timeout in milliseconds
  static const int sendTimeout = 30000;

  // ──────────────────────────────────────────────
  // Health Check
  // ──────────────────────────────────────────────
  static const String healthCheck = '/auth/health-check';

  // ──────────────────────────────────────────────
  // Auth
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

  // ──────────────────────────────────────────────
  // Users
  // ──────────────────────────────────────────────
  static const String users = '/users';

  // ──────────────────────────────────────────────
  // Roles
  // ──────────────────────────────────────────────
  static const String roles = '/roles';

  // ──────────────────────────────────────────────
  // Permissions
  // ──────────────────────────────────────────────
  static const String permissions = '/permissions';
  static const String permissionModules = '/permission-modules';

  // ──────────────────────────────────────────────
  // Notifications
  // ──────────────────────────────────────────────
  static const String getAllNotifications = '/notifications';
  static const String getAllNotificationsUnread = '/notifications/unread';
  static const String markNotificationAsRead = '/notifications/mark-as-read';
  static const String markAllNotificationsAsRead = '/notifications/read-all';
  static const String adminNotifications = '/admin/notifications';

  // ──────────────────────────────────────────────
  // Stores
  // ──────────────────────────────────────────────
  static const String stores = '/stores';
  static String storeUploadLogo(int storeId) => '$stores/$storeId/logo';

  // ──────────────────────────────────────────────
  // Payment Types
  // ──────────────────────────────────────────────
  static const String paymentTypes = '/payment-types';

  // ──────────────────────────────────────────────
  // Currencies
  // ──────────────────────────────────────────────
  static const String currencies = '/currencies';

  // ──────────────────────────────────────────────
  // Exchange Rates
  // ──────────────────────────────────────────────
  static const String exchangeRates = '/exchange-rates';

  // ──────────────────────────────────────────────
  // Security Bans
  // ──────────────────────────────────────────────
  static const String securityBans = '/security-bans';

  // ──────────────────────────────────────────────
  // Role Permissions
  // ──────────────────────────────────────────────
  static const String rolePermissions = '/role-permissions';

  // ──────────────────────────────────────────────
  // Operation Types
  // ──────────────────────────────────────────────
  static const String operationTypes = '/operation-types';

  // ──────────────────────────────────────────────
  // System Settings
  // ──────────────────────────────────────────────
  static const String systemSettings = '/system-settings';

  // ــ إعدادات الرسائل النصية (مدير التطبيق) ــ
  static const String smsSettings = '/sms-settings';
  static String smsSettingsStore(int storeId) => '$smsSettings/stores/$storeId';
  static String smsSettingsStoreTest(int storeId) =>
      '$smsSettings/stores/$storeId/test';

  // ──────────────────────────────────────────────
  // النسخ الاحتياطي إلى جوجل درايف (مدير التطبيق)
  // ──────────────────────────────────────────────
  static const String backups = '/backups';
  static const String backupsSettings = '/backups/settings';
  static const String backupsHealth = '/backups/health';
  static const String backupsHistory = '/backups/history';
  static const String backupsRun = '/backups/run';
  static const String backupsConfig = '/backups/config';
  static const String backupsDriveAuth = '/backups/drive/auth';
  static const String backupsDriveToken = '/backups/drive/token';
  static const String backupsDriveDisconnect = '/backups/drive/disconnect';

  // ──────────────────────────────────────────────
  // Dashboard
  // ──────────────────────────────────────────────
  static const String dashboard = '/dashboard/summary';

  // ──────────────────────────────────────────────
  // Customers
  // ──────────────────────────────────────────────
  static const String customers = '/customers';

  // ──────────────────────────────────────────────
  // Suppliers
  // ──────────────────────────────────────────────
  static const String suppliers = '/suppliers';
  static String supplierStatement(int supplierId) =>
      '$suppliers/$supplierId/statement';

  // ──────────────────────────────────────────────
  // Expenses
  // ──────────────────────────────────────────────
  static const String expenses = '/expenses';

  // ──────────────────────────────────────────────
  // Sales
  // ──────────────────────────────────────────────
  static const String sales = '/sales';

  // ──────────────────────────────────────────────
  // Purchases
  // ──────────────────────────────────────────────
  static const String purchases = '/purchases';
  static String purchaseStatus(int invoiceId) => '$purchases/$invoiceId/status';
  static String purchaseAttachment(int attachmentId) =>
      '$purchases/attachments/$attachmentId';

  // ──────────────────────────────────────────────
  // Bank Accounts
  // ──────────────────────────────────────────────
  static const String bankAccounts = '/bank-accounts';
  static String bankAccountUploadLogo(int bankAccountId) =>
      '$bankAccounts/$bankAccountId/logo';

  // ──────────────────────────────────────────────
  // Payments
  // ──────────────────────────────────────────────
  static const String payments = '/payments';

  // ──────────────────────────────────────────────
  // Returns
  // ──────────────────────────────────────────────
  static const String returns = '/returns';

  // ──────────────────────────────────────────────
  // Purchase Returns
  // ──────────────────────────────────────────────
  static const String purchaseReturns = '/purchase-returns';

  // ──────────────────────────────────────────────
  // Reports
  // ──────────────────────────────────────────────
  static const String reportsSales = '/reports/sales';
  static const String reportsPurchases = '/reports/purchases';
  static const String reportsSuppliers = '/reports/suppliers';
  static const String reportsCustomers = '/reports/customers';
  static const String reportsExpenses = '/reports/expenses';
  static const String reportsPayments = '/reports/payments';
  static const String reportsReturns = '/reports/returns';
  static const String reportsPurchaseReturns = '/reports/purchase-returns';
  static const String reportsFinancial = '/reports/financial';
  static const String reportsBankTransactions = '/reports/bank-transactions';
  static const String reportsBankAccounts = '/reports/bank-accounts';
  static const String reportsCustomerStatement = '/reports/customer-statement';
  static const String reportsSupplierStatement = '/reports/supplier-statement';
  static const String reportsStorePerformance = '/reports/store-performance';

  // ──────────────────────────────────────────────
  // User Sessions
  // ──────────────────────────────────────────────
  static const String userSessions = '/user-sessions';

  // ──────────────────────────────────────────────
  // User Devices
  // ──────────────────────────────────────────────
  static const String userDevices = '/user-devices';

  // ──────────────────────────────────────────────
  // Two Factor Auth
  // ──────────────────────────────────────────────
  static const String twoFactorAuths = '/two-factor-auths';

  // ──────────────────────────────────────────────
  // Wallets
  // ──────────────────────────────────────────────
  static const String wallets = '/wallets';
  static const String walletLogs = '/wallet-logs';

  // ──────────────────────────────────────────────
  // System Logs & Scheduled Tasks
  // ──────────────────────────────────────────────
  static const String systemLogs = '/system-logs';
  static const String scheduledTasks = '/scheduled-tasks';

  // ──────────────────────────────────────────────
  // User Permissions
  // ──────────────────────────────────────────────
  static const String userPermissions = '/user-permissions';

  // ──────────────────────────────────────────────
  // Bank Transactions
  // ──────────────────────────────────────────────
  static const String bankTransactions = '/bank-transactions';

  // ──────────────────────────────────────────────
  // QR Code (توليد موقّع للفواتير والسندات + تحقق)
  // ──────────────────────────────────────────────
  static const String qrKey = '/qr/key';
  static const String qrVerify = '/qr/verify';

  // ──────────────────────────────────────────────
  // Background Tasks / Cron & Queue Runner
  // ──────────────────────────────────────────────
  static const String cronRun = '/cron/run';
  static const String cronScheduler = '/cron/scheduler';
  static const String cronQueue = '/cron/queue';
}
