import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/utils/form_validators.dart';
import 'package:netsales/features/auth/data/models/directorate_model.dart';
import 'package:netsales/features/auth/data/models/governorate_model.dart';
import 'package:netsales/features/auth/data/models/register_network_request_model.dart';
import 'package:netsales/features/auth/data/models/register_network_response_model.dart';
import 'package:netsales/features/auth/domain/entities/directorate_entity.dart';
import 'package:netsales/features/auth/domain/entities/governorate_entity.dart';
import 'package:netsales/features/auth/domain/entities/register_network_result_entity.dart';
import 'package:netsales/features/auth/domain/entities/register_pos_result_entity.dart';
import 'package:netsales/features/auth/domain/repositories/auth_repository.dart';
import 'package:netsales/features/auth/domain/usecases/get_directorates_use_case.dart';
import 'package:netsales/features/auth/domain/usecases/get_governorates_use_case.dart';
import 'package:netsales/features/auth/domain/usecases/register_network_use_case.dart';
import 'package:netsales/features/auth/domain/entities/auth_result_entity.dart';

class MockRegisterNetworkAuthRepository implements AuthRepository {
  bool shouldSucceed = true;
  String? failureMessage;

  @override
  Future<List<GovernorateEntity>> getGovernorates() async {
    if (!shouldSucceed) {
      throw Exception(failureMessage ?? 'فشل جلب المحافظات');
    }
    return const [
      GovernorateEntity(governorateId: 1, governorateName: 'صنعاء'),
      GovernorateEntity(governorateId: 2, governorateName: 'عدن'),
    ];
  }

  @override
  Future<List<DirectorateEntity>> getDirectorates(int governorateId) async {
    if (!shouldSucceed) {
      throw Exception(failureMessage ?? 'فشل جلب المديريات');
    }
    return [
      DirectorateEntity(
        directorateId: 101,
        governorateId: governorateId,
        directorateName: 'مديرية التحرير',
      ),
      DirectorateEntity(
        directorateId: 102,
        governorateId: governorateId,
        directorateName: 'مديرية الصافية',
      ),
    ];
  }

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
  }) async {
    if (!shouldSucceed) {
      throw Exception(failureMessage ?? 'فشل تسجيل الشبكة');
    }
    return RegisterNetworkResultEntity(
      success: true,
      message: 'تم استلام طلبكم، سيتم مراجعة الطلب واشعاركم في حال قبول الطلب.',
      networkId: 10,
      networkName: networkName,
      userId: 25,
      status: 'PENDING',
    );
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
  Future<void> resetPassword({
    required String phoneNumber,
    required String otp,
    required String newPassword,
    required String confirmPassword,
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
  }) =>
      throw UnimplementedError();
}

