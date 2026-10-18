import 'package:netsales/core/config/app_environment.dart';

/// ============================================================================
/// ثوابت مسارات واجهة برمجة التطبيقات (NetSales API V1 Endpoints)
/// ============================================================================
/// موثقة ومطابقة 100% لمسارات الباك إند المعتمدة في netsales_api (routes/api.php).
/// مصنفة حسب القطاعات الوظيفية مع دوال مساعدة للمسارات الديناميكية (Parameterized).
abstract final class ApiConstants {
  ApiConstants._();

  /// عنوان الـ API الأساسي — يُشتق ديناميكياً من بيئة التشغيل الحالية
  static String get baseUrl => AppEnvironment.apiBaseUrl;

  // ── مهلات الاتصال (Timeouts in milliseconds) ──
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 30000;
  static const int sendTimeout = 30000;

  // ==========================================================================
  // 1. البيانات المرجعية وصحة النظام والملفات (Reference, Health & Public Files)
  // ==========================================================================
  static const String healthCheck = '/auth/health-check';
  static String file(String path) => '/files/$path';
  static String signedFile(String path) => '/files/signed/$path';

  // ==========================================================================
  // 2. المصادقة والجلسات والحساب الشخصي (Authentication & Profile)
  // ==========================================================================
  static const String login = '/auth/login';
  static const String registerNetwork = '/auth/register-network';
  static const String registerPos = '/auth/register-pos';
  static const String register = '/auth/register';
  static const String passwordRequestReset = '/auth/password/request-reset';
  static const String passwordVerifyOtp = '/auth/password/verify-otp';
  static const String passwordReset = '/auth/password/reset';
  static const String verify2fa = '/auth/2fa/verify';
  static const String logout = '/auth/logout';
  static const String logoutOtherDevices = '/auth/logout-other-devices';
  static const String me = '/auth/me';
  static const String updatePassword = '/auth/update-password';
  static const String toggle2fa = '/auth/toggle-2fa';
  static const String authDevices = '/auth/devices';
  static String disconnectDevice(int id) => '/auth/devices/$id';

  // ==========================================================================
  // 3. خدمات التحقق بالرمز المؤقت (OTP Verification)
  // ==========================================================================
  static const String otpGenerate = '/otp/generate';
  static const String otpVerify = '/otp/verify';
  static const String otpResend = '/otp/resend';

  // ==========================================================================
  // 4. إدارة المستخدمين والحسابات (Users Management)
  // ==========================================================================
  static const String users = '/users';
  static const String usersTrashed = '/users/trashed';
  static String user(int id) => '/users/$id';
  static String userPermissions(int id) => '/users/$id/permissions';
  static String userProfilePicture(int id) => '/users/$id/profile-picture';
  static String userRestore(int id) => '/users/$id/restore';
  static String userForceDelete(int id) => '/users/$id/force';
  static const String usersBatchDelete = '/users/batch-delete';
  static const String usersBatchRestore = '/users/batch-restore';
  static const String usersBatchForceDelete = '/users/batch-force-delete';

  // ==========================================================================
  // 5. الأمان والمفاتيح الرقمية السيادية (Security & Sovereign Public Keys)
  // ==========================================================================
  static const String securityPublicKeys = '/security/public-keys';
  static String securityUserSessions(int userId) =>
      '/security/users/$userId/sessions';
  static String securityUserDevices(int userId) =>
      '/security/users/$userId/devices';
  static const String securityBanUser = '/security/bans/users';
  static const String securityBanDevice = '/security/bans/devices';
  static String securityUnban(int banId) => '/security/bans/$banId/unban';
  static String securityTerminateSession(int sessionId) =>
      '/security/sessions/$sessionId/terminate';

