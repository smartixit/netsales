import 'package:netsales/core/models/user_model.dart';
import 'package:netsales/features/auth/domain/entities/auth_result_entity.dart';

/// نموذج استجابة تسجيل الدخول من netsales_api يرث من الكيان الدوميني
class LoginResponseModel extends AuthResultEntity {
  const LoginResponseModel({
    super.require2fa,
    super.requirePasswordChange,
    super.isNewDevice,
    super.isPrimary,
    required super.sessionId,
    super.user,
    super.permissions,
    required super.userPhoneNumber,
    required super.deviceUuid,
    super.message,
  });

  factory LoginResponseModel.fromJson(dynamic json, {String? message}) {
    if (json is! Map) {
      return LoginResponseModel(
        sessionId: '',
        userPhoneNumber: '',
        deviceUuid: '',
        message: message,
      );
    }

    final map = Map<String, dynamic>.from(json);
    final is2fa = map['require_2fa'] == true;
    final deviceUuid = (map['device_uuid'] ?? '').toString();

    if (is2fa) {
      return LoginResponseModel(
        require2fa: true,
        isNewDevice: map['is_new_device'] == true,
        isPrimary: map['is_primary'] == true,
        sessionId: (map['session_id'] ?? '').toString(),
        userPhoneNumber: (map['user_phone_number'] ?? '').toString(),
        deviceUuid: deviceUuid,
        message: message,
      );
    }

    final rawPermissions = map['permissions'];
    final permissionsList = rawPermissions is List
        ? rawPermissions.map((e) => e.toString()).toList()
        : const <String>[];

    final rawUser = map['user'];
    final userModel = rawUser is Map
        ? UserModel.fromJson(Map<String, dynamic>.from(rawUser))
        : null;

    final userPhone = (map['user_phone_number'] ?? userModel?.userPhoneNumber ?? '').toString();
    final mustChangePassword = map['require_password_change'] == true ||
        userModel?.mustChangePassword == true;

    return LoginResponseModel(
      require2fa: false,
      requirePasswordChange: mustChangePassword,
      sessionId: (map['session_id'] ?? '').toString(),
      deviceUuid: deviceUuid,
      userPhoneNumber: userPhone,
      user: userModel,
      permissions: permissionsList,
      message: message,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'require_2fa': require2fa,
      'require_password_change': requirePasswordChange,
      'is_new_device': isNewDevice,
      'is_primary': isPrimary,
      'session_id': sessionId,
      'user': user?.toJson(),
      'permissions': permissions,
      'user_phone_number': userPhoneNumber,
      'device_uuid': deviceUuid,
      'message': message,
    };
  }
}
