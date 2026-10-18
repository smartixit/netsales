/// ============================================================================
/// ثوابت مفاتيح التخزين المحلي (Storage Keys)
/// ============================================================================
abstract final class StorageKeys {
  StorageKeys._();

  /// معرف الجلسة المعتمد لدى الخادم (X-Session-Id)
  static const String session = 'session_id';

  /// المعرف الفريد للجهاز (X-Device-Uuid)
  static const String deviceUuid = 'device_uuid';

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
}
