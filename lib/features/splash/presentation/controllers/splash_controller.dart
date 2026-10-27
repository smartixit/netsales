import 'dart:async';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/services/api_service.dart';
import 'package:netsales/core/services/app_crypto_service.dart';
import 'package:netsales/core/services/device_service.dart';
import 'package:netsales/core/services/internet_connection_service.dart';
import 'package:netsales/core/services/public_settings_service.dart';
import 'package:netsales/core/services/push_notification_service.dart';
import 'package:netsales/core/services/theme_service.dart';
import 'package:netsales/features/splash/domain/usecases/determine_boot_destination_use_case.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// متحكم واجهة الإقلاع المسؤول عن تنسيق توقيت الظهور واتخاذ قرار التوجيه
class SplashController extends GetxController {
  final DetermineBootDestinationUseCase _determineBootDestinationUseCase;

  SplashController(this._determineBootDestinationUseCase);

  /// مدة ظهور شاشة الإقلاع الأدنى لضمان استمتاع المستخدم بالهوية البصرية وانسيابية الحركة
  static const Duration minSplashDuration = Duration(milliseconds: 3000);

  bool _isDisposed = false;

  @override
  void onInit() {
    super.onInit();
    _bootstrapApp();
  }

  bool get isDarkMode => ThemeService.to.isDarkMode;

  Future<void> _bootstrapApp() async {
    try {
      final stopwatch = Stopwatch()..start();

      // 1. تشغيل التهيئة المتوازية للخدمات غير الحرجة أثناء عرض شاشة الإقلاع الأنيقة
      await Future.wait([
        DeviceService.instance.init(),
        AppCryptoService.instance.init(),
        PushNotificationService.instance.init(),
        PublicSettingsService.instance.init(),
        InternetConnectionService.instance.initialize(),
      ]);

      // مزامنة مفاتيح السيرفر السيادية في الخلفية فور جاهزية محرك التشفير
      unawaited(
        AppCryptoService.instance.syncServerPublicKeys(
          dio: ApiService.instance.dio,
        ),
      );

      // تفعيل مراقبة الاتصال الشبكي بعد اكتمال واجهات التطبيق بأمان
      InternetConnectionService.instance.showInternetConnectionState();

      // 2. ضمان بقاء شاشة الإقلاع للمدة البصرية المطلوبة دون تقطيع أو وميض
      final elapsed = stopwatch.elapsed;
      if (elapsed < minSplashDuration) {
        await Future.delayed(minSplashDuration - elapsed);
      }
      if (_isDisposed) return;

      final destination = await _determineBootDestinationUseCase();
      if (_isDisposed) return;

      log(
        '🚀 [SplashController] Bootstrapping complete. Navigating to: $destination',
      );
      Get.offNamed(destination);
    } catch (e, stack) {
      final cleanMessage = AppException.sanitizeMessage(e);
      CustomSnackbar.show(
        title: 'خطأ',
        message: cleanMessage,
        type: SnackType.error,
      );
      log('❌ [SplashController] Bootstrapping error: $e', stackTrace: stack);
      if (!_isDisposed) {
        Get.offNamed(AppRoutes.welcome);
      }
    }
  }

  @override
  void onClose() {
    _isDisposed = true;
    super.onClose();
  }
}
