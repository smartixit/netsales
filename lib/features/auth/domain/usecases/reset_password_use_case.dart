import 'package:netsales/features/auth/domain/repositories/auth_repository.dart';

/// معلمات حالة استخدام إعادة تعيين كلمة المرور المباشرة
class ResetPasswordParams {
  const ResetPasswordParams({
    required this.phoneNumber,
    required this.otp,
    required this.newPassword,
    required this.confirmPassword,
  });

  /// رقم هاتف المستخدم
  final String phoneNumber;

  /// رمز التحقق OTP المستلم
  final String otp;

  /// كلمة المرور الجديدة
  final String newPassword;

  /// تأكيد كلمة المرور الجديدة
  final String confirmPassword;
}

/// حالة استخدام اعتماد وإعادة تعيين كلمة المرور المباشرة بعد استيفاء كود التحقق
///
/// تمثل منطق الأعمال المستقل لمسار `POST /api/v1/auth/password/reset`
class ResetPasswordUseCase {
  const ResetPasswordUseCase(this._repository);

  final AuthRepository _repository;

  /// تنفيذ عملية اعتماد كلمة المرور الجديدة وإلغاء الجلسات القديمة
  Future<void> execute(ResetPasswordParams params) {
    return _repository.resetPassword(
      phoneNumber: params.phoneNumber,
      otp: params.otp,
      newPassword: params.newPassword,
      confirmPassword: params.confirmPassword,
    );
  }
}
