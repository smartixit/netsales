import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/models/user_model.dart';
import 'package:netsales/core/models/user_session_model.dart';
import 'package:netsales/core/services/permission_service.dart';
import 'package:netsales/core/services/session_service.dart';
import 'package:netsales/core/services/storage_service.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/features/auth/domain/repositories/auth_repository.dart';
import 'package:netsales/features/auth/domain/usecases/request_two_factor_otp_use_case.dart';
import 'package:netsales/features/auth/domain/usecases/toggle_two_factor_use_case.dart';
import 'package:netsales/features/auth/presentation/controllers/security_settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockAuthRepository implements AuthRepository {
  bool requestOtpCalled = false;
  bool toggleCalled = false;
  bool? lastEnable;
  String? lastOtp;
  String? lastCurrentPassword;

  bool shouldThrowOnRequestOtp = false;
  bool shouldThrowOnToggle = false;
  String throwErrorMessage = 'خطأ أمني';

  @override
  Future<void> requestTwoFactorOtp({
    String? deviceUuid,
    String? appHash,
  }) async {
    requestOtpCalled = true;
    if (shouldThrowOnRequestOtp) {
      throw AppException(throwErrorMessage);
    }
  }

  @override
  Future<void> toggleTwoFactor({
    required bool enable,
    String? otp,
    String? currentPassword,
    String? deviceUuid,
    String? appHash,
  }) async {
    toggleCalled = true;
    lastEnable = enable;
    lastOtp = otp;
    lastCurrentPassword = currentPassword;

    if (shouldThrowOnToggle) {
      throw AppException(throwErrorMessage);
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthRepository mockAuthRepository;
  late RequestTwoFactorOtpUseCase requestOtpUseCase;
  late ToggleTwoFactorUseCase toggleUseCase;
  late SecuritySettingsController controller;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    Get.reset();
    await StorageService.instance.init();
    Get.put<StorageService>(StorageService.instance);
    Get.put<PermissionService>(PermissionService.instance);
    Get.put<WorkspaceService>(WorkspaceService.instance);
    Get.put<SessionService>(SessionService.instance);
    await SessionService.instance.init();

    mockAuthRepository = MockAuthRepository();
    requestOtpUseCase = RequestTwoFactorOtpUseCase(mockAuthRepository);
    toggleUseCase = ToggleTwoFactorUseCase(mockAuthRepository);
  });

  tearDown(() {
    Get.reset();
  });

  UserModel createTestUser({bool user2faEnabled = false}) {
    return UserModel(
      userId: 55,
      userFullName: 'علي صالح',
      userPhoneNumber: '771234567',
      user2faEnabled: user2faEnabled,
    );
  }

  Future<void> setupSessionUser({bool user2faEnabled = false}) async {
    await SessionService.to.startSession(
      user: createTestUser(user2faEnabled: user2faEnabled),
      session: const UserSessionModel(sessionId: 'test_session_id', userId: 55),
      permissions: const [],
    );
  }

  group('2FA Security Settings & Lifecycle Tests', () {
    test(
      'Initializes with user 2FA status from SessionService (Disabled)',
      () async {
        await setupSessionUser(user2faEnabled: false);

        controller = SecuritySettingsController(
          requestTwoFactorOtpUseCase: requestOtpUseCase,
          toggleTwoFactorUseCase: toggleUseCase,
        );
        controller.onInit();

        expect(controller.is2faEnabled.value, isFalse);
        expect(controller.maskedPhone, equals('771***567'));
      },
    );

    test(
      'Initializes with user 2FA status from SessionService (Enabled)',
      () async {
        await setupSessionUser(user2faEnabled: true);

        controller = SecuritySettingsController(
          requestTwoFactorOtpUseCase: requestOtpUseCase,
          toggleTwoFactorUseCase: toggleUseCase,
        );
        controller.onInit();

        expect(controller.is2faEnabled.value, isTrue);
      },
    );

    test('requestOtpForEnable calls repository and starts cooldown', () async {
      await setupSessionUser(user2faEnabled: false);

      controller = SecuritySettingsController(
        requestTwoFactorOtpUseCase: requestOtpUseCase,
        toggleTwoFactorUseCase: toggleUseCase,
      );
      controller.onInit();

      final success = await controller.requestOtpForEnable();

      expect(success, isTrue);
      expect(mockAuthRepository.requestOtpCalled, isTrue);
      expect(controller.canResend.value, isFalse);
      expect(controller.cooldownSeconds.value, equals(60));
    });

    test('requestOtpForEnable handles failure gracefully', () async {
      await setupSessionUser(user2faEnabled: false);

      mockAuthRepository.shouldThrowOnRequestOtp = true;
      mockAuthRepository.throwErrorMessage =
          'تم تجاوز الحد الأقصى اليومي لطلب الرمز';

      controller = SecuritySettingsController(
        requestTwoFactorOtpUseCase: requestOtpUseCase,
        toggleTwoFactorUseCase: toggleUseCase,
      );
      controller.onInit();

      final success = await controller.requestOtpForEnable();

      expect(success, isFalse);
      expect(controller.isRequestingOtp.value, isFalse);
    });

    test(
      'confirmEnable2fa rejects short OTP (< 6 digits) without calling backend',
      () async {
        await setupSessionUser(user2faEnabled: false);

        controller = SecuritySettingsController(
          requestTwoFactorOtpUseCase: requestOtpUseCase,
          toggleTwoFactorUseCase: toggleUseCase,
        );
        controller.onInit();

        final success = await controller.confirmEnable2fa('123');

        expect(success, isFalse);
        expect(mockAuthRepository.toggleCalled, isFalse);
        expect(controller.is2faEnabled.value, isFalse);
      },
    );

    test(
      'confirmEnable2fa successfully enables 2FA and updates SessionService',
      () async {
        await setupSessionUser(user2faEnabled: false);

        controller = SecuritySettingsController(
          requestTwoFactorOtpUseCase: requestOtpUseCase,
          toggleTwoFactorUseCase: toggleUseCase,
        );
        controller.onInit();

        final success = await controller.confirmEnable2fa('654321');

        expect(success, isTrue);
        expect(mockAuthRepository.toggleCalled, isTrue);
        expect(mockAuthRepository.lastEnable, isTrue);
        expect(mockAuthRepository.lastOtp, equals('654321'));
        expect(controller.is2faEnabled.value, isTrue);
        expect(SessionService.to.currentUser?.user2faEnabled, isTrue);
      },
    );

    test('confirmEnable2fa failure keeps 2FA disabled', () async {
      await setupSessionUser(user2faEnabled: false);

      mockAuthRepository.shouldThrowOnToggle = true;
      mockAuthRepository.throwErrorMessage =
          'رمز التحقق غير صحيح أو منتهي الصلاحية';

      controller = SecuritySettingsController(
        requestTwoFactorOtpUseCase: requestOtpUseCase,
        toggleTwoFactorUseCase: toggleUseCase,
      );
      controller.onInit();

      final success = await controller.confirmEnable2fa('000000');

      expect(success, isFalse);
      expect(controller.is2faEnabled.value, isFalse);
      expect(SessionService.to.currentUser?.user2faEnabled, isFalse);
    });

    test(
      'confirmDisable2fa rejects empty password without calling backend',
      () async {
        await setupSessionUser(user2faEnabled: true);

        controller = SecuritySettingsController(
          requestTwoFactorOtpUseCase: requestOtpUseCase,
          toggleTwoFactorUseCase: toggleUseCase,
        );
        controller.onInit();

        final success = await controller.confirmDisable2fa('   ');

        expect(success, isFalse);
        expect(mockAuthRepository.toggleCalled, isFalse);
        expect(controller.is2faEnabled.value, isTrue);
      },
    );

    test(
      'confirmDisable2fa successfully disables 2FA with current password',
      () async {
        await setupSessionUser(user2faEnabled: true);

        controller = SecuritySettingsController(
          requestTwoFactorOtpUseCase: requestOtpUseCase,
          toggleTwoFactorUseCase: toggleUseCase,
        );
        controller.onInit();

        final success = await controller.confirmDisable2fa(
          'MyCurrentPassword@123',
        );

        expect(success, isTrue);
        expect(mockAuthRepository.toggleCalled, isTrue);
        expect(mockAuthRepository.lastEnable, isFalse);
        expect(
          mockAuthRepository.lastCurrentPassword,
          equals('MyCurrentPassword@123'),
        );
        expect(controller.is2faEnabled.value, isFalse);
        expect(SessionService.to.currentUser?.user2faEnabled, isFalse);
      },
    );

    test(
      'confirmDisable2fa failure (wrong password) keeps 2FA enabled',
      () async {
        await setupSessionUser(user2faEnabled: true);

        mockAuthRepository.shouldThrowOnToggle = true;
        mockAuthRepository.throwErrorMessage = 'كلمة المرور الحالية غير صحيحة';

        controller = SecuritySettingsController(
          requestTwoFactorOtpUseCase: requestOtpUseCase,
          toggleTwoFactorUseCase: toggleUseCase,
        );
        controller.onInit();

        final success = await controller.confirmDisable2fa('WrongPassword');

        expect(success, isFalse);
        expect(controller.is2faEnabled.value, isTrue);
        expect(SessionService.to.currentUser?.user2faEnabled, isTrue);
      },
    );
  });
}
