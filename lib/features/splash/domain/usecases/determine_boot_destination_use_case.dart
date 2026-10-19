import 'package:netsales/features/splash/domain/repositories/splash_repository.dart';

/// حالة استخدام تحديد مسار الإقلاع
class DetermineBootDestinationUseCase {
  final SplashRepository _repository;

  const DetermineBootDestinationUseCase(this._repository);

  Future<String> call() {
    return _repository.getBootDestination();
  }
}
