import 'package:netsales/features/auth/domain/repositories/auth_repository.dart';

/// معلمات حالة استخدام التحقق من رمز الاستعادة
class VerifyResetOtpParams {
  final String phoneNumber;
  final String otp;

  const VerifyResetOtpParams({
    required this.phoneNumber,
    required this.otp,
  });
}

/// حالة استخدام التحقق من كود الاستعادة وتوليد كلمة المرور المؤقتة (Verify Reset OTP Use Case)
class VerifyResetOtpUseCase {
  const VerifyResetOtpUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> execute(VerifyResetOtpParams params) {
    return _repository.verifyResetOtp(
      phoneNumber: params.phoneNumber,
      otp: params.otp,
    );
  }
}
