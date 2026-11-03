import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/routing/middlewares/auth_guard.dart';
import 'package:netsales/core/routing/middlewares/workspace_guard.dart';
import 'package:netsales/features/auth/presentation/bindings/active_sessions_binding.dart';
import 'package:netsales/features/auth/presentation/bindings/forgot_password_binding.dart';
import 'package:netsales/features/auth/presentation/bindings/login_binding.dart';
import 'package:netsales/features/auth/presentation/bindings/register_network_binding.dart';
import 'package:netsales/features/auth/presentation/bindings/register_pos_binding.dart';
import 'package:netsales/features/auth/presentation/bindings/reset_password_binding.dart';
import 'package:netsales/features/auth/presentation/bindings/two_factor_auth_binding.dart';
import 'package:netsales/features/auth/presentation/bindings/verify_otp_binding.dart';
import 'package:netsales/features/auth/presentation/screens/active_sessions_screen.dart';
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
import 'package:netsales/features/workspace/presentation/bindings/network_workspace_binding.dart';
import 'package:netsales/features/workspace/presentation/bindings/pos_workspace_binding.dart';
import 'package:netsales/features/workspace/presentation/screens/network_workspace_shell.dart';
import 'package:netsales/features/workspace/presentation/screens/pos_workspace_shell.dart';
import 'package:netsales/features/workspace/presentation/screens/unsupported_platform_screen.dart';
import 'package:netsales/widgets/feedback/custom_not_found.dart';
import 'package:netsales/widgets/feedback/custom_unauthorized.dart';

/// ============================================================================
/// سجل صفحات ومسارات التطبيق (Application Pages Register)
/// ============================================================================
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

    // ========================================================================
    // 3. مسارات المصادقة العامة (Auth Routes)
    // ========================================================================
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
    // 4. مسارات مساحات العمل التشغيلية المحمية (Workspace Shell Routes)
    // ========================================================================
    // مسار التوجيه الافتراضي للوحة التحكم (يتم اعتراضه وتوجيهه حسب مساحة المستخدم)
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const SizedBox.shrink(),
      middlewares: [AuthGuard(), WorkspaceGuard()],
    ),

    // مساحة عمل مزود شبكة الإنترنت (Network Workspace)
    GetPage(
      name: AppRoutes.networkWorkspace,
      page: () => const NetworkWorkspaceShell(),
      binding: NetworkWorkspaceBinding(),
      middlewares: [
        AuthGuard(),
        WorkspaceGuard(targetWorkspace: AppWorkspace.network),
      ],
    ),

    // مساحة عمل نقطة البيع والوكيل (POS Workspace)
    GetPage(
      name: AppRoutes.posWorkspace,
      page: () => const PosWorkspaceShell(),
      binding: PosWorkspaceBinding(),
      middlewares: [
        AuthGuard(),
        WorkspaceGuard(targetWorkspace: AppWorkspace.pos),
      ],
    ),

    // شاشة حظر وتوجيه حسابات إدارة المنصة العامة (Platform Scope Exclusion)
    GetPage(
      name: AppRoutes.unsupportedPlatform,
      page: () => const UnsupportedPlatformScreen(),
      middlewares: [AuthGuard()],
    ),

    // ========================================================================
    // 5. مسارات الأمان والجلسات المعتمدة (Security & Active Sessions)
    // ========================================================================
    GetPage(
      name: AppRoutes.activeSessions,
      page: () => const ActiveSessionsScreen(),
      binding: ActiveSessionsBinding(),
      middlewares: [AuthGuard()],
    ),
  ];
}
