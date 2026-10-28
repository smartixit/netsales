import 'package:netsales/features/splash/domain/repositories/splash_repository.dart';

/// حالة استخدام تهيئة خدمات البنية التحتية الأساسية للتطبيق
class InitializeAppUseCase {
  final SplashRepository _repository;

  const InitializeAppUseCase(this._repository);

  Future<void> call() {
    return _repository.initializeServices();
  }
}
