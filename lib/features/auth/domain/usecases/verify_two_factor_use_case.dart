import 'package:netsales/features/auth/domain/entities/auth_result_entity.dart';
import 'package:netsales/features/auth/domain/repositories/auth_repository.dart';

/// معلمات حالة استخدام التحقق الثنائي (VerifyTwoFactorParams)
class VerifyTwoFactorParams {
  final String phoneNumber;
  final String otp;
  final String deviceUuid;
  final String fcmToken;
  final String? deviceName;
  final String? deviceType;

  const VerifyTwoFactorParams({
    required this.phoneNumber,
    required this.otp,
    required this.deviceUuid,
    required this.fcmToken,
    this.deviceName,
    this.deviceType,
  });
}

/// حالة استخدام التحقق الثنائي وتأكيد الجهاز (VerifyTwoFactorUseCase)
class VerifyTwoFactorUseCase {
  const VerifyTwoFactorUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthResultEntity> execute(VerifyTwoFactorParams params) {
    return _repository.verifyTwoFactor(
      phoneNumber: params.phoneNumber,
      otp: params.otp,
      deviceUuid: params.deviceUuid,
      fcmToken: params.fcmToken,
      deviceName: params.deviceName,
      deviceType: params.deviceType,
    );
  }
}