  // ==========================================================================
  // 6. إدارة مزودي الشبكات (Networks Management)
  // ==========================================================================
  static const String networks = '/networks';
  static const String networksTrashed = '/networks/trashed';
  static String network(int id) => '/networks/$id';
  static String networkApprove(int id) => '/networks/$id/approve';
  static String networkReject(int id) => '/networks/$id/reject';
  static String networkRestore(int id) => '/networks/$id/restore';
  static String networkForceDelete(int id) => '/networks/$id/force';
  static String networkPosList(int id) => '/networks/$id/pos';
  static String networkVoucherPackages(int id) =>
      '/networks/$id/voucher-packages';
  static const String networksBatchDelete = '/networks/batch-delete';
  static const String networksBatchRestore = '/networks/batch-restore';
  static const String networksBatchForceDelete = '/networks/batch-force-delete';

  // ==========================================================================
  // 7. إدارة نقاط البيع والوكلاء (POS Management)
  // ==========================================================================
  static const String pos = '/pos';
  static const String posTrashed = '/pos/trashed';
  static String posItem(int id) => '/pos/$id';
  static String posApprove(int id) => '/pos/$id/approve';
  static String posReject(int id) => '/pos/$id/reject';
  static String posRestore(int id) => '/pos/$id/restore';
  static String posForceDelete(int id) => '/pos/$id/force';
  static String posNetworksList(int id) => '/pos/$id/networks';
  static const String posBatchDelete = '/pos/batch-delete';
  static const String posBatchRestore = '/pos/batch-restore';
  static const String posBatchForceDelete = '/pos/batch-force-delete';

  // ==========================================================================
  // 8. ربط نقاط البيع بالشبكات (Network POS Links)
  // ==========================================================================
  static const String networkPos = '/network-pos';
  static String networkPosItem(int id) => '/network-pos/$id';
  static String networkPosToggleStatus(int id) =>
      '/network-pos/$id/toggle-status';
  static const String networkPosBatchDelete = '/network-pos/batch-delete';
  static const String networkPosBatchStatus = '/network-pos/batch-status';

  // ==========================================================================
  // 9. باقات كروت الإنترنت (Voucher Packages)
  // ==========================================================================
  static const String voucherPackages = '/voucher-packages';
  static const String voucherPackagesTrashed = '/voucher-packages/trashed';
  static String voucherPackage(int id) => '/voucher-packages/$id';
  static String voucherPackageToggleStatus(int id) =>
      '/voucher-packages/$id/toggle-status';
  static String voucherPackageRestore(int id) =>
      '/voucher-packages/$id/restore';
  static String voucherPackageForceDelete(int id) =>
      '/voucher-packages/$id/force';
  static const String voucherPackagesBatchDelete =
      '/voucher-packages/batch-delete';
  static const String voucherPackagesBatchRestore =
      '/voucher-packages/batch-restore';
  static const String voucherPackagesBatchForceDelete =
      '/voucher-packages/batch-force-delete';

  // ==========================================================================
  // 10. خصومات الباقات لنقاط البيع (Voucher Package Discounts)
  // ==========================================================================
  static const String voucherPackageDiscounts = '/voucher-package-discounts';
  static const String voucherPackageDiscountsTrashed =
      '/voucher-package-discounts/trashed';
  static const String voucherPackageDiscountsEffective =
      '/voucher-package-discounts/effective';
  static String voucherPackageDiscount(int id) =>
      '/voucher-package-discounts/$id';
  static String voucherPackageDiscountToggleStatus(int id) =>
      '/voucher-package-discounts/$id/toggle-status';
  static String voucherPackageDiscountRestore(int id) =>
      '/voucher-package-discounts/$id/restore';
  static String voucherPackageDiscountForceDelete(int id) =>
      '/voucher-package-discounts/$id/force';
  static const String voucherPackageDiscountsBatchDelete =
      '/voucher-package-discounts/batch-delete';
  static const String voucherPackageDiscountsBatchRestore =
      '/voucher-package-discounts/batch-restore';
  static const String voucherPackageDiscountsBatchForceDelete =
      '/voucher-package-discounts/batch-force-delete';

