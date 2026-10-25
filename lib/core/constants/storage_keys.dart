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

  /// سياق الشبكة ونقطة البيع النشطة للمزود والوكيل
  static const String activeNetworkId = 'active_network_id';
  static const String activePosId = 'active_pos_id';
  static const String activeNetworkName = 'active_network_name';
  static const String activePosName = 'active_pos_name';
}

