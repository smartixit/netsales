import 'package:netsales/features/auth/domain/entities/register_pos_result_entity.dart';
import 'package:netsales/features/auth/domain/repositories/auth_repository.dart';

/// معلمات حالة استخدام تقديم طلب تسجيل نقطة بيع جديدة (RegisterPosParams)
class RegisterPosParams {
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

  const RegisterPosParams({
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
}

/// حالة استخدام تسجيل نقطة بيع جديدة ومسؤولها بحالة PENDING (RegisterPosUseCase)
class RegisterPosUseCase {
  const RegisterPosUseCase(this._repository);

  final AuthRepository _repository;

  Future<RegisterPosResultEntity> execute(RegisterPosParams params) {
    return _repository.registerPos(
      posName: params.posName,
      governorateId: params.governorateId,
      directorateId: params.directorateId,
      posEmail: params.posEmail,
      posAddress: params.posAddress,
      posProfileLogoPath: params.posProfileLogoPath,
      userFullName: params.userFullName,
      userPhoneNumber: params.userPhoneNumber,
      userPassword: params.userPassword,
      userEmail: params.userEmail,
      userProfileLogoPath: params.userProfileLogoPath,
      deviceUuid: params.deviceUuid,
      fcmToken: params.fcmToken,
      deviceName: params.deviceName,
      deviceType: params.deviceType,
    );
  }
}