  // ==========================================================================
  // 11. محافظ مزودي الشبكات ودفتر الأستاذ (Network Wallets & Ledger)
  // ==========================================================================
  static const String networkWallets = '/network-wallets';
  static const String networkWalletsTrashed = '/network-wallets/trashed';
  static String networkWallet(int id) => '/network-wallets/$id';
  static String networkWalletLogs(int id) => '/network-wallets/$id/logs';
  static String networkWalletByNetwork(int networkId) =>
      '/network-wallets/network/$networkId';
  static String networkWalletDeposit(int id) => '/network-wallets/$id/deposit';
  static String networkWalletWithdraw(int id) =>
      '/network-wallets/$id/withdraw';
  static String networkWalletRestore(int id) => '/network-wallets/$id/restore';
  static String networkWalletForceDelete(int id) =>
      '/network-wallets/$id/force';
  static const String networkWalletsBatchDelete =
      '/network-wallets/batch-delete';
  static const String networkWalletsBatchRestore =
      '/network-wallets/batch-restore';
  static const String networkWalletsBatchForceDelete =
      '/network-wallets/batch-force-delete';

  // ==========================================================================
  // 12. محافظ نقاط البيع والتحويلات المالية (POS Wallets & Transfers)
  // ==========================================================================
  static const String posWallets = '/pos-wallets';
  static const String posWalletsTrashed = '/pos-wallets/trashed';
  static String posWallet(int id) => '/pos-wallets/$id';
  static String posWalletLogs(int id) => '/pos-wallets/$id/logs';
  static String posWalletByNetworkPos(int networkId, int posId) =>
      '/pos-wallets/network/$networkId/pos/$posId';
  static String posWalletDeposit(int id) => '/pos-wallets/$id/deposit';
  static String posWalletWithdraw(int id) => '/pos-wallets/$id/withdraw';
  static const String posWalletTransferFromNetwork =
      '/pos-wallets/transfer-from-network';
  static const String posWalletTransferToNetwork =
      '/pos-wallets/transfer-to-network';
  static String posWalletRestore(int id) => '/pos-wallets/$id/restore';
  static String posWalletForceDelete(int id) => '/pos-wallets/$id/force';
  static const String posWalletsBatchDelete = '/pos-wallets/batch-delete';
  static const String posWalletsBatchRestore = '/pos-wallets/batch-restore';
  static const String posWalletsBatchForceDelete =
      '/pos-wallets/batch-force-delete';

  // ==========================================================================
  // 13. طلبات شراء كروت الإنترنت (Voucher Requests)
  // ==========================================================================
  static const String voucherRequests = '/requests';
  static const String voucherRequestsTrashed = '/requests/trashed';
  static String voucherRequest(int id) => '/requests/$id';
  static String voucherRequestApprove(int id) => '/requests/$id/approve';
  static String voucherRequestReject(int id) => '/requests/$id/reject';
  static String voucherRequestCancel(int id) => '/requests/$id/cancel';
  static String voucherRequestRestore(int id) => '/requests/$id/restore';
  static String voucherRequestForceDelete(int id) => '/requests/$id/force';
  static const String voucherRequestsBatchDelete = '/requests/batch-delete';
  static const String voucherRequestsBatchRestore = '/requests/batch-restore';
  static const String voucherRequestsBatchForceDelete =
      '/requests/batch-force-delete';

  // ==========================================================================
  // 14. فواتير مبيعات الكروت (Sale Invoices)
  // ==========================================================================
  static const String saleInvoices = '/sale-invoices';
  static const String saleInvoicesTrashed = '/sale-invoices/trashed';
  static String saleInvoice(int id) => '/sale-invoices/$id';
  static String saleInvoiceRestore(int id) => '/sale-invoices/$id/restore';
  static String saleInvoiceForceDelete(int id) => '/sale-invoices/$id/force';
  static const String saleInvoicesBatchDelete = '/sale-invoices/batch-delete';
  static const String saleInvoicesBatchRestore = '/sale-invoices/batch-restore';
  static const String saleInvoicesBatchForceDelete =
      '/sale-invoices/batch-force-delete';

