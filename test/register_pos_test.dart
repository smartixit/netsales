import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/features/auth/data/models/register_pos_request_model.dart';
import 'package:netsales/features/auth/data/models/register_pos_response_model.dart';
import 'package:netsales/features/auth/domain/entities/auth_result_entity.dart';
import 'package:netsales/features/auth/domain/entities/directorate_entity.dart';
import 'package:netsales/features/auth/domain/entities/governorate_entity.dart';
import 'package:netsales/features/auth/domain/entities/register_network_result_entity.dart';
import 'package:netsales/features/auth/domain/entities/register_pos_result_entity.dart';
import 'package:netsales/features/auth/domain/repositories/auth_repository.dart';
import 'package:netsales/features/auth/domain/usecases/register_pos_use_case.dart';

class MockRegisterPosAuthRepository implements AuthRepository {
  bool shouldSucceed = true;
  String? failureMessage;
  RegisterPosParams? capturedParams;

  @override
  Future<RegisterPosResultEntity> registerPos({
    required String posName,
    required int governorateId,
    required int directorateId,
    String? posEmail,
    String? posAddress,
    String? posProfileLogoPath,
    required String userFullName,
    required String userPhoneNumber,
    required String userPassword,
    String? userEmail,
    String? userProfileLogoPath,
    required String deviceUuid,
    required String fcmToken,
    String? deviceName,
    String? deviceType,
  }) async {
    capturedParams = RegisterPosParams(
      posName: posName,
      governorateId: governorateId,
      directorateId: directorateId,
      posEmail: posEmail,
      posAddress: posAddress,
      posProfileLogoPath: posProfileLogoPath,
      userFullName: userFullName,
      userPhoneNumber: userPhoneNumber,
      userPassword: userPassword,
      userEmail: userEmail,
      userProfileLogoPath: userProfileLogoPath,
      deviceUuid: deviceUuid,
      fcmToken: fcmToken,
      deviceName: deviceName,
      deviceType: deviceType,
    );

    if (!shouldSucceed) {
      throw Exception(failureMessage ?? 'فشل تسجيل نقطة البيع');
    }

    return RegisterPosResultEntity(
      success: true,
      message: 'تم استلام طلبكم، سيتم مراجعة الطلب واشعاركم في حال قبول الطلب.',
      posId: 101,
      posName: posName,
      userId: 55,
      userFullName: userFullName,
      status: 'PENDING',
    );
  }

  @override
  Future<List<GovernorateEntity>> getGovernorates() =>
      throw UnimplementedError();

  @override
  Future<List<DirectorateEntity>> getDirectorates(int governorateId) =>
      throw UnimplementedError();

  @override
  Future<RegisterNetworkResultEntity> registerNetwork({
    required String networkName,
    required int governorateId,
    required int directorateId,
    String? networkEmail,
    String? networkAddress,
    String? networkProfileLogoPath,
    required String userFullName,
    required String userPhoneNumber,
    required String userPassword,
    String? userEmail,
    String? userProfileLogoPath,
    required String deviceUuid,
    required String fcmToken,
    String? deviceName,
    String? deviceType,
  }) =>
      throw UnimplementedError();

  @override
  Future<AuthResultEntity> login({
    required String phoneNumber,
    required String password,
    required String deviceUuid,
    required String fcmToken,
    String? deviceName,
    String? deviceType,
  }) =>
      throw UnimplementedError();

  @override
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) =>
      throw UnimplementedError();

  @override
  Future<void> requestPasswordReset(String phoneNumber) =>
      throw UnimplementedError();

  @override
  Future<void> verifyResetOtp({
    required String phoneNumber,
    required String otp,
  }) =>
      throw UnimplementedError();

  @override
  Future<void> resetPassword({
    required String phoneNumber,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) =>
      throw UnimplementedError();

  @override
  Future<AuthResultEntity> verifyTwoFactor({
    required String phoneNumber,
    required String otp,
    required String deviceUuid,
    required String fcmToken,
    String? deviceName,
    String? deviceType,
  }) =>
      throw UnimplementedError();

  @override
  Future<void> resendOtp({
    required String phoneNumber,
    required String otpType,
    required String deviceUuid,
  }) =>
      throw UnimplementedError();
}

