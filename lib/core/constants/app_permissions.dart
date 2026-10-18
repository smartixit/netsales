/// ============================================================================
/// ثوابت الصلاحيات والأدوار المعتمدة لنظام NetSales
/// ============================================================================
/// مطابقة 100% لمصفوفة الصلاحيات (PermissionSeeder) والأدوار (RoleKey) في netsales_api.
abstract final class AppRoles {
  AppRoles._();

  static const String superAdmin = 'SUPER_ADMIN';
  static const String networkOwner = 'NETWORK_OWNER';
  static const String networkUser = 'NETWORK_USER';
  static const String posAgent = 'POS_AGENT';
  static const String posUser = 'POS_USER';
  static const String supportAgent = 'SUPPORT_AGENT';
  static const String accountant = 'ACCOUNTANT';
}

abstract final class AppPermissions {
  AppPermissions._();

  // 1. الأمان والجلسات (auth)
  static const String authView = 'auth.view';
  static const String authManage = 'auth.manage';

  // 2. المستخدمون (users)
  static const String usersView = 'users.view';
  static const String usersCreate = 'users.create';
  static const String usersEdit = 'users.edit';
  static const String usersDelete = 'users.delete';
  static const String usersExport = 'users.export';

  // 3. الأدوار والصلاحيات (roles)
  static const String rolesView = 'roles.view';
  static const String rolesCreate = 'roles.create';
  static const String rolesEdit = 'roles.edit';
  static const String rolesDelete = 'roles.delete';
  static const String rolesManage = 'roles.manage';

  // 4. الجغرافيا والمواقع (geography)
  static const String geographyView = 'geography.view';
  static const String geographyCreate = 'geography.create';
  static const String geographyEdit = 'geography.edit';
  static const String geographyDelete = 'geography.delete';

  // 5. الشبكات (networks)
  static const String networksView = 'networks.view';
  static const String networksCreate = 'networks.create';
  static const String networksEdit = 'networks.edit';
  static const String networksDelete = 'networks.delete';
  static const String networksApprove = 'networks.approve';
  static const String networksReject = 'networks.reject';
  static const String networksReport = 'networks.report';
  static const String networksExport = 'networks.export';

  // 6. محافظ الشبكات (network_wallets)
  static const String networkWalletsView = 'network_wallets.view';
  static const String networkWalletsCreate = 'network_wallets.create';
  static const String networkWalletsEdit = 'network_wallets.edit';
  static const String networkWalletsReport = 'network_wallets.report';
  static const String networkWalletsExport = 'network_wallets.export';
  static const String networkWalletsManage = 'network_wallets.manage';

  // 7. نقاط البيع (pos)
  static const String posView = 'pos.view';
  static const String posCreate = 'pos.create';
  static const String posEdit = 'pos.edit';
  static const String posDelete = 'pos.delete';
  static const String posReport = 'pos.report';
  static const String posExport = 'pos.export';

  // 8. محافظ نقاط البيع (pos_wallets)
  static const String posWalletsView = 'pos_wallets.view';
  static const String posWalletsCreate = 'pos_wallets.create';
  static const String posWalletsEdit = 'pos_wallets.edit';
  static const String posWalletsReport = 'pos_wallets.report';
  static const String posWalletsExport = 'pos_wallets.export';
  static const String posWalletsManage = 'pos_wallets.manage';

  // 9. باقات الكروت (voucher_packages)
  static const String voucherPackagesView = 'voucher_packages.view';
  static const String voucherPackagesCreate = 'voucher_packages.create';
  static const String voucherPackagesEdit = 'voucher_packages.edit';
  static const String voucherPackagesDelete = 'voucher_packages.delete';
  static const String voucherPackagesExport = 'voucher_packages.export';

  // 10. طلبات الكروت والتعبئة (requests)
  static const String requestsView = 'requests.view';
  static const String requestsCreate = 'requests.create';
  static const String requestsEdit = 'requests.edit';
  static const String requestsDelete = 'requests.delete';
  static const String requestsApprove = 'requests.approve';
  static const String requestsReject = 'requests.reject';
  static const String requestsReport = 'requests.report';

  // 11. المبيعات وفواتير البيع (sales)
  static const String salesView = 'sales.view';
  static const String salesCreate = 'sales.create';
  static const String salesEdit = 'sales.edit';
  static const String salesReport = 'sales.report';
  static const String salesExport = 'sales.export';

  // 12. المصروفات وسندات الصرف (expenses)
  static const String expensesView = 'expenses.view';
  static const String expensesCreate = 'expenses.create';
  static const String expensesEdit = 'expenses.edit';
  static const String expensesDelete = 'expenses.delete';
  static const String expensesApprove = 'expenses.approve';
  static const String expensesReport = 'expenses.report';
  static const String expensesExport = 'expenses.export';

  // 13. اشتراكات المزودين وباقاتها (subscriptions)
  static const String subscriptionsView = 'subscriptions.view';
  static const String subscriptionsCreate = 'subscriptions.create';
  static const String subscriptionsEdit = 'subscriptions.edit';
  static const String subscriptionsDelete = 'subscriptions.delete';
  static const String subscriptionsApprove = 'subscriptions.approve';
  static const String subscriptionsReject = 'subscriptions.reject';
  static const String subscriptionsReport = 'subscriptions.report';

  // 14. الحسابات البنكية ومحافظ السداد (bank_accounts)
  static const String bankAccountsView = 'bank_accounts.view';
  static const String bankAccountsCreate = 'bank_accounts.create';
  static const String bankAccountsEdit = 'bank_accounts.edit';
  static const String bankAccountsDelete = 'bank_accounts.delete';
  static const String bankAccountsManage = 'bank_accounts.manage';

  // 15. تذاكر الدعم والشكاوى (support)
  static const String supportView = 'support.view';
  static const String supportCreate = 'support.create';
  static const String supportEdit = 'support.edit';
  static const String supportDelete = 'support.delete';
  static const String supportManage = 'support.manage';

  // 16. سجل الإشعارات (notifications)
  static const String notificationsView = 'notifications.view';
  static const String notificationsCreate = 'notifications.create';
  static const String notificationsDelete = 'notifications.delete';

  // 17. سجلات النظام والتدقيق (system_logs)
  static const String systemLogsView = 'system_logs.view';
  static const String systemLogsExport = 'system_logs.export';
  static const String systemLogsDelete = 'system_logs.delete';

  // 18. إعدادات النظام (settings)
  static const String settingsView = 'settings.view';
  static const String settingsEdit = 'settings.edit';
  static const String settingsManage = 'settings.manage';
}
