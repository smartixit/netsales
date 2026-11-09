import 'package:netsales/features/auth/domain/repositories/auth_repository.dart';

/// معلمات حالة استخدام تفعيل أو تعطيل المصادقة الثنائية 2FA
class ToggleTwoFactorParams {
  final bool enable;
  final String? otp;
  final String? currentPassword;
  final String? deviceUuid;
  final String? appHash;

  const ToggleTwoFactorParams({
    required this.enable,
    this.otp,
    this.currentPassword,
    this.deviceUuid,
    this.appHash,
  });
}

/// حالة استخدام تفعيل أو تعطيل المصادقة الثنائية (Toggle 2FA Use Case)
class ToggleTwoFactorUseCase {
  const ToggleTwoFactorUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> execute(ToggleTwoFactorParams params) {
    return _repository.toggleTwoFactor(
      enable: params.enable,
      otp: params.otp,
      currentPassword: params.currentPassword,
      deviceUuid: params.deviceUuid,
      appHash: params.appHash,
    );
  }
}

