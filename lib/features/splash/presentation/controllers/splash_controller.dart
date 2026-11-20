import 'dart:async';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:netsales/core/themes/app_motion.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/features/splash/domain/entities/boot_verification_unavailable_exception.dart';
import 'package:netsales/features/splash/domain/usecases/determine_boot_destination_use_case.dart';
import 'package:netsales/features/splash/domain/usecases/initialize_app_use_case.dart';

/// متحكم واجهة الإقلاع المسؤول عن تنسيق توقيت الظهور واتخاذ قرار التوجيه
///
/// يعتمد المعمارية النظيفة الصارمة (Strict Clean Architecture):
/// - خلو تام من أي تبعيات للبنية التحتية أو الخدمات المباشرة.
/// - التنسيق عبر حالات الاستخدام (Use Cases) المحقونة حصراً.
class SplashController extends GetxController {
  final InitializeAppUseCase initializeAppUseCase;
  final DetermineBootDestinationUseCase determineBootDestinationUseCase;

  SplashController({
    required this.initializeAppUseCase,
    required this.determineBootDestinationUseCase,
  });

  /// مدة ظهور شاشة الإقلاع الأدنى لضمان استمتاع المستخدم بالهوية البصرية وانسيابية الحركة
  static const Duration minSplashDuration = AppMotion.splashMinimum;

  bool _isDisposed = false;
  bool _infrastructureReady = false;

  final RxBool isRetryableError = false.obs;
  final RxBool isRetrying = false.obs;
  final RxString retryMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _bootstrapApp();
  }

  Future<void> _bootstrapApp() async {
    final stopwatch = Stopwatch()..start();
    try {
      await _resolveBootDestination(initializeInfrastructure: true);
      final elapsed = stopwatch.elapsed;
      if (elapsed < minSplashDuration) {
        await Future<void>.delayed(minSplashDuration - elapsed);
      }
    } catch (error, stack) {
      _showRetryState(error, stack);
    }
  }

  Future<void> retryBoot() async {
    if (isRetrying.value || _isDisposed) return;
    isRetrying.value = true;
    isRetryableError.value = false;
    try {
      await _resolveBootDestination(
        initializeInfrastructure: !_infrastructureReady,
      );
    } catch (error, stack) {
      _showRetryState(error, stack);
    } finally {
      isRetrying.value = false;
    }
  }

  Future<void> _resolveBootDestination({required bool initializeInfrastructure}) async {
    if (initializeInfrastructure) {
      await initializeAppUseCase();
      _infrastructureReady = true;
    }
    if (_isDisposed) return;
    final destination = await determineBootDestinationUseCase();
    if (_isDisposed) return;
    isRetryableError.value = false;
    log('🚀 [SplashController] Boot destination resolved: $destination');
    await Get.offNamed<void>(destination);
  }

  void _showRetryState(Object error, StackTrace stack) {
    log('❌ [SplashController] Boot verification failed.', stackTrace: stack);
    retryMessage.value = error is BootVerificationUnavailableException
        ? error.toString()
        : 'تعذر إكمال تهيئة التطبيق. تحقق من الاتصال ثم أعد المحاولة.';
    isRetryableError.value = true;
  }

  @override
  void onClose() {
    _isDisposed = true;
    super.onClose();
  }
}
