/// نموذج طلب تسجيل الدخول المطابق لـ LoginRequest في netsales_api
class LoginRequestModel {
  final String userPhoneNumber;
  final String userPassword;
  final String? deviceUuid;
  final String? deviceName;
  final String? deviceType;

  const LoginRequestModel({
    required this.userPhoneNumber,
    required this.userPassword,
    this.deviceUuid,
    this.deviceName,
    this.deviceType,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_phone_number': userPhoneNumber,
      'user_password': userPassword,
      if (deviceUuid != null && deviceUuid!.isNotEmpty)
        'device_uuid': deviceUuid,
      if (deviceName != null && deviceName!.isNotEmpty)
        'device_name': deviceName,
      'device_type': deviceType ?? 'UNKNOWN',
    };
  }
}
