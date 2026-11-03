import 'package:netsales/features/auth/domain/entities/user_device_entity.dart';
import 'package:netsales/features/auth/domain/repositories/auth_repository.dart';

/// حالة استخدام جلب قائمة الأجهزة المقترنة للمستخدم (Get Devices Use Case)
class GetDevicesUseCase {
  const GetDevicesUseCase(this._repository);

  final AuthRepository _repository;

  Future<List<UserDeviceEntity>> execute() {
    return _repository.getDevices();
  }

  Future<List<UserDeviceEntity>> call() => execute();
}
