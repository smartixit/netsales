/// ============================================================================
/// ثوابت مفاتيح التخزين المحلي (Storage Keys)
/// ============================================================================
abstract final class StorageKeys {
  StorageKeys._();

  /// معرف الجلسة المعتمد لدى الخادم (X-Session-Id)
  static const String session = 'session_id';

  /// معرف المستخدم المسجل
  static const String userId = 'user_id';

  /// مفتاح تخزين الصلاحيات محلياً
  static const String permissionsStorage = 'user_permissions';

  /// بيانات المستخدم المخزنة كـ JSON
  static const String userData = 'user_data';

  /// حالة تسجيل الدخول
  static const String isLoggedIn = 'is_logged_in';

  /// أول تشغيل للتطبيق (Onboarding)
  static const String isFirstLaunch = 'is_first_launch';

  /// وضع الثيم: light | dark | system
  static const String themeMode = 'theme_mode';

  /// لغة التطبيق: ar | en
  static const String locale = 'locale';

  /// المفتاح العام السيادي للتشفير (X25519 Box Public Key)
  static const String serverBoxPublicKey = 'server_box_public_key';

  /// المفتاح العام السيادي للتحقق من التوقيع الرقمي (Ed25519 Sign Public Key)
  static const String serverSignPublicKey = 'server_sign_public_key';

  /// آخر رمز إشعارات فورية تم مزامنته مع الخادم بنجاح
  static const String fcmTokenStorage = 'fcm_token_storage';

  /// إعدادات النظام العامة المخزنة محلياً (Public Settings Cache)
  static const String publicSettings = 'public_settings_cache';

  /// مساحة العمل النشطة المحفوظة (network | pos)
  static const String activeWorkspaceKey = 'active_workspace_key';

  /// نقطة البيع النشطة لكل مستخدم.
  static const String activePosTenantPrefix = 'active_pos_tenant';

  /// الشبكة النشطة لكل مستخدم (Network Workspace Tenant).
  static const String activeNetworkTenantPrefix = 'active_network_tenant';

  /// بادئة تخزين الشبكة المختارة لكل مستخدم ونقطة بيع.
  static const String activePosNetworkPrefix = 'active_pos_network';

  /// آخر توقيت تم فيه تشغيل محرك استدراك مهام السيرفر بالملي ثانية
  static const String lastServerCatchupRun = 'last_server_catchup_run_ms';

  /// عدد مرات الفشل المتتالية لاستدعاء مهام السيرفر لحساب التراجع الأسي (Circuit Breaker)
  static const String serverCatchupFailuresCount = 'server_catchup_failures_count';
}