  // ==========================================================================
  // 15. المصروفات التشغيلية والبنود والمرفقات (Expenses & Operational Disbursals)
  // ==========================================================================
  static const String expenses = '/expenses';
  static const String expensesTrashed = '/expenses/trashed';
  static String expense(int id) => '/expenses/$id';
  static String expenseRestore(int id) => '/expenses/$id/restore';
  static String expenseForceDelete(int id) => '/expenses/$id/force';
  static String expenseAddItem(int id) => '/expenses/$id/items';
  static String expenseDeleteItem(int id, int itemId) =>
      '/expenses/$id/items/$itemId';
  static String expenseDeleteAttachment(int id, int attachmentId) =>
      '/expenses/$id/attachments/$attachmentId';
  static const String expensesBatchDelete = '/expenses/batch-delete';
  static const String expensesBatchRestore = '/expenses/batch-restore';
  static const String expensesBatchForceDelete = '/expenses/batch-force-delete';

  // ==========================================================================
  // 16. باقات الاشتراك السحابية لمزودي الشبكات (Subscription Plans)
  // ==========================================================================
  static const String subscriptionPlans = '/subscription-plans';
  static const String subscriptionPlansTrashed = '/subscription-plans/trashed';
  static String subscriptionPlan(int id) => '/subscription-plans/$id';
  static String subscriptionPlanToggleStatus(int id) =>
      '/subscription-plans/$id/toggle-status';
  static String subscriptionPlanAttachFeature(int id) =>
      '/subscription-plans/$id/features';
  static String subscriptionPlanDetachFeature(int id, int featureId) =>
      '/subscription-plans/$id/features/$featureId';
  static String subscriptionPlanRestore(int id) =>
      '/subscription-plans/$id/restore';
  static String subscriptionPlanForceDelete(int id) =>
      '/subscription-plans/$id/force';
  static const String subscriptionPlansBatchDelete =
      '/subscription-plans/batch-delete';
  static const String subscriptionPlansBatchRestore =
      '/subscription-plans/batch-restore';
  static const String subscriptionPlansBatchForceDelete =
      '/subscription-plans/batch-force-delete';

  // ==========================================================================
  // 17. كتالوج ميزات النظام (System Features)
  // ==========================================================================
  static const String features = '/features';
  static const String featuresTrashed = '/features/trashed';
  static String feature(int id) => '/features/$id';
  static String featureToggleStatus(int id) => '/features/$id/toggle-status';
  static String featureRestore(int id) => '/features/$id/restore';
  static String featureForceDelete(int id) => '/features/$id/force';
  static const String featuresBatchDelete = '/features/batch-delete';
  static const String featuresBatchRestore = '/features/batch-restore';
  static const String featuresBatchForceDelete = '/features/batch-force-delete';

  // ==========================================================================
  // 18. الحسابات البنكية والمحافظ (Bank Accounts)
  // ==========================================================================
  static const String bankAccounts = '/bank-accounts';
  static const String bankAccountsActive = '/bank-accounts/active';
  static const String bankAccountsTrashed = '/bank-accounts/trashed';
  static String bankAccount(int id) => '/bank-accounts/$id';
  static String bankAccountToggleStatus(int id) =>
      '/bank-accounts/$id/toggle-status';
  static String bankAccountRestore(int id) => '/bank-accounts/$id/restore';
  static String bankAccountForceDelete(int id) => '/bank-accounts/$id/force';
  static const String bankAccountsBatchDelete = '/bank-accounts/batch-delete';
  static const String bankAccountsBatchRestore = '/bank-accounts/batch-restore';
  static const String bankAccountsBatchForceDelete =
      '/bank-accounts/batch-force-delete';

  // ==========================================================================
  // 19. طلبات الاشتراك والترقية (Subscription Plan Requests)
  // ==========================================================================
  static const String subscriptionPlanRequests = '/subscription-plan-requests';
  static const String subscriptionPlanRequestsTrashed =
      '/subscription-plan-requests/trashed';
  static String subscriptionPlanRequest(int id) =>
      '/subscription-plan-requests/$id';
  static String subscriptionPlanRequestApprove(int id) =>
      '/subscription-plan-requests/$id/approve';
  static String subscriptionPlanRequestReject(int id) =>
      '/subscription-plan-requests/$id/reject';
  static String subscriptionPlanRequestCancel(int id) =>
      '/subscription-plan-requests/$id/cancel';
  static String subscriptionPlanRequestRestore(int id) =>
      '/subscription-plan-requests/$id/restore';
  static String subscriptionPlanRequestForceDelete(int id) =>
      '/subscription-plan-requests/$id/force';
  static const String subscriptionPlanRequestsBatchDelete =
      '/subscription-plan-requests/batch-delete';
  static const String subscriptionPlanRequestsBatchRestore =
      '/subscription-plan-requests/batch-restore';
  static const String subscriptionPlanRequestsBatchForceDelete =
      '/subscription-plan-requests/batch-force-delete';

