import 'package:netsales/features/auth/domain/entities/auth_result_entity.dart';
import 'package:netsales/features/auth/domain/repositories/auth_repository.dart';

/// معلمات حالة استخدام تسجيل الدخول
class LoginParams {
  final String phoneNumber;
  final String password;
  final String? deviceUuid;
  final String? deviceName;
  final String? deviceType;

  const LoginParams({
    required this.phoneNumber,
    required this.password,
    this.deviceUuid,
    this.deviceName,
    this.deviceType,
  });
}

/// حالة استخدام تسجيل الدخول إلى النظام (Login Use Case)
class LoginUseCase {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthResultEntity> execute(LoginParams params) {
    return _repository.login(
      phoneNumber: params.phoneNumber,
      password: params.password,
      deviceUuid: params.deviceUuid,
      deviceName: params.deviceName,
      deviceType: params.deviceType,
    );
  }
}
