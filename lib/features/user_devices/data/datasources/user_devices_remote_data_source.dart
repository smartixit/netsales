import 'package:netsales/features/user_devices/data/models/user_device_model.dart';

abstract interface class UserDevicesRemoteDataSource {
  Future<List<UserDeviceModel>> getDevices();

  Future<void> disconnectDevice(int deviceId);

  Future<void> logoutOtherDevices();
}
