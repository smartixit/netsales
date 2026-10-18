import 'dart:developer';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:netsales/core/bindings/initial_binding.dart';
import 'package:netsales/core/constants/app_constants.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/routing/app_pages.dart';
import 'package:netsales/core/services/storage_service.dart';
import 'package:netsales/core/themes/app_themes.dart';
import 'package:netsales/widgets/custom_animation_overlay.dart';
import 'package:netsales/widgets/custom_snackbar.dart';

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

  // تخصيص شاشة الخطأ في الواجهات عند حدوث استثناء في بناء العناصر
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: Colors.white,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 56,
                color: Colors.amber,
              ),
              const SizedBox(height: 16),
              const Text(
                'حدث خطأ غير متوقع عند عرض هذه الشاشة',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  };

  // 1. تهيئة التخزين الأساسي - يجب انتظاره بشكل قاطع قبل أي خدمة تعتمد عليه
  await StorageService.instance.init();
  Get.put<StorageService>(StorageService.instance, permanent: true);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // 2. تشغيل الواجهة فوراً لإنهاء شاشة النظام (Native Splash) فوراً وبدء واجهة فلاتر
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(375, 812),
      minTextAdapt: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: AppConstants.appNameEn,
          debugShowCheckedModeBanner: false,
          theme: AppThemes.light,
          darkTheme: AppThemes.dark,
          themeMode: ,
          initialBinding: InitialBinding(),
          initialRoute: AppPages.initial,
          getPages: AppPages.routes,
          unknownRoute: GetPage(
            name: '/not-found',
            page: () => const Scaffold(
              body: Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 56,
                        color: Colors.amber,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'الصفحة غير موجودة',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          defaultTransition: Transition.rightToLeft,
          // transitionDuration: const Duration(milliseconds: 500),
          locale: const Locale('ar'),
          supportedLocales: const [Locale('en'), Locale('ar')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,

            FormBuilderLocalizations.delegate,
          ],
          textDirection: TextDirection.rtl,
          builder: (context, child) {
            final mediaQuery = MediaQuery.of(context);
            // تحديد نطاق أمان لحجم الخط بين 85% كحد أدنى و115% كحد أقصى
            // للسماح بإمكانية الوصول المناسبة مع حماية تصميم الواجهات من التشوه
            return MediaQuery(
              data: mediaQuery.copyWith(
                textScaler: mediaQuery.textScaler.clamp(
                  minScaleFactor: 0.85,
                  maxScaleFactor: 1.15,
                ),
              ),
              child: child ?? const SizedBox.shrink(),
            );
          },
        );
      },
    );
  }
}