  // ==========================================================================
  // 20. اشتراكات مزودي الشبكات وتتبع الحصص (Provider Subscriptions & Feature Quotas)
  // ==========================================================================
  static const String providerSubscriptions = '/provider-subscriptions';
  static String providerSubscription(int id) => '/provider-subscriptions/$id';
  static String providerSubscriptionActiveForNetwork(int networkId) =>
      '/provider-subscriptions/network/$networkId/active';
  static String providerSubscriptionConsumptions(int id) =>
      '/provider-subscriptions/$id/consumptions';
  static String providerSubscriptionExtend(int id) =>
      '/provider-subscriptions/$id/extend';
  static String providerSubscriptionConsume(int networkId) =>
      '/provider-subscriptions/network/$networkId/consume';
  static String providerSubscriptionActivateEarly(int networkId) =>
      '/provider-subscriptions/network/$networkId/activate-early';

  // ==========================================================================
  // 21. تذاكر الدعم الفني والمراسلات (Support Tickets & Communications)
  // ==========================================================================
  static const String supportTickets = '/support-tickets';
  static const String supportTicketsTrashed = '/support-tickets/trashed';
  static String supportTicket(int id) => '/support-tickets/$id';
  static String supportTicketMessages(int id) =>
      '/support-tickets/$id/messages';
  static String supportTicketMarkAsRead(int id) => '/support-tickets/$id/read';
  static String supportTicketRestore(int id) => '/support-tickets/$id/restore';
  static String supportTicketForceDelete(int id) =>
      '/support-tickets/$id/force';
  static const String supportTicketsBatchDelete =
      '/support-tickets/batch-delete';
  static const String supportTicketsBatchRestore =
      '/support-tickets/batch-restore';
  static const String supportTicketsBatchForceDelete =
      '/support-tickets/batch-force-delete';

  // ==========================================================================
  // 22. الإشعارات والتنبيهات الموجهة (Notifications Engine)
  // ==========================================================================
  static const String notifications = '/notifications';
  static const String notificationsMy = '/notifications/my';
  static const String notificationsUnreadCount = '/notifications/unread-count';
  static const String notificationsTrashed = '/notifications/trashed';
  static String notification(int id) => '/notifications/$id';
  static String notificationMarkAsRead(int id) => '/notifications/$id/read';
  static const String notificationsMarkAllRead = '/notifications/mark-all-read';
  static const String notificationFcmToken = '/notifications/fcm-token';
  static String notificationRestore(int id) => '/notifications/$id/restore';
  static String notificationForceDelete(int id) => '/notifications/$id/force';
  static const String notificationsBatchDelete = '/notifications/batch-delete';
  static const String notificationsBatchRestore =
      '/notifications/batch-restore';
  static const String notificationsBatchForceDelete =
      '/notifications/batch-force-delete';

  // ==========================================================================
  // 23. إعدادات النظام وتهيئة البيئة (System Settings & Engine Configuration)
  // ==========================================================================
  static const String systemSettings = '/system-settings';
  static const String systemSettingsTrashed = '/system-settings/trashed';
  static String systemSettingsByCategory(String category) =>
      '/system-settings/category/$category';
  static String systemSettingsByKey(String key) => '/system-settings/key/$key';
  static String systemSetting(int id) => '/system-settings/$id';
  static const String systemSettingsBatchUpdate =
      '/system-settings/batch-update';
  static const String systemSettingsClearCache = '/system-settings/clear-cache';
  static String systemSettingRestore(int id) => '/system-settings/$id/restore';
  static String systemSettingForceDelete(int id) =>
      '/system-settings/$id/force';
  static const String systemSettingsBatchDelete =
      '/system-settings/batch-delete';
  static const String systemSettingsBatchRestore =
      '/system-settings/batch-restore';
  static const String systemSettingsBatchForceDelete =
      '/system-settings/batch-force-delete';

