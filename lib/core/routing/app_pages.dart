import 'package:get/get.dart';
import 'package:netsales/core/constants/app_permissions.dart';
import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/routing/middlewares/auth_guard.dart';
import 'package:netsales/core/routing/middlewares/workspace_guard.dart';
import 'package:netsales/features/auth/presentation/bindings/forgot_password_binding.dart';
import 'package:netsales/features/auth/presentation/bindings/login_binding.dart';
import 'package:netsales/features/auth/presentation/bindings/register_network_binding.dart';
import 'package:netsales/features/auth/presentation/bindings/register_pos_binding.dart';
import 'package:netsales/features/auth/presentation/bindings/reset_password_binding.dart';
import 'package:netsales/features/auth/presentation/bindings/two_factor_auth_binding.dart';
import 'package:netsales/features/auth/presentation/bindings/verify_otp_binding.dart';
import 'package:netsales/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:netsales/features/auth/presentation/screens/login_screen.dart';
import 'package:netsales/features/auth/presentation/screens/register_network_screen.dart';
import 'package:netsales/features/auth/presentation/screens/register_pos_screen.dart';
import 'package:netsales/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:netsales/features/auth/presentation/screens/two_factor_auth_screen.dart';
import 'package:netsales/features/auth/presentation/screens/unsupported_platform_screen.dart';
import 'package:netsales/features/auth/presentation/screens/verify_otp_screen.dart';
import 'package:netsales/features/debts/presentation/bindings/network_debts_binding.dart';
import 'package:netsales/features/debts/presentation/screens/network_debts_screen.dart';
import 'package:netsales/features/home/presentation/bindings/home_layout_binding.dart';
import 'package:netsales/features/home/presentation/bindings/workspace_bindings.dart';
import 'package:netsales/features/home/presentation/screens/home_layout_screen.dart';
import 'package:netsales/features/home/presentation/screens/network_workspace_shell.dart';
import 'package:netsales/features/home/presentation/screens/pos_workspace_shell.dart';
import 'package:netsales/features/onboarding/presentation/bindings/onboarding_binding.dart';
import 'package:netsales/features/onboarding/presentation/bindings/welcome_binding.dart';
import 'package:netsales/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:netsales/features/onboarding/presentation/screens/welcome_screen.dart';
import 'package:netsales/features/operations/presentation/bindings/operations_binding.dart';
import 'package:netsales/features/operations/presentation/screens/new_procurement_order_screen.dart';
import 'package:netsales/features/operations/presentation/screens/sale_invoice_details_screen.dart';
import 'package:netsales/features/operations/presentation/screens/voucher_request_details_screen.dart';
import 'package:netsales/features/packages/presentation/bindings/packages_binding.dart';
import 'package:netsales/features/packages/presentation/screens/voucher_packages_hub_screen.dart';
import 'package:netsales/features/splash/presentation/bindings/splash_binding.dart';
import 'package:netsales/features/splash/presentation/screens/splash_screen.dart';
import 'package:netsales/features/wallets/presentation/bindings/network_wallet_binding.dart';
import 'package:netsales/features/wallets/presentation/bindings/pos_wallet_binding.dart';
import 'package:netsales/features/wallets/presentation/screens/network_wallet_statement_screen.dart';
import 'package:netsales/features/wallets/presentation/screens/pos_wallet_statement_screen.dart';
import 'package:netsales/widgets/feedback/custom_not_found.dart';
import 'package:netsales/widgets/feedback/custom_unauthorized.dart';

/// ============================================================================
/// سجل صفحات ومسارات التطبيق (Application Pages Register)
/// ============================================================================
/// يحتوي على قائمة مسارات GetPage وروابطها مع الـ Bindings والـ Middlewares.
/// تم وضع الصفحات المستقبلية في حالة تعليق مؤقتاً لحين بناء واجهات كل ميزة.
abstract final class AppPages {
  AppPages._();

  static const String initial = AppRoutes.initial;

  static final List<GetPage<dynamic>> routes = [
    // 1. مسار البداية والفحص الأولي (Splash)
    GetPage(
      name: AppRoutes.initial,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
    ),

    // Not Found
    GetPage(name: AppRoutes.notFound, page: () => const CustomNotFound()),

    // Unauthorized Access Rejection (Deep Link Defense)
    GetPage(
      name: AppRoutes.unauthorized,
      page: () => const CustomUnauthorized(),
    ),

    // ========================================================================
    // 2. جولة التعريف والترحيب (Onboarding & Welcome)
    // ========================================================================
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingScreen(),
      binding: OnboardingBinding(),
      middlewares: [GuestGuard()],
    ),
    GetPage(
      name: AppRoutes.welcome,
      page: () => const WelcomeScreen(),
      binding: WelcomeBinding(),
      middlewares: [GuestGuard()],
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: LoginBinding(),
      middlewares: [GuestGuard()],
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordScreen(),
      binding: ForgotPasswordBinding(),
      middlewares: [GuestGuard()],
    ),
    GetPage(
      name: AppRoutes.verifyOtp,
      page: () => const VerifyOtpScreen(),
      binding: VerifyOtpBinding(),
    ),
    GetPage(
      name: AppRoutes.resetPassword,
      page: () => const ResetPasswordScreen(),
      binding: ResetPasswordBinding(),
    ),
    GetPage(
      name: AppRoutes.twoFactorAuth,
      page: () => const TwoFactorAuthScreen(),
      binding: TwoFactorAuthBinding(),
    ),
    GetPage(
      name: AppRoutes.registerNetwork,
      page: () => const RegisterNetworkScreen(),
      binding: RegisterNetworkBinding(),
      middlewares: [GuestGuard()],
    ),
    GetPage(
      name: AppRoutes.registerPos,
      page: () => const RegisterPosScreen(),
      binding: RegisterPosBinding(),
      middlewares: [GuestGuard()],
    ),
  ];
}
