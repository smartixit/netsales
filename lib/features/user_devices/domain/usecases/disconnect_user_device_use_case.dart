import 'package:netsales/features/user_devices/domain/repositories/user_devices_repository.dart';

class DisconnectUserDeviceUseCase {
  const DisconnectUserDeviceUseCase(this._repository);

  final UserDevicesRepository _repository;

  Future<void> call(int deviceId) => _repository.disconnectDevice(deviceId);
}
