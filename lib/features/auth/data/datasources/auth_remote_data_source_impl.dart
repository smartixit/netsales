import 'package:netsales/core/constants/api_constants.dart';
import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/core/services/api_service.dart';
import 'package:netsales/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:netsales/features/auth/data/models/login_request_model.dart';
import 'package:netsales/features/auth/data/models/login_response_model.dart';
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
}
