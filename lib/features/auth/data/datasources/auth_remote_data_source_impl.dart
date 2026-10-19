import 'package:netsales/core/constants/api_constants.dart';
import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/core/services/api_service.dart';
import 'package:netsales/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:netsales/features/auth/data/models/login_request_model.dart';
import 'package:netsales/features/auth/data/models/login_response_model.dart';

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
}
