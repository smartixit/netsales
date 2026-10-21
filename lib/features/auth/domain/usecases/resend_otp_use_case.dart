import 'package:netsales/features/auth/domain/repositories/auth_repository.dart';

/// معلمات حالة استخدام إعادة إرسال رمز التحقق
class ResendOtpParams {
  final String phoneNumber;
  final String otpType;
  final String deviceUuid;

  const ResendOtpParams({
    required this.phoneNumber,
    required this.otpType,
    required this.deviceUuid,
  });
}

/// حالة استخدام إعادة إرسال رمز التحقق عبر الرسائل القصيرة (ResendOtpUseCase)
class ResendOtpUseCase {
  const ResendOtpUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> execute(ResendOtpParams params) {
    return _repository.resendOtp(
      phoneNumber: params.phoneNumber,
      otpType: params.otpType,
      deviceUuid: params.deviceUuid,
    );
  }
}