void main() {
  group('Geography Models & Data Mapping Tests', () {
    test('GovernorateModel correctly parses API JSON and acts as entity', () {
      final json = {
        'id': 1,
        'name': 'أمانة العاصمة',
      };

      final model = GovernorateModel.fromJson(json);

      expect(model.governorateId, 1);
      expect(model.governorateName, 'أمانة العاصمة');
      expect(model, isA<GovernorateEntity>());
    });

    test('DirectorateModel correctly parses API JSON and acts as entity', () {
      final json = {
        'id': 105,
        'governorate_id': 1,
        'name': 'مديرية السبعين',
      };

      final model = DirectorateModel.fromJson(json);

      expect(model.directorateId, 105);
      expect(model.governorateId, 1);
      expect(model.directorateName, 'مديرية السبعين');
      expect(model, isA<DirectorateEntity>());
    });

    test('RegisterNetworkRequestModel serializes cleanly matching backend requirements', () {
      final request = RegisterNetworkRequestModel(
        networkName: 'شبكة السرعة الفائقة',
        governorateId: 1,
        directorateId: 105,
        networkEmail: 'contact@superspeed.net',
        networkAddress: 'شارع حدة، أمام مركز الكمبيوتر',
        userFullName: 'عمار عبد العزيز',
        userPhoneNumber: '771234567',
        userPassword: 'StrongPassword123',
        userEmail: 'ammar@superspeed.net',
        deviceUuid: 'uuid-phone-test-99',
        fcmToken: 'fcm-token-test-99',
        deviceName: 'Samsung S24',
        deviceType: 'MOBILE',
      );

      final json = request.toJson();

      expect(json['network_name'], 'شبكة السرعة الفائقة');
      expect(json['governorate_id'], 1);
      expect(json['directorate_id'], 105);
      expect(json['network_email'], 'contact@superspeed.net');
      expect(json['network_address'], 'شارع حدة، أمام مركز الكمبيوتر');
      expect(json['user_full_name'], 'عمار عبد العزيز');
      expect(json['user_phone_number'], '771234567');
      expect(json['user_password'], 'StrongPassword123');
      expect(json['user_email'], 'ammar@superspeed.net');
      expect(json['device_uuid'], 'uuid-phone-test-99');
      expect(json['fcm_token'], 'fcm-token-test-99');
      expect(json['device_name'], 'Samsung S24');
      expect(json['device_type'], 'MOBILE');
    });

    test('RegisterNetworkResponseModel parses backend review confirmation', () {
      final json = {
        'message': 'تم استلام طلبكم، سيتم مراجعة الطلب واشعاركم في حال قبول الطلب.',
        'network': {
          'network_id': 10,
          'network_name': 'شبكة السرعة الفائقة',
          'status': 'PENDING',
        },
        'user': {
          'user_id': 25,
          'user_full_name': 'عمار عبد العزيز',
        },
      };

      final response = RegisterNetworkResponseModel.fromJson(json);

      expect(response.success, isTrue);
      expect(response.networkId, 10);
      expect(response.networkName, 'شبكة السرعة الفائقة');
      expect(response.userId, 25);
      expect(response.userFullName, 'عمار عبد العزيز');
      expect(response.status, 'PENDING');
      expect(response, isA<RegisterNetworkResultEntity>());
    });
  });

  group('Register Network UseCases Tests', () {
    late MockRegisterNetworkAuthRepository mockRepository;
    late GetGovernoratesUseCase getGovernoratesUseCase;
    late GetDirectoratesUseCase getDirectoratesUseCase;
    late RegisterNetworkUseCase registerNetworkUseCase;

    setUp(() {
      mockRepository = MockRegisterNetworkAuthRepository();
      getGovernoratesUseCase = GetGovernoratesUseCase(mockRepository);
      getDirectoratesUseCase = GetDirectoratesUseCase(mockRepository);
      registerNetworkUseCase = RegisterNetworkUseCase(mockRepository);
    });

    test('GetGovernoratesUseCase fetches list of governorates', () async {
      final governorates = await getGovernoratesUseCase.execute();
      expect(governorates.length, 2);
      expect(governorates.first.governorateName, 'صنعاء');
    });

    test('GetDirectoratesUseCase fetches directorates for a specific governorate', () async {
      final directorates = await getDirectoratesUseCase.execute(1);
      expect(directorates.length, 2);
      expect(directorates.first.directorateName, 'مديرية التحرير');
      expect(directorates.first.governorateId, 1);
    });

    test('RegisterNetworkUseCase executes registration and returns pending review entity', () async {
      final params = RegisterNetworkParams(
        networkName: 'شبكة الأمل اللاسلكية',
        governorateId: 1,
        directorateId: 101,
        userFullName: 'فؤاد سالم',
        userPhoneNumber: '733123456',
        userPassword: 'SecurePassword123!',
        deviceUuid: 'uuid-12345',
        fcmToken: 'fcm-12345',
      );

      final result = await registerNetworkUseCase.execute(params);

      expect(result.success, isTrue);
      expect(result.networkName, 'شبكة الأمل اللاسلكية');
      expect(result.networkId, 10);
      expect(result.message, contains('سيتم مراجعة الطلب'));
    });
  });

  group('Register Network Form Validators Tests', () {
    test('Required validator catches empty or null values', () {
      final validator = FormValidators.required(fieldName: 'اسم الشبكة');
      expect(validator(null), 'اسم الشبكة مطلوب.');
      expect(validator(''), 'اسم الشبكة مطلوب.');
      expect(validator('شبكة الفهد'), isNull);
    });

    test('Name validator enforces word count between bounds', () {
      final validator = FormValidators.nameValidator(
        fieldName: 'اسم مسؤول الشبكة',
        minWordsCount: 2,
        maxWordsCount: 6,
      );

      expect(validator('علي'), 'الاسم يجب ان يكون مكون من 2 كلمة على الاقل');
      expect(validator('علي حسن صالح'), isNull);
      expect(validator('واحد اثنين ثلاثة اربعة خمسة ستة سبعة'),
          'الاسم يجب ان يكون مكون من 6 كلمة على الاكثر');
    });

    test('Phone validator verifies Yemeni mobile networks', () {
      final validator = FormValidators.phoneValidator(fieldName: 'رقم هاتف المسؤول');
      expect(validator('123456789'), 'رقم الجوال يجب ان يبدأ بـ 7');
      expect(validator('770000000'), isNull);
      expect(validator('730000000'), isNull);
      expect(validator('710000000'), isNull);
    });

    test('Email validator permits optional empty string or validates format', () {
      final optionalValidator = FormValidators.emailValidator(
        fieldName: 'بريد الشبكة',
        isRequired: false,
      );
      expect(optionalValidator(''), isNull);
      expect(optionalValidator(null), isNull);
      expect(optionalValidator('invalid-email'), isNotNull);
      expect(optionalValidator('admin@network.ye'), isNull);
    });
  });
}
