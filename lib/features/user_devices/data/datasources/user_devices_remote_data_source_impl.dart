import 'package:netsales/core/constants/api_constants.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/services/api_service.dart';
import 'package:netsales/features/user_devices/data/datasources/user_devices_remote_data_source.dart';
import 'package:netsales/features/user_devices/data/models/user_device_model.dart';

class UserDevicesRemoteDataSourceImpl implements UserDevicesRemoteDataSource {
  const UserDevicesRemoteDataSourceImpl();

  @override
  Future<List<UserDeviceModel>> getDevices() async {
    final response = await ApiService.instance.get<List<UserDeviceModel>>(
      ApiConstants.authDevices,
      fromJson: (json) {
        if (json is! List) return <UserDeviceModel>[];
        return json
            .whereType<Map<String,dynamic>>()
            .map((e) => UserDeviceModel.fromJson(Map<String, dynamic>.from(e)))
            .toList(growable: false);
      },
    );

    if (!response.success) {
      throw AppException(
        response.message.isNotEmpty
            ? response.message
            : 'تعذر جلب قائمة الأجهزة المقترنة.',
      );
    }

    return response.data ?? const <UserDeviceModel>[];
  }

  @override
  Future<void> disconnectDevice(int deviceId) async {
    final response = await ApiService.instance.delete<void>(
      ApiConstants.disconnectDevice(deviceId),
    );

    if (!response.success) {
      throw AppException(
        response.message.isNotEmpty
            ? response.message
            : 'تعذر فصل الجهاز.',
      );
    }
  }

  @override
  Future<void> logoutOtherDevices() async {
    final response = await ApiService.instance.post<void>(
      ApiConstants.logoutOtherDevices,
    );

    if (!response.success) {
      throw AppException(
        response.message.isNotEmpty
            ? response.message
            : 'تعذر إنهاء الجلسات الأخرى.',
      );
    }
  }
}
