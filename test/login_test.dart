import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/models/user_model.dart';
import 'package:netsales/core/utils/form_validators.dart';
import 'package:netsales/features/auth/data/models/login_request_model.dart';
import 'package:netsales/features/auth/data/models/login_response_model.dart';
import 'package:netsales/features/auth/domain/entities/auth_result_entity.dart';
import 'package:netsales/features/auth/domain/repositories/auth_repository.dart';
import 'package:netsales/features/auth/domain/usecases/login_use_case.dart';

class MockAuthRepository implements AuthRepository {
  bool shouldSucceed = true;
  bool require2fa = false;

  @override
  Future<AuthResultEntity> login({
    required String phoneNumber,
    required String password,
    required String deviceUuid,
    required String fcmToken,
    String? deviceName,
    String? deviceType,
  }) async {
    if (!shouldSucceed) {
      throw Exception('بيانات الاعتماد غير صحيحة');
    }

    if (require2fa) {
      return AuthResultEntity(
        require2fa: true,
        userPhoneNumber: phoneNumber,
        deviceUuid: deviceUuid,
        sessionId: '',
      );
    }

    return AuthResultEntity(
      require2fa: false,
      sessionId: 'test-session-token-12345',
      user: UserModel(
        userId: 1,
        userFullName: 'حسام خالد',
        userPhoneNumber: phoneNumber,
      ),
      permissions: ['pos.view', 'sales.create'],
      userPhoneNumber: phoneNumber,
      deviceUuid: deviceUuid,
    );
  }

  @override
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (!shouldSucceed) {
      throw Exception('فشل تحديث كلمة المرور');
    }
  }

  @override
  Future<void> requestPasswordReset(String phoneNumber) async {
    if (!shouldSucceed) {
      throw Exception('فشل طلب استعادة كلمة المرور');
    }
  }

  @override
  Future<void> verifyResetOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    if (!shouldSucceed) {
      throw Exception('كود التحقق غير صالح');
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Login Form Validators Tests', () {
    test(
      'phoneValidator rejects empty, invalid prefixes, or invalid lengths',
      () {
        final validator = FormValidators.phoneValidator(
          fieldName: 'رقم الهاتف',
        );

        expect(validator(null), isNotNull);
        expect(validator(''), isNotNull);

        // Not starting with 7
        expect(validator('123456789'), contains('يبدأ بـ 7'));
        expect(validator('672957881'), contains('يبدأ بـ 7'));

        // Incorrect length
        expect(validator('77295788'), contains('9'));
        expect(validator('7729578810'), contains('9'));

        // Valid numbers (Yemen Mobile, YOU, Sabafon, Y)
        expect(validator('772957881'), isNull);
        expect(validator('782957881'), isNull);
        expect(validator('732957881'), isNull);
        expect(validator('712957881'), isNull);
        expect(validator('702957881'), isNull);

        // International or local prefix variants rejected by start rule
        expect(validator('+967772957881'), contains('يبدأ بـ 7'));
        expect(validator('00967772957881'), contains('يبدأ بـ 7'));
        expect(validator('0772957881'), contains('يبدأ بـ 7'));
      },
    );

    test('passwordValidator enforces required and password complexity', () {
      final validator = FormValidators.passwordValidator(
        fieldName: 'كلمة المرور',
      );

      expect(validator(null), isNotNull);
      expect(validator(''), isNotNull);
      expect(validator('12345'), isNotNull);
      expect(validator('Admin@123456'), isNull);
    });
  });

  group('Login Models and Data Mapping Tests', () {
    test(
      'LoginRequestModel serializes correctly with detected device type',
      () {
        final model = LoginRequestModel(
          userPhoneNumber: '772957881',
          userPassword: 'SecretPassword',
          deviceUuid: 'DEV-12345',
          fcmToken: 'test-fcm-token-123',
          deviceName: 'Test Phone',
        );

        final json = model.toJson();
        expect(json['user_phone_number'], '772957881');
        expect(json['user_password'], 'SecretPassword');
        expect(json['device_uuid'], 'DEV-12345');
        expect(json['fcm_token'], 'test-fcm-token-123');
        expect(json['device_name'], 'Test Phone');
        expect(json['device_type'], isNotEmpty);
      },
    );

    test('LoginResponseModel parses direct success response', () {
      final rawJson = {
        'session_id': 'session-token-xyz',
        'require_2fa': false,
        'user': {
          'user_id': 10,
          'user_full_name': 'عمر سالم',
          'user_phone_number': '772957881',
        },
        'permissions': ['dashboard.view', 'pos.manage'],
      };

      final response = LoginResponseModel.fromJson(rawJson);
      expect(response.require2fa, isFalse);
      expect(response.sessionId, 'session-token-xyz');
      expect(response.user?.userId, 10);
      expect(response.user?.userFullName, 'عمر سالم');
      expect(response.permissions, contains('pos.manage'));
    });

    test('LoginResponseModel parses 2FA required response', () {
      final rawJson = {
        'require_2fa': true,
        'is_new_device': true,
        'user_phone_number': '772957881',
        'device_uuid': 'DEV-999',
      };

      final response = LoginResponseModel.fromJson(rawJson);
      expect(response.require2fa, isTrue);
      expect(response.isNewDevice, isTrue);
      expect(response.userPhoneNumber, '772957881');
      expect(response.deviceUuid, 'DEV-999');
      expect(response.sessionId, isEmpty);
    });
  });

  group('LoginUseCase Tests', () {
    test('executes login successfully with mock repository', () async {
      final repo = MockAuthRepository();
      final useCase = LoginUseCase(repo);

      final result = await useCase.execute(
        const LoginParams(
          phoneNumber: '772957881',
          password: 'Password123',
          deviceUuid: 'DEV-12345',
          fcmToken: 'test-fcm-token-123',
        ),
      );

      expect(result.sessionId, 'test-session-token-12345');
      expect(result.user?.userFullName, 'حسام خالد');
    });

    test('executes login and flags 2FA requirement', () async {
      final repo = MockAuthRepository()..require2fa = true;
      final useCase = LoginUseCase(repo);

      final result = await useCase.execute(
        const LoginParams(
          phoneNumber: '772957881',
          password: 'Password123',
          deviceUuid: 'DEV-12345',
          fcmToken: 'test-fcm-token-123',
        ),
      );

      expect(result.require2fa, isTrue);
    });
  });
}
