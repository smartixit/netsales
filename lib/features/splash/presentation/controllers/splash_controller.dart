import 'dart:developer';

import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/features/splash/domain/usecases/determine_boot_destination_use_case.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// متحكم واجهة الإقلاع المسؤول عن تنسيق توقيت الظهور واتخاذ قرار التوجيه
class SplashController extends GetxController {
  final DetermineBootDestinationUseCase _determineBootDestinationUseCase;

  SplashController(this._determineBootDestinationUseCase);

  /// مدة ظهور شاشة الإقلاع الأدنى لضمان استمتاع المستخدم بالهوية البصرية
  static const Duration minSplashDuration = Duration(seconds: 4);

  bool _isDisposed = false;

  late String appName;

  @override
  void onInit() {
    super.onInit();
    _bootstrapApp();
  }

  Future<void> _bootstrapApp() async {
    try {
      await Future.delayed(minSplashDuration);
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
