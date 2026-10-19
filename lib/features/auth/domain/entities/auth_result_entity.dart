import 'package:netsales/core/models/user_model.dart';

/// الكيان الدوميني لنتيجة عملية المصادقة
class AuthResultEntity {
  final bool require2fa;
  final bool isNewDevice;
  final bool isPrimary;
  final String? sessionId;
  final UserModel? user;
  final List<String> permissions;
  final String? userPhoneNumber;
  final String? deviceUuid;
  final String? message;

  const AuthResultEntity({
    this.require2fa = false,
    this.isNewDevice = false,
    this.isPrimary = false,
    this.sessionId,
    this.user,
    this.permissions = const [],
    this.userPhoneNumber,
    this.deviceUuid,
    this.message,
  });

  /// هل تمت المصادقة بنجاح مباشر وأُنشئت الجلسة
  bool get isDirectSuccess => !require2fa && sessionId != null && user != null;
}
