import 'dart:async';
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
import 'package:netsales/core/services/api_service.dart';
import 'package:netsales/core/services/app_crypto_service.dart';
import 'package:netsales/core/services/device_service.dart';
import 'package:netsales/core/services/internet_connection_service.dart';
import 'package:netsales/core/services/permission_service.dart';
import 'package:netsales/core/services/push_notification_service.dart';
import 'package:netsales/core/services/session_service.dart';
import 'package:netsales/core/services/sms_retriever_service.dart';
import 'package:netsales/core/services/storage_service.dart';
import 'package:netsales/core/services/theme_service.dart';
import 'package:netsales/core/themes/app_motion.dart';
import 'package:netsales/core/utils/system_ui_style_resolver.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_themes.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/feedback/custom_not_found.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';
import 'package:netsales/widgets/interactions/custome_theme_switcher.dart';
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

  // 2. تهيئة خدمة بصمة الجهاز السيادية (Enterprise Device Intelligence)
  await DeviceService.instance.init();
  Get.put<DeviceService>(DeviceService.instance, permanent: true);

  // 3. تهيئة خدمة التشفير اللامتناظر ومزامنة المفاتيح العامة السيادية
  await AppCryptoService.instance.init();
  Get.put<AppCryptoService>(AppCryptoService.instance, permanent: true);
  unawaited(
    AppCryptoService.instance.syncServerPublicKeys(
      dio: ApiService.instance.dio,
    ),
  );

  // 3. تهيئة خدمات المظهر والهوية والصلاحيات الدائمة
  await ThemeService.instance.init();
  Get.put<ThemeService>(ThemeService.instance, permanent: true);

  // تفعيل مراقبة الاتصال بالإنترنت (Global listener for offline snackbar)
  await InternetConnectionService.instance.initialize();
  Get.put<InternetConnectionService>(
    InternetConnectionService.instance,
    permanent: true,
  );
  InternetConnectionService.instance.showInternetConnectionState();

  Get.put<PermissionService>(PermissionService.instance, permanent: true);
  await SessionService.instance.init();
  Get.put<SessionService>(SessionService.instance, permanent: true);

  // 4. تهيئة خدمة الإشعارات المركزية وإشعارات الدفع (FCM & Local Notifications)
  await PushNotificationService.instance.init();
  Get.put<PushNotificationService>(
    PushNotificationService.instance,
    permanent: true,
  );

  // 5. تهيئة استرجاع بصمة التطبيق لنظام أندرويد في الخلفية (Zero-click SMS Retriever API)
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    unawaited(SmsRetrieverService.instance.initSignature());
  }

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);

  // Edge-to-Edge (Android 15+ standard) — Guaranteed modern system bars
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // 7. تشغيل الواجهة الرئيسية للتطبيق
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
            defaultTransition: Transition.fadeIn,
            transitionDuration: AppMotion.page,
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
              return AnnotatedRegion<SystemUiOverlayStyle>(
                value: SystemUiStyleResolver.resolve(ctx),
                child: MediaQuery(
                  data: mediaQuery.copyWith(
                    textScaler: mediaQuery.textScaler.clamp(
                      minScaleFactor: 0.85,
                      maxScaleFactor: 1.15,
                    ),
                  ),
                  child: CustomThemeSwitcher(
                    child: appChild ?? const SizedBox.shrink(),
                  ),
                ),
              );
            },
          );
        });
      },
    );
  }
}
