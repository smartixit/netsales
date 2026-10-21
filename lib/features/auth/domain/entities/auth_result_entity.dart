import 'package:netsales/core/models/user_model.dart';

/// الكيان الدوميني لنتيجة عملية المصادقة
class AuthResultEntity {
  final bool require2fa;
  final bool requirePasswordChange;
  final bool isNewDevice;
  final bool isPrimary;
  final String sessionId;
  final UserModel? user;
  final List<String> permissions;
  final String userPhoneNumber;
  final String deviceUuid;
  final String? message;

  const AuthResultEntity({
    this.require2fa = false,
    this.requirePasswordChange = false,
    this.isNewDevice = false,
    this.isPrimary = false,
    required this.sessionId,
    this.user,
    this.permissions = const [],
    required this.userPhoneNumber,
    required this.deviceUuid,
    this.message,
  });
}
