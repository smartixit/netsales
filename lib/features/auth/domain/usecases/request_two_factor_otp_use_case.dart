import 'package:netsales/features/auth/domain/repositories/auth_repository.dart';

/// معلمات حالة استخدام طلب كود المصادقة الثنائية 2FA
class RequestTwoFactorOtpParams {
  final String? deviceUuid;
  final String? appHash;

  const RequestTwoFactorOtpParams({this.deviceUuid, this.appHash});
}

/// حالة استخدام طلب رمز تحقق OTP جديد لتفعيل أو إدارة المصادقة الثنائية (Request 2FA OTP Use Case)
class RequestTwoFactorOtpUseCase {
  const RequestTwoFactorOtpUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> execute([RequestTwoFactorOtpParams? params]) {
    return _repository.requestTwoFactorOtp(
      deviceUuid: params?.deviceUuid,
      appHash: params?.appHash,
    );
  }
}
