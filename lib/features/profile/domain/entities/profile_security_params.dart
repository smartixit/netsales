import 'package:equatable/equatable.dart';

/// معاملات تغيير كلمة المرور.
class ChangePasswordParams extends Equatable {
  const ChangePasswordParams({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  final String currentPassword;
  final String newPassword;
  final String confirmPassword;

  @override
  List<Object?> get props => [currentPassword, newPassword, confirmPassword];
}

/// معاملات تفعيل أو تعطيل التحقق بخطوتين.
class ToggleTwoFactorParams extends Equatable {
  const ToggleTwoFactorParams({
    required this.enable,
    this.otp,
    this.currentPassword,
  });

  final bool enable;
  final String? otp;
  final String? currentPassword;

  @override
  List<Object?> get props => [enable, otp, currentPassword];
}
