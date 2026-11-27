import 'package:netsales/features/user_devices/domain/repositories/user_devices_repository.dart';

class LogoutOtherDevicesUseCase {
  const LogoutOtherDevicesUseCase(this._repository);

  final UserDevicesRepository _repository;

  Future<void> call() => _repository.logoutOtherDevices();
}
