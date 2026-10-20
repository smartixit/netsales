import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/models/user_session_model.dart';
import 'package:netsales/core/services/session_service.dart';
import 'package:netsales/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:netsales/features/auth/data/models/login_request_model.dart';
import 'package:netsales/features/auth/domain/entities/auth_result_entity.dart';
import 'package:netsales/features/auth/domain/repositories/auth_repository.dart';

/// تطبيق مستودع المصادقة وتنسيق البيانات بين مصدر البيانات وإدارة الجلسات
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remoteDataSource);

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<AuthResultEntity> login({
    required String phoneNumber,
    required String password,
    String? deviceUuid,
    String? deviceName,
    String? deviceType,
  }) async {
    final request = LoginRequestModel(
      userPhoneNumber: phoneNumber,
      userPassword: password,
      deviceUuid: deviceUuid,
      deviceName: deviceName,
      deviceType: deviceType,
    );

    final response = await _remoteDataSource.login(request);

    if (!response.success) {
      throw AppException(response.message);
    }

    final data = response.data;
    if (data == null) {
      throw AppException(
        response.message.isNotEmpty
            ? response.message
            : 'تعذر استلام بيانات المصادقة من الخادم',
      );
    }

    // إذا كانت المصادقة مباشرة وناجحة، نبدأ الجلسة فورياً في الذاكرة والتخزين الآمن
    if (!data.require2fa && data.sessionId != null && data.user != null) {
      await SessionService.to.startSession(
        user: data.user!,
        session: UserSessionModel(
          sessionId: data.sessionId!,
          userId: data.user!.userId,
        ),
        permissions: data.permissions,
      );
    }

    // LoginResponseModel يرث مباشرة من AuthResultEntity (LSP)
    return data;
  }
}
