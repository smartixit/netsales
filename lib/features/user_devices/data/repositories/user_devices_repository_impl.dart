import 'package:netsales/features/user_devices/data/datasources/user_devices_remote_data_source.dart';
import 'package:netsales/features/user_devices/domain/entities/user_device_entity.dart';
import 'package:netsales/features/user_devices/domain/repositories/user_devices_repository.dart';

class UserDevicesRepositoryImpl implements UserDevicesRepository {
  const UserDevicesRepositoryImpl(this._remoteDataSource);

  final UserDevicesRemoteDataSource _remoteDataSource;

  @override
  Future<List<UserDeviceEntity>> getDevices() => _remoteDataSource.getDevices();

  @override
  Future<void> disconnectDevice(int deviceId) =>
      _remoteDataSource.disconnectDevice(deviceId);

  @override
  Future<void> logoutOtherDevices() => _remoteDataSource.logoutOtherDevices();
}
