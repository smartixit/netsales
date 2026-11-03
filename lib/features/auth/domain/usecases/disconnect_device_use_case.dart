import 'package:netsales/features/auth/domain/repositories/auth_repository.dart';

/// حالة استخدام فصل وإلغاء اقتران جهاز محدد (Disconnect Device Use Case)
class DisconnectDeviceUseCase {
  const DisconnectDeviceUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> execute(int deviceId) {
    return _repository.disconnectDevice(deviceId);
  }

  Future<void> call(int deviceId) => execute(deviceId);
}
