import 'package:netsales/features/auth/domain/repositories/auth_repository.dart';

/// معلمات حالة استخدام تحديث كلمة المرور
class UpdatePasswordParams {
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;

  const UpdatePasswordParams({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });
}

/// حالة استخدام تحديث كلمة المرور للمستخدم (Update Password Use Case)
class UpdatePasswordUseCase {
  const UpdatePasswordUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> execute(UpdatePasswordParams params) {
    return _repository.updatePassword(
      currentPassword: params.currentPassword,
      newPassword: params.newPassword,
      confirmPassword: params.confirmPassword,
    );
  }
}
