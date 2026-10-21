import 'package:netsales/features/auth/domain/repositories/auth_repository.dart';

/// حالة استخدام طلب رمز استعادة كلمة المرور عبر الرسائل القصيرة (Request Password Reset Use Case)
class RequestPasswordResetUseCase {
  const RequestPasswordResetUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> execute(String phoneNumber) {
    return _repository.requestPasswordReset(phoneNumber);
  }
}
