/// نموذج طلب التحقق الثنائي وتأكيد الجهاز (VerifyTwoFactorRequestModel)
class VerifyTwoFactorRequestModel {
  final String userPhoneNumber;
  final String otp;
  final String deviceUuid;
  final String fcmToken;
  final String? deviceName;
  final String? deviceType;

  const VerifyTwoFactorRequestModel({
    required this.userPhoneNumber,
    required this.otp,
    required this.deviceUuid,
    required this.fcmToken,
    this.deviceName,
    this.deviceType,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_phone_number': userPhoneNumber,
      'otp': otp,
      'device_uuid': deviceUuid,
      'fcm_token': fcmToken,
      if (deviceName != null && deviceName!.isNotEmpty) 'device_name': deviceName,
      if (deviceType != null && deviceType!.isNotEmpty) 'device_type': deviceType,
    };
  }
}
