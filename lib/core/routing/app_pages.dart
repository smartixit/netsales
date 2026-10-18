import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_constants.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/custom_not_found.dart';
// import 'package:netsales/core/routing/middlewares/auth_guard.dart';

/// ============================================================================
/// سجل صفحات ومسارات التطبيق (Application Pages Register)
/// ============================================================================
/// يحتوي على قائمة مسارات GetPage وروابطها مع الـ Bindings والـ Middlewares.
/// تم وضع الصفحات المستقبلية في حالة تعليق مؤقتاً لحين بناء واجهات كل ميزة.
abstract final class AppPages {
  AppPages._();

  static const String initial = AppRoutes.initial;

  static final List<GetPage> routes = [
    // المسار المبدئي المؤقت أثناء إقلاع التطبيق قبل بناء واجهات الميزات
    GetPage(name: AppRoutes.initial, page: () => const _AppBootPlaceholder()),

    // Not Found
    GetPage(name: AppRoutes.notFound, page: () => const CustomNotFound()),

    // ========================================================================
    // 1. مسار البداية والفحص الأولي (Splash)
    // ========================================================================
    // GetPage(
    //   name: AppRoutes.splash,
    //   page: () => const SplashScreen(),
    //   binding: SplashBinding(),
    // ),

    // ========================================================================
    // 2. مسارات المصادقة (Authentication)
    // ========================================================================
    // GetPage(
    //   name: AppRoutes.welcome,
    //   page: () => const WelcomeScreen(),
    //   middlewares: [GuestGuard()],
    // ),
    // GetPage(
    //   name: AppRoutes.login,
    //   page: () => const LoginScreen(),
    //   binding: AuthBinding(),
    //   middlewares: [GuestGuard()],
    // ),
    // GetPage(
    //   name: AppRoutes.registerNetwork,
    //   page: () => const RegisterNetworkScreen(),
    //   binding: AuthBinding(),
    //   middlewares: [GuestGuard()],
    // ),
    // GetPage(
    //   name: AppRoutes.registerPos,
    //   page: () => const RegisterPosScreen(),
    //   binding: AuthBinding(),
    //   middlewares: [GuestGuard()],
    // ),

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

/// شاشة إقلاع خفيفة ومؤقتة ريثما يتم بناء شاشات وميزات التطبيق
class _AppBootPlaceholder extends StatelessWidget {
  const _AppBootPlaceholder();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.surface,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppConstants.appName,
              style: AppTypography.headlineMedium.copyWith(
                color: colors.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
