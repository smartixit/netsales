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

  // مسار الرفض والتنبيه الأمني
  static const String unauthorized = '/unauthorized';

  // Not Found
  static const String notFound = '/not-found';
}
