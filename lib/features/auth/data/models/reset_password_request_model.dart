/// نموذج حمولة طلب إعادة تعيين كلمة المرور المباشرة (ResetPasswordRequestModel)
///
/// مطابق بنسبة 100% لعقد الواجهة الخلفية في netsales_api:
/// App\Http\Requests\API\V1\Auth\ResetPasswordRequest
class ResetPasswordRequestModel {
  const ResetPasswordRequestModel({
    required this.userPhoneNumber,
    required this.otp,
    required this.password,
    required this.passwordConfirmation,
  });

  /// رقم هاتف المستخدم (9 أرقام، يبدأ بـ 7)
  final String userPhoneNumber;

  /// رمز التحقق OTP المستلم (6 أرقام)
  final String otp;

  /// كلمة المرور الجديدة
  final String password;

  /// تأكيد كلمة المرور الجديدة
  final String passwordConfirmation;

  /// تحويل النموذج لحمولة JSON مطابقة لحقول الطلب في الباك إند
  Map<String, dynamic> toJson() => {
        'user_phone_number': userPhoneNumber,
        'otp': otp,
        'password': password,
        'password_confirmation': passwordConfirmation,
      };
}
