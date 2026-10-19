import 'package:netsales/core/models/user_model.dart';

/// نموذج استجابة تسجيل الدخول من netsales_api
class LoginResponseModel {
  final bool require2fa;
  final bool isNewDevice;
  final bool isPrimary;
  final String? sessionId;
  final UserModel? user;
  final List<String> permissions;
  final String? userPhoneNumber;
  final String? deviceUuid;

  const LoginResponseModel({
    this.require2fa = false,
    this.isNewDevice = false,
    this.isPrimary = false,
    this.sessionId,
    this.user,
    this.permissions = const [],
    this.userPhoneNumber,
    this.deviceUuid,
  });

  factory LoginResponseModel.fromJson(dynamic json) {
    if (json is! Map) {
      return const LoginResponseModel();
    }

    final map = Map<String, dynamic>.from(json);
    final is2fa = map['require_2fa'] == true;

    if (is2fa) {
      return LoginResponseModel(
        require2fa: true,
        isNewDevice: map['is_new_device'] == true,
        isPrimary: map['is_primary'] == true,
        userPhoneNumber: map['user_phone_number']?.toString(),
        deviceUuid: map['device_uuid']?.toString(),
      );
    }

    final rawPermissions = map['permissions'];
    final permissionsList = rawPermissions is List
        ? rawPermissions.map((e) => e.toString()).toList()
        : <String>[];

    final rawUser = map['user'];
    final userModel = rawUser is Map
        ? UserModel.fromJson(Map<String, dynamic>.from(rawUser))
        : null;

    return LoginResponseModel(
      require2fa: false,
      sessionId: map['session_id']?.toString(),
      user: userModel,
      permissions: permissionsList,
    );
  }
}
