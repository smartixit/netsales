import 'dart:io';
import 'package:dio/dio.dart';

/// نموذج حمولة طلب تسجيل نقطة بيع / وكيل جديد (RegisterPosRequestModel)
///
/// مطابق بنسبة 100% لعقد الباك إند المعتمد في:
/// App\Http\Requests\API\V1\Auth\RegisterPosRequest
class RegisterPosRequestModel {
  final String posName;
  final int governorateId;
  final int directorateId;
  final String? posEmail;
  final String? posAddress;
  final String? posProfileLogoPath;
  final String userFullName;
  final String userPhoneNumber;
  final String userPassword;
  final String? userEmail;
  final String? userProfileLogoPath;
  final String deviceUuid;
  final String fcmToken;
  final String? deviceName;
  final String? deviceType;

  const RegisterPosRequestModel({
    required this.posName,
    required this.governorateId,
    required this.directorateId,
    this.posEmail,
    this.posAddress,
    this.posProfileLogoPath,
    required this.userFullName,
    required this.userPhoneNumber,
    required this.userPassword,
    this.userEmail,
    this.userProfileLogoPath,
    required this.deviceUuid,
    required this.fcmToken,
    this.deviceName,
    this.deviceType,
  });

  /// فحص احتواء الطلب على ملفات أو شعارات مرفوعة
  bool get hasFiles =>
      (posProfileLogoPath != null && posProfileLogoPath!.isNotEmpty) ||
      (userProfileLogoPath != null && userProfileLogoPath!.isNotEmpty);

  /// تحويل البيانات لحمولة Map قياسية
  Map<String, dynamic> toJson() {
    return {
      'pos_name': posName,
      'governorate_id': governorateId,
      'directorate_id': directorateId,
      if (posEmail != null && posEmail!.trim().isNotEmpty)
        'pos_email': posEmail!.trim(),
      if (posAddress != null && posAddress!.trim().isNotEmpty)
        'pos_address': posAddress!.trim(),
      'user_full_name': userFullName,
      'user_phone_number': userPhoneNumber,
      'user_password': userPassword,
      if (userEmail != null && userEmail!.trim().isNotEmpty)
        'user_email': userEmail!.trim(),
      'device_uuid': deviceUuid,
      'fcm_token': fcmToken,
      if (deviceName != null && deviceName!.trim().isNotEmpty)
        'device_name': deviceName!.trim(),
      if (deviceType != null && deviceType!.trim().isNotEmpty)
        'device_type': deviceType!.trim(),
    };
  }

  /// تحويل البيانات لصيغة FormData متعددة الأجزاء (Multipart) عند وجود وسائط
  Future<FormData> toFormData() async {
    final map = toJson();
    if (posProfileLogoPath != null && posProfileLogoPath!.isNotEmpty) {
      final file = File(posProfileLogoPath!);
      if (file.existsSync()) {
        map['pos_profile_logo'] = await MultipartFile.fromFile(
          file.path,
          filename: file.uri.pathSegments.last,
        );
      }
    }
    if (userProfileLogoPath != null && userProfileLogoPath!.isNotEmpty) {
      final file = File(userProfileLogoPath!);
      if (file.existsSync()) {
        map['user_profile_logo'] = await MultipartFile.fromFile(
          file.path,
          filename: file.uri.pathSegments.last,
        );
      }
    }
    return FormData.fromMap(map);
  }
}
