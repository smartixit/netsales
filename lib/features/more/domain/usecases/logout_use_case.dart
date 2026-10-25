import 'package:netsales/features/more/domain/repositories/more_repository.dart';

/// ============================================================================
/// حالة استخدام تسجيل الخروج الآمن (LogoutUseCase)
/// ============================================================================
class LogoutUseCase {
  final MoreRepository _repository;

  const LogoutUseCase(this._repository);

  Future<bool> call() {
    return _repository.logout();
  }
}
