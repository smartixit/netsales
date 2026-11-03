import 'package:netsales/features/auth/domain/repositories/auth_repository.dart';

/// حالة استخدام تسجيل الخروج من كافة الأجهزة الأخرى (Logout Other Devices Use Case)
class LogoutOtherDevicesUseCase {
  const LogoutOtherDevicesUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> execute() {
    return _repository.logoutOtherDevices();
  }

  Future<void> call() => execute();
}

