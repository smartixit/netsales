import 'package:netsales/features/user_devices/domain/entities/user_device_entity.dart';
import 'package:netsales/features/user_devices/domain/repositories/user_devices_repository.dart';

class GetUserDevicesUseCase {
  const GetUserDevicesUseCase(this._repository);

  final UserDevicesRepository _repository;

  Future<List<UserDeviceEntity>> call() => _repository.getDevices();
}
