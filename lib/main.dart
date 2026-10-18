import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:netsales/core/bindings/initial_binding.dart';
import 'package:netsales/core/constants/app_constants.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/routing/app_pages.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/services/app_crypto_service.dart';
import 'package:netsales/core/services/permission_service.dart';
import 'package:netsales/core/services/session_service.dart';
import 'package:netsales/core/services/storage_service.dart';
import 'package:netsales/core/services/theme_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_themes.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/custom_not_found.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';
import 'package:netsales/widgets/animations/custome_theme_switcher.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // معالجة أخطاء فلاتر وتجنب انهيار التطبيق
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    log(
      '❌ FlutterError: ${details.exceptionAsString()}',
      stackTrace: details.stack,
    );
  };

  // شبكة أمان عامة لكافة الاستثناءات غير الملتقطة على مستوى النظام الأساسي
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    log('❌ Uncaught Platform Error: $error', stackTrace: stack);

    // إخفاء أي مؤشر تحميل معلق
    try {
      CustomAnimationOverlay.hide();
    } catch (_) {}

    final sanitizedMessage = AppException.sanitizeMessage(error);

    // التأكد من توفر سياق الواجهة قبل محاولة إظهار سناك بار
    if (Get.context != null) {
      if (error is PermissionDeniedException) {
        CustomSnackbar.show(
          title: 'صلاحية غير متوفرة',
          message: sanitizedMessage,
          type: SnackType.warning,
        );
      } else if (error is UnauthenticatedException) {
        CustomSnackbar.show(
          title: 'تسجيل الدخول مطلوب',
          message: sanitizedMessage,
          type: SnackType.warning,
        );
      } else {
        CustomSnackbar.show(
          title: 'تنبيه',
          message: sanitizedMessage,
          type: SnackType.error,
        );
      }
    }
    return true; // تم التعامل مع الخطأ بنجاح دون انهيار التطبيق
  };

  // تخصيص شاشة الخطأ في الواجهات عند حدوث استثناء في بناء العناصر (Clean Design System)
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Builder(
      builder: (context) {
        final colors = context.colors;
        return Material(
          color: colors.surface,
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 56.r,
                    color: colors.warning,
                  ),
                  AppSpacing.vMd,
                  Text(
                    'حدث خطأ غير متوقع عند عرض هذه الشاشة',
                    style: AppTypography.titleMedium.copyWith(
                      color: colors.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  };

  // 1. تهيئة التخزين الأساسي - يجب انتظاره قبل أي خدمة تعتمد عليه
  await StorageService.instance.init();
  Get.put<StorageService>(StorageService.instance, permanent: true);

  // 2. تهيئة خدمة التشفير اللامتناظر ومزامنة المفاتيح العامة السيادية
  await AppCryptoService.instance.init();
  Get.put<AppCryptoService>(AppCryptoService.instance, permanent: true);

  // 3. تهيئة خدمات المظهر والهوية والصلاحيات الدائمة
  final themeService = Get.put<ThemeService>(ThemeService(), permanent: true);
  await themeService.init();

  Get.put<PermissionService>(PermissionService(), permanent: true);
  final sessionService = Get.put<SessionService>(
    SessionService(),
    permanent: true,
  );
  await sessionService.init();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);

  // 3. تشغيل الواجهة الرئيسية للتطبيق
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = ThemeService.to;

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (context, child) {
        return Obx(() {
          return GetMaterialApp(
            title: AppConstants.appNameEn,
            debugShowCheckedModeBanner: false,
            theme: AppThemes.light,
            darkTheme: AppThemes.dark,
            themeMode: themeService.themeMode,
            initialBinding: InitialBinding(),
            initialRoute: AppPages.initial,
            getPages: AppPages.routes,
            unknownRoute: GetPage(
              name: AppRoutes.notFound,
              page: () => const CustomNotFound(),
            ),
            defaultTransition: Transition.rightToLeft,
            // transitionDuration: AppMotion.page,
            locale: const Locale('ar'),
            supportedLocales: const [Locale('en'), Locale('ar')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              FormBuilderLocalizations.delegate,
            ],
            textDirection: TextDirection.rtl,
            builder: (ctx, appChild) {
              final mediaQuery = MediaQuery.of(ctx);
              // تحديد نطاق أمان لحجم الخط بين 85% كحد أدنى و115% كحد أقصى
              // لحماية تناسق الواجهات من التشوه مع الحفاظ على إمكانية الوصول
              return MediaQuery(
                data: mediaQuery.copyWith(
                  textScaler: mediaQuery.textScaler.clamp(
                    minScaleFactor: 0.85,
                    maxScaleFactor: 1.15,
                  ),
                ),
                child: CustomThemeSwitcher(
                  child: appChild ?? const SizedBox.shrink(),
                ),
              );
            },
          );
        });
      },
    );
  }
}