void main() {
  group('Register POS Model & Data Mapping Tests', () {
    test('RegisterPosRequestModel serializes cleanly matching backend contract without network_id', () {
      const model = RegisterPosRequestModel(
        posName: 'مركز الأمانة للخدمات',
        governorateId: 1,
        directorateId: 101,
        posEmail: 'pos@example.com',
        posAddress: 'صنعاء - شارع تعز',
        userFullName: 'محمد يحيى علي',
        userPhoneNumber: '777123456',
        userPassword: 'StrongPassword@2026',
        deviceUuid: 'uuid-pos-device-1234',
        fcmToken: 'fcm-token-xyz-pos',
      );

      final json = model.toJson();

      expect(json['pos_name'], 'مركز الأمانة للخدمات');
      expect(json['governorate_id'], 1);
      expect(json['directorate_id'], 101);
      expect(json['pos_email'], 'pos@example.com');
      expect(json['pos_address'], 'صنعاء - شارع تعز');
      expect(json['user_full_name'], 'محمد يحيى علي');
      expect(json['user_phone_number'], '777123456');
      expect(json['user_password'], 'StrongPassword@2026');
      expect(json['device_uuid'], 'uuid-pos-device-1234');
      expect(json['fcm_token'], 'fcm-token-xyz-pos');
      expect(json.containsKey('network_id'), isFalse,
          reason: 'network_id must NOT be present in pos registration request');
    });

    test('RegisterPosResponseModel parses API JSON and acts as pure polymorphic entity', () {
      final json = {
        'message': 'تم استلام طلبكم، سيتم مراجعة الطلب واشعاركم في حال قبول الطلب.',
        'pos': {
          'id': 101,
          'pos_id': 101,
          'pos_name': 'مركز الأمانة للخدمات',
          'status': 'PENDING',
        },
        'user': {
          'id': 55,
          'user_id': 55,
          'user_full_name': 'محمد يحيى علي',
        },
      };

      final model = RegisterPosResponseModel.fromJson(json);

      expect(model.success, isTrue);
      expect(model.posId, 101);
      expect(model.posName, 'مركز الأمانة للخدمات');
      expect(model.userId, 55);
      expect(model.userFullName, 'محمد يحيى علي');
      expect(model.status, 'PENDING');
      expect(model, isA<RegisterPosResultEntity>());
    });
  });

  group('RegisterPosUseCase Execution Tests', () {
    late MockRegisterPosAuthRepository mockRepository;
    late RegisterPosUseCase useCase;

    setUp(() {
      mockRepository = MockRegisterPosAuthRepository();
      useCase = RegisterPosUseCase(mockRepository);
    });

    test('executes successfully and forwards params to repository without network_id', () async {
      const params = RegisterPosParams(
        posName: 'سوبرماركت البركة',
        governorateId: 2,
        directorateId: 202,
        userFullName: 'خالد عبدالله عمر',
        userPhoneNumber: '733987654',
        userPassword: 'SecurePassword#456',
        deviceUuid: 'device-uuid-al-baraka',
        fcmToken: 'fcm-baraka-token',
      );

      final result = await useCase.execute(params);

      expect(result.success, isTrue);
      expect(result.posId, 101);
      expect(result.posName, 'سوبرماركت البركة');
      expect(result.status, 'PENDING');
      expect(mockRepository.capturedParams, isNotNull);
      expect(mockRepository.capturedParams!.posName, 'سوبرماركت البركة');
      expect(mockRepository.capturedParams!.userPhoneNumber, '733987654');
    });

    test('throws exception when repository fails', () async {
      mockRepository.shouldSucceed = false;
      mockRepository.failureMessage = 'رقم الهاتف مسجل مسبقاً في النظام';

      const params = RegisterPosParams(
        posName: 'سوبرماركت البركة',
        governorateId: 2,
        directorateId: 202,
        userFullName: 'خالد عبدالله عمر',
        userPhoneNumber: '733987654',
        userPassword: 'SecurePassword#456',
        deviceUuid: 'device-uuid-al-baraka',
        fcmToken: 'fcm-baraka-token',
      );

      expect(
        () => useCase.execute(params),
        throwsA(isA<Exception>()),
      );
    });
  });
}
