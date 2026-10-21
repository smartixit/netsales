import 'package:netsales/core/constants/api_constants.dart';
import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/core/services/api_service.dart';
import 'package:netsales/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:netsales/features/auth/data/models/directorate_model.dart';
import 'package:netsales/features/auth/data/models/governorate_model.dart';
import 'package:netsales/features/auth/data/models/login_request_model.dart';
import 'package:netsales/features/auth/data/models/login_response_model.dart';
import 'package:netsales/features/auth/data/models/register_network_request_model.dart';
import 'package:netsales/features/auth/data/models/register_network_response_model.dart';
import 'package:netsales/features/auth/data/models/register_pos_request_model.dart';
import 'package:netsales/features/auth/data/models/register_pos_response_model.dart';
import 'package:netsales/features/auth/data/models/reset_password_request_model.dart';
import 'package:netsales/features/auth/data/models/verify_two_factor_request_model.dart';

/// تطبيق مصدر البيانات البعيد للمصادقة عبر ApiService
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl();

  @override
  Future<ApiResponse<LoginResponseModel>> login(LoginRequestModel request) {
    return ApiService.instance.post<LoginResponseModel>(
      ApiConstants.login,
      data: request.toJson(),
      fromJson: LoginResponseModel.fromJson,
    );
  }

  @override
  Future<ApiResponse<void>> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) {
    return ApiService.instance.post<void>(
      ApiConstants.updatePassword,
      data: {
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': confirmPassword,
      },
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> getProfile() {
    return ApiService.instance.get<Map<String, dynamic>>(
      ApiConstants.me,
      fromJson: (json) =>
          json is Map ? Map<String, dynamic>.from(json) : <String, dynamic>{},
    );
  }

  @override
  Future<ApiResponse<void>> requestPasswordReset(String phoneNumber) {
    return ApiService.instance.post<void>(
      ApiConstants.passwordRequestReset,
      data: {
        'user_phone_number': phoneNumber,
      },
    );
  }

  @override
  Future<ApiResponse<void>> verifyResetOtp({
    required String phoneNumber,
    required String otp,
  }) {
    return ApiService.instance.post<void>(
      ApiConstants.passwordVerifyOtp,
      data: {
        'user_phone_number': phoneNumber,
        'otp': otp,
      },
    );
  }

  @override
  Future<ApiResponse<void>> resetPassword(ResetPasswordRequestModel request) {
    return ApiService.instance.post<void>(
      ApiConstants.passwordReset,
      data: request.toJson(),
    );
  }

  @override
  Future<ApiResponse<LoginResponseModel>> verifyTwoFactor(
    VerifyTwoFactorRequestModel request,
  ) {
    return ApiService.instance.post<LoginResponseModel>(
      ApiConstants.verify2fa,
      data: request.toJson(),
      fromJson: LoginResponseModel.fromJson,
    );
  }

  @override
  Future<ApiResponse<void>> resendOtp({
    required String phoneNumber,
    required String otpType,
    required String deviceUuid,
  }) {
    return ApiService.instance.post<void>(
      ApiConstants.otpResend,
      data: {
        'user_phone_number': phoneNumber,
        'otp_type': otpType,
        'device_uuid': deviceUuid,
      },
    );
  }

  @override
  Future<ApiResponse<List<GovernorateModel>>> getGovernorates() {
    return ApiService.instance.getList<GovernorateModel>(
      ApiConstants.governorates,
      queryParameters: {'all': true},
      fromJson: (json) => GovernorateModel.fromJson(
        Map<String, dynamic>.from(json as Map),
      ),
    );
  }

  @override
  Future<ApiResponse<List<DirectorateModel>>> getDirectorates(int governorateId) {
    return ApiService.instance.getList<DirectorateModel>(
      ApiConstants.directoratesByGovernorate(governorateId),
      fromJson: (json) => DirectorateModel.fromJson(
        Map<String, dynamic>.from(json as Map),
      ),
    );
  }

  @override
  Future<ApiResponse<RegisterNetworkResponseModel>> registerNetwork(
    RegisterNetworkRequestModel request,
  ) async {
    final dynamic requestData = request.hasFiles
        ? await request.toFormData()
        : request.toJson();

    return ApiService.instance.post<RegisterNetworkResponseModel>(
      ApiConstants.registerNetwork,
      data: requestData,
      fromJson: (json) => RegisterNetworkResponseModel.fromJson(
        Map<String, dynamic>.from(json as Map),
      ),
    );
  }

  @override
  Future<ApiResponse<RegisterPosResponseModel>> registerPos(
    RegisterPosRequestModel request,
  ) async {
    final dynamic requestData = request.hasFiles
        ? await request.toFormData()
        : request.toJson();

    return ApiService.instance.post<RegisterPosResponseModel>(
      ApiConstants.registerPos,
      data: requestData,
      fromJson: (json) => RegisterPosResponseModel.fromJson(
        Map<String, dynamic>.from(json as Map),
      ),
    );
  }
}
