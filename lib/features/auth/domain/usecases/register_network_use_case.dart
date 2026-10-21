import 'package:netsales/features/auth/domain/entities/register_network_result_entity.dart';
import 'package:netsales/features/auth/domain/repositories/auth_repository.dart';

/// معلمات حالة استخدام تقديم طلب تسجيل شبكة جديدة (RegisterNetworkParams)
class RegisterNetworkParams {
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

  const RegisterNetworkParams({
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
}

/// حالة استخدام تسجيل شبكة جديدة ومسؤولها بحالة PENDING (RegisterNetworkUseCase)
class RegisterNetworkUseCase {
  const RegisterNetworkUseCase(this._repository);

  final AuthRepository _repository;

  Future<RegisterNetworkResultEntity> execute(RegisterNetworkParams params) {
    return _repository.registerNetwork(
      networkName: params.networkName,
      governorateId: params.governorateId,
      directorateId: params.directorateId,
      networkEmail: params.networkEmail,
      networkAddress: params.networkAddress,
      networkProfileLogoPath: params.networkProfileLogoPath,
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
