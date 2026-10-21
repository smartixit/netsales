import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/features/auth/data/models/reset_password_request_model.dart';
import 'package:netsales/features/auth/domain/entities/auth_result_entity.dart';
import 'package:netsales/features/auth/domain/entities/directorate_entity.dart';
import 'package:netsales/features/auth/domain/entities/governorate_entity.dart';
import 'package:netsales/features/auth/domain/entities/register_network_result_entity.dart';
import 'package:netsales/features/auth/domain/repositories/auth_repository.dart';
import 'package:netsales/features/auth/domain/usecases/reset_password_use_case.dart';

class MockResetPasswordAuthRepository implements AuthRepository {
  bool shouldSucceed = true;
  String? capturedPhone;
  String? capturedOtp;
  String? capturedNewPassword;
  String? capturedConfirmPassword;

  @override
  Future<void> resetPassword({
    required String phoneNumber,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async {
    capturedPhone = phoneNumber;
    capturedOtp = otp;
    capturedNewPassword = newPassword;
    capturedConfirmPassword = confirmPassword;

    if (!shouldSucceed) {
      throw Exception('رمز التحقق غير صحيح أو منتهي الصلاحية');
    }
  }

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
}

void main() {
  group('Direct Password Reset Model Tests (Data Layer)', () {
    test('ResetPasswordRequestModel serializes cleanly matching backend contract', () {
      const model = ResetPasswordRequestModel(
        userPhoneNumber: '772957881',
        otp: '123456',
        password: 'NewSecret@123',
        passwordConfirmation: 'NewSecret@123',
      );

      final json = model.toJson();

      expect(json['user_phone_number'], '772957881');
      expect(json['otp'], '123456');
      expect(json['password'], 'NewSecret@123');
      expect(json['password_confirmation'], 'NewSecret@123');
    });
  });

  group('Direct Password Reset UseCase Tests (Domain Layer)', () {
    late MockResetPasswordAuthRepository mockRepository;
    late ResetPasswordUseCase useCase;

    setUp(() {
      mockRepository = MockResetPasswordAuthRepository();
      useCase = ResetPasswordUseCase(mockRepository);
    });

    test('ResetPasswordUseCase delegates parameters correctly and succeeds', () async {
      mockRepository.shouldSucceed = true;

      await useCase.execute(
        const ResetPasswordParams(
          phoneNumber: '772957881',
          otp: '654321',
          newPassword: 'StrongPassword@2026',
          confirmPassword: 'StrongPassword@2026',
        ),
      );

      expect(mockRepository.capturedPhone, '772957881');
      expect(mockRepository.capturedOtp, '654321');
      expect(mockRepository.capturedNewPassword, 'StrongPassword@2026');
      expect(mockRepository.capturedConfirmPassword, 'StrongPassword@2026');
    });

    test('ResetPasswordUseCase propagates domain failure exception when repository throws', () async {
      mockRepository.shouldSucceed = false;

      expect(
        () => useCase.execute(
          const ResetPasswordParams(
            phoneNumber: '772957881',
            otp: '000000',
            newPassword: 'StrongPassword@2026',
            confirmPassword: 'StrongPassword@2026',
          ),
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
