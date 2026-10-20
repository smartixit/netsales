/// نموذج طلب تسجيل الدخول المطابق لـ LoginRequest في netsales_api
class LoginRequestModel {
  final String userPhoneNumber;
  final String userPassword;
  final String deviceUuid;
  final String fcmToken;
  final String? deviceName;
  final String? deviceType;

  const LoginRequestModel({
    required this.userPhoneNumber,
    required this.userPassword,
    required this.deviceUuid,
    required this.fcmToken,
    this.deviceName,
    this.deviceType,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_phone_number': userPhoneNumber,
      'user_password': userPassword,
      'device_uuid': deviceUuid,
      'fcm_token': fcmToken,
      if (deviceName != null && deviceName!.isNotEmpty)
        'device_name': deviceName,
      'device_type': deviceType ?? 'UNKNOWN',
    };
  }
}
