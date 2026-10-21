import 'dart:io';
import 'package:dio/dio.dart';

/// نموذج طلب تسجيل شبكة جديدة (RegisterNetworkRequestModel)
class RegisterNetworkRequestModel {
  final String networkName;
  final int governorateId;
  final int directorateId;
  final String? networkEmail;
  final String? networkAddress;
  final String? networkProfileLogoPath;
  final String userFullName;
  final String userPhoneNumber;
  final String userPassword;
  final String? userEmail;
  final String? userProfileLogoPath;
  final String deviceUuid;
  final String fcmToken;
  final String? deviceName;
  final String? deviceType;

  const RegisterNetworkRequestModel({
    required this.networkName,
    required this.governorateId,
    required this.directorateId,
    this.networkEmail,
    this.networkAddress,
    this.networkProfileLogoPath,
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

  bool get hasFiles =>
      (networkProfileLogoPath != null && networkProfileLogoPath!.isNotEmpty) ||
      (userProfileLogoPath != null && userProfileLogoPath!.isNotEmpty);

  Map<String, dynamic> toJson() {
    return {
      'network_name': networkName,
      'governorate_id': governorateId,
      'directorate_id': directorateId,
      if (networkEmail != null && networkEmail!.trim().isNotEmpty)
        'network_email': networkEmail!.trim(),
      if (networkAddress != null && networkAddress!.trim().isNotEmpty)
        'network_address': networkAddress!.trim(),
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

  Future<FormData> toFormData() async {
    final map = toJson();
    if (networkProfileLogoPath != null && networkProfileLogoPath!.isNotEmpty) {
      final file = File(networkProfileLogoPath!);
      if (file.existsSync()) {
        map['network_profile_logo'] = await MultipartFile.fromFile(
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
