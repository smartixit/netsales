import 'dart:async';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/features/splash/domain/usecases/determine_boot_destination_use_case.dart';
import 'package:netsales/features/splash/domain/usecases/initialize_app_use_case.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// متحكم واجهة الإقلاع المسؤول عن تنسيق توقيت الظهور واتخاذ قرار التوجيه
///
/// يعتمد المعمارية النظيفة الصارمة (Strict Clean Architecture):
/// - خلو تام من أي تبعيات للبنية التحتية أو الخدمات المباشرة.
/// - التنسيق عبر حالات الاستخدام (Use Cases) المحقونة حصراً.
class SplashController extends GetxController {
  final InitializeAppUseCase _initializeAppUseCase;
  final DetermineBootDestinationUseCase _determineBootDestinationUseCase;

  SplashController(
    this._initializeAppUseCase,
    this._determineBootDestinationUseCase,
  );

  /// مدة ظهور شاشة الإقلاع الأدنى لضمان استمتاع المستخدم بالهوية البصرية وانسيابية الحركة
  static const Duration minSplashDuration = Duration(milliseconds: 2500);

  bool _isDisposed = false;

  @override
  void onInit() {
    super.onInit();
    _bootstrapApp();
  }

  Future<void> _bootstrapApp() async {
    try {
      final stopwatch = Stopwatch()..start();

      // 1. تشغيل تهيئة البنية التحتية عبر حالة الاستخدام المعزولة
      await _initializeAppUseCase();

      // 2. ضمان بقاء شاشة الإقلاع للمدة البصرية المطلوبة دون وميض حاد
      final elapsed = stopwatch.elapsed;
      if (elapsed < minSplashDuration) {
        await Future.delayed(minSplashDuration - elapsed);
      }
      if (_isDisposed) return;

      // 3. اتخاذ قرار مسار التوجيه التالي
      final destination = await _determineBootDestinationUseCase();
      if (_isDisposed) return;

      log('🚀 [SplashController] Bootstrapping complete. Navigating to: $destination');
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

