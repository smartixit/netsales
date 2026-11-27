import 'package:netsales/features/user_devices/domain/entities/user_device_entity.dart';

/// عقد المستودع لوحدة الأجهزة المقترنة.
abstract interface class UserDevicesRepository {
  Future<List<UserDeviceEntity>> getDevices();

  Future<void> disconnectDevice(int deviceId);

  Future<void> logoutOtherDevices();
}
