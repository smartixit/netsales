import 'dart:io';

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

  /// استنتاج نوع الجهاز المعتمد تلقائياً وفق Enums الواجهة الخلفية
  static String detectDeviceType() {
    if (Platform.isAndroid) return 'ANDROID';
    if (Platform.isIOS) return 'IOS';
    if (Platform.isWindows) return 'WINDOWS';
    if (Platform.isMacOS) return 'MAC';
    if (Platform.isLinux) return 'LINUX';
    return 'UNKNOWN';
  }

  Map<String, dynamic> toJson() {
    return {
      'user_phone_number': userPhoneNumber,
      'user_password': userPassword,
      if (deviceUuid != null && deviceUuid!.isNotEmpty)
        'device_uuid': deviceUuid,
      if (deviceName != null && deviceName!.isNotEmpty)
        'device_name': deviceName,
      'device_type': deviceType ?? detectDeviceType(),
    };
  }
}