  // ==========================================================================
  // 24. سجلات تدقيق النظام والتتبع الأمني (System Audit Logs & Activity Trails)
  // ==========================================================================
  static const String systemLogs = '/system-logs';
  static const String systemLogsStats = '/system-logs/stats';
  static const String systemLogsModules = '/system-logs/modules';
  static const String systemLogsActions = '/system-logs/actions';
  static String systemLogsByEntity(String entityType, int entityId) =>
      '/system-logs/entity/$entityType/$entityId';
  static String systemLogsByUser(int userId) => '/system-logs/user/$userId';
  static String systemLog(int id) => '/system-logs/$id';

  // ==========================================================================
  // 25. المحرك الجغرافي: المحافظات والمديريات (Geography Engine)
  // ==========================================================================
  static const String governorates = '/governorates';
  static const String governoratesCounts = '/governorates/counts';
  static const String governoratesTrashed = '/governorates/trashed';
  static String governorate(int id) => '/governorates/$id';
  static String governorateRestore(int id) => '/governorates/$id/restore';
  static String governorateForceDelete(int id) => '/governorates/$id/force';
  static const String governoratesBatchDelete = '/governorates/batch-delete';
  static const String governoratesBatchRestore = '/governorates/batch-restore';
  static const String governoratesBatchForceDelete =
      '/governorates/batch-force-delete';

  static const String directorates = '/directorates';
  static const String directoratesTrashed = '/directorates/trashed';
  static String directoratesByGovernorate(int governorateId) =>
      '/directorates/governorate/$governorateId';
  static String directorate(int id) => '/directorates/$id';
  static String directorateRestore(int id) => '/directorates/$id/restore';
  static String directorateForceDelete(int id) => '/directorates/$id/force';
  static const String directoratesBatchDelete = '/directorates/batch-delete';
  static const String directoratesBatchRestore = '/directorates/batch-restore';
  static const String directoratesBatchForceDelete =
      '/directorates/batch-force-delete';

  // ==========================================================================
  // 26. إعدادات وبوابات الرسائل النصية للشبكات (Network SMS Settings)
  // ==========================================================================
  static const String smsSettingsOverview = '/sms-settings';
  static String smsSettingsNetwork(int id) => '/sms-settings/networks/$id';
  static const String smsSettingsUpdateGlobal = '/sms-settings/global';
  static String smsSettingsTest(int id) => '/sms-settings/networks/$id/test';

  // ==========================================================================
  // 27. محرك النسخ الاحتياطي السحابي (Cloud Backup & Disaster Recovery)
  // ==========================================================================
  static const String backups = '/backups';
  static const String backupsSettings = '/backups/settings';
  static const String backupsHealth = '/backups/health';
  static const String backupsDriveAuth = '/backups/drive/auth';
  static const String backupsDriveToken = '/backups/drive/token';
  static const String backupsDriveDisconnect = '/backups/drive/disconnect';
  static const String backupsConfig = '/backups/config';
  static const String backupsRun = '/backups/run';
  static String backup(int id) => '/backups/$id';

  // ==========================================================================
  // 28. سجلات ومحرك المهام المجدولة (Scheduled Tasks Engine)
  // ==========================================================================
  static const String scheduledTasks = '/scheduled-tasks';
  static const String scheduledTasksStats = '/scheduled-tasks/stats';
  static const String scheduledTasksCatchup = '/scheduled-tasks/catchup';

  // ==========================================================================
  // 29. إشعارات ورسائل الإدارة الموجهة (Admin Multi-Channel Notifications)
  // ==========================================================================
  static const String adminNotificationsSend = '/admin/notifications/send';
  static const String adminNotificationsUser = '/admin/notifications/user';
}
