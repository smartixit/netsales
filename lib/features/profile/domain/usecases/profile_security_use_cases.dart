import 'package:netsales/features/profile/domain/entities/profile_security_params.dart';
import 'package:netsales/features/profile/domain/repositories/profile_repository.dart';

/// حالة استخدام: تغيير كلمة المرور.
class ChangePasswordUseCase {
  const ChangePasswordUseCase(this._repository);

  final ProfileRepository _repository;

  Future<void> call(ChangePasswordParams params) {
    return _repository.changePassword(params);
  }
}

/// حالة استخدام: طلب رمز التحقق بخطوتين لتفعيل الميزة.
class RequestTwoFactorOtpUseCase {
  const RequestTwoFactorOtpUseCase(this._repository);

  final ProfileRepository _repository;

  Future<void> call() => _repository.requestTwoFactorOtp();
}

/// حالة استخدام: تفعيل أو تعطيل التحقق بخطوتين.
class ToggleTwoFactorUseCase {
  const ToggleTwoFactorUseCase(this._repository);

  final ProfileRepository _repository;

  Future<void> call(ToggleTwoFactorParams params) {
    return _repository.toggleTwoFactor(params);
  }
}
