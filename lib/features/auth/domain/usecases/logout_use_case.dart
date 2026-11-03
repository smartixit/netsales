import 'package:netsales/features/auth/domain/repositories/auth_repository.dart';

/// حالة استخدام تسجيل الخروج وإنهاء الجلسة (Logout Use Case)
class LogoutUseCase {
  const LogoutUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> execute() {
    return _repository.logout();
  }

  Future<void> call() => execute();
}

