import 'dart:developer';

import 'package:get/get.dart';
import 'package:netsales/features/splash/domain/usecases/determine_boot_destination_use_case.dart';

/// متحكم واجهة الإقلاع المسؤول عن تنسيق توقيت الظهور واتخاذ قرار التوجيه
class SplashController extends GetxController {
  final DetermineBootDestinationUseCase _determineBootDestinationUseCase;

  SplashController(this._determineBootDestinationUseCase);

  /// مدة ظهور شاشة الإقلاع الأدنى لضمان استمتاع المستخدم بالهوية البصرية
  static const Duration minSplashDuration = Duration(milliseconds: 1800);

  bool _isDisposed = false;

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

      log('🚀 [SplashController] Bootstrapping complete. Navigating to: $destination');
      Get.offNamed(destination);
    } catch (e, stack) {
      log('❌ [SplashController] Bootstrapping error: $e', stackTrace: stack);
      if (!_isDisposed) {
        Get.offNamed('/welcome');
      }
    }
  }

  @override
  void onClose() {
    _isDisposed = true;
    super.onClose();
  }
}
