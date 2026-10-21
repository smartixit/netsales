import 'package:get/get.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/routing/middlewares/auth_guard.dart';
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
import 'package:netsales/features/auth/presentation/screens/verify_otp_screen.dart';
import 'package:netsales/features/onboarding/presentation/bindings/onboarding_binding.dart';
import 'package:netsales/features/onboarding/presentation/bindings/welcome_binding.dart';
import 'package:netsales/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:netsales/features/onboarding/presentation/screens/welcome_screen.dart';
import 'package:netsales/features/splash/presentation/bindings/splash_binding.dart';
import 'package:netsales/features/splash/presentation/screens/splash_screen.dart';
import 'package:netsales/widgets/custom_not_found.dart';
import 'package:netsales/widgets/custom_unauthorized.dart';

/// ============================================================================
/// سجل صفحات ومسارات التطبيق (Application Pages Register)
/// ============================================================================
/// يحتوي على قائمة مسارات GetPage وروابطها مع الـ Bindings والـ Middlewares.
/// تم وضع الصفحات المستقبلية في حالة تعليق مؤقتاً لحين بناء واجهات كل ميزة.
abstract final class AppPages {
  AppPages._();

  static const String initial = AppRoutes.initial;

  static final List<GetPage> routes = [
    // 1. مسار البداية والفحص الأولي (Splash)
    GetPage(
      name: AppRoutes.initial,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.splash,
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

    // ========================================================================
    // 3. المسارات الرئيسية المحمية (Dashboard & Home Layout)
    // ========================================================================
    // GetPage(
    //   name: AppRoutes.dashboard,
    //   page: () => const DashboardScreen(),
    //   binding: DashboardBinding(),
    //   middlewares: [AuthGuard()],
    // ),
    // GetPage(
    //   name: AppRoutes.homeLayout,
    //   page: () => const HomeLayoutScreen(),
    //   binding: HomeLayoutBinding(),
    //   middlewares: [AuthGuard()],
    // ),

    // ========================================================================
    // 4. قطاع الشبكات ومحافظها (Networks & Wallets)
    // ========================================================================
    // GetPage(
    //   name: AppRoutes.networks,
    //   page: () => const NetworksScreen(),
    //   binding: NetworksBinding(),
    //   middlewares: [
    //     AuthGuard(),
    //     PermissionGuardMiddleware(requiredPermission: AppPermissions.networksView),
    //   ],
    // ),
    // GetPage(
    //   name: AppRoutes.networkWallets,
    //   page: () => const NetworkWalletsScreen(),
    //   binding: NetworkWalletsBinding(),
    //   middlewares: [
    //     AuthGuard(),
    //     PermissionGuardMiddleware(requiredPermission: AppPermissions.networkWalletsView),
    //   ],
    // ),

    // ========================================================================
    // 5. قطاع نقاط البيع ومحافظها (POS & Wallets)
    // ========================================================================
    // GetPage(
    //   name: AppRoutes.pos,
    //   page: () => const PosScreen(),
    //   binding: PosBinding(),
    //   middlewares: [
    //     AuthGuard(),
    //     PermissionGuardMiddleware(requiredPermission: AppPermissions.posView),
    //   ],
    // ),
    // GetPage(
    //   name: AppRoutes.posWallets,
    //   page: () => const PosWalletsScreen(),
    //   binding: PosWalletsBinding(),
    //   middlewares: [
    //     AuthGuard(),
    //     PermissionGuardMiddleware(requiredPermission: AppPermissions.posWalletsView),
    //   ],
    // ),

    // ========================================================================
    // 6. باقات كروت الشبكة (Voucher Packages)
    // ========================================================================
    // GetPage(
    //   name: AppRoutes.voucherPackages,
    //   page: () => const VoucherPackagesScreen(),
    //   binding: VoucherPackagesBinding(),
    //   middlewares: [
    //     AuthGuard(),
    //     PermissionGuardMiddleware(requiredPermission: AppPermissions.voucherPackagesView),
    //   ],
    // ),

    // ========================================================================
    // 7. طلبات الكروت وفواتير المبيعات (Requests & Sales)
    // ========================================================================
    // GetPage(
    //   name: AppRoutes.requests,
    //   page: () => const RequestsScreen(),
    //   binding: RequestsBinding(),
    //   middlewares: [
    //     AuthGuard(),
    //     PermissionGuardMiddleware(requiredPermission: AppPermissions.requestsView),
    //   ],
    // ),
    // GetPage(
    //   name: AppRoutes.sales,
    //   page: () => const SalesScreen(),
    //   binding: SalesBinding(),
    //   middlewares: [
    //     AuthGuard(),
    //     PermissionGuardMiddleware(requiredPermission: AppPermissions.salesView),
    //   ],
    // ),

    // ========================================================================
    // 8. المصروفات والاشتراكات والدعم (Expenses, Subscriptions & Support)
    // ========================================================================
    // GetPage(
    //   name: AppRoutes.expenses,
    //   page: () => const ExpensesScreen(),
    //   binding: ExpensesBinding(),
    //   middlewares: [
    //     AuthGuard(),
    //     PermissionGuardMiddleware(requiredPermission: AppPermissions.expensesView),
    //   ],
    // ),
    // GetPage(
    //   name: AppRoutes.subscriptions,
    //   page: () => const SubscriptionsScreen(),
    //   binding: SubscriptionsBinding(),
    //   middlewares: [AuthGuard()],
    // ),
    // GetPage(
    //   name: AppRoutes.support,
    //   page: () => const SupportScreen(),
    //   binding: SupportBinding(),
    //   middlewares: [AuthGuard()],
    // ),
  ];
}
