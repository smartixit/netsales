/// بيئات التشغيل المدعومة.
enum AppEnv { dev, staging, prod }

/// تكوين البيئة — يحدد عنوان الـ API وسلوك التطبيق حسب البيئة.
///
/// يمكن التحكم بها عند البناء:
/// Flutter build apk --dart-define=APP_ENV=prod --dart-define=API_BASE_URL=https://...
class AppEnvironment {
  AppEnvironment._();

  static const String _envName = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'dev',
  );

  static const String _baseUrlOverride = String.fromEnvironment('API_BASE_URL');

  static AppEnv get current => switch (_envName) {
    'prod' => AppEnv.prod,
    'staging' => AppEnv.staging,
    _ => AppEnv.dev,
  };

  static bool get isProd => current == AppEnv.prod;
  static bool get isDev => current == AppEnv.dev;

  static const String _devBaseUrl = 'http://192.168.1.4:8000/api/v1';
  static const String _stagingBaseUrl =
      'https://staging.netsales.smartix.app/api/v1';
  static const String _prodBaseUrl = 'https://netsales.kesug.com/api/v1';

  /// عنوان الـ API الفعّال للبيئة الحالية.
  static String get apiBaseUrl {
    if (_baseUrlOverride.isNotEmpty) return _baseUrlOverride;
    return switch (current) {
      AppEnv.prod => _prodBaseUrl,
      AppEnv.staging => _stagingBaseUrl,
      AppEnv.dev => _devBaseUrl,
    };
  }

  /// تفعيل سجلات الشبكة والتشخيص (مُعطّل في الإنتاج).
  static bool get enableLogging => !isProd;

  /// السماح بالشهادات الذاتية — للتطوير المحلي فقط (خطر أمني في الإنتاج).
  static bool get allowBadCertificates => isDev;
}
