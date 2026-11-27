import 'package:netsales/core/constants/api_constants.dart';
import 'package:netsales/core/enums/user_session_status.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/services/api_service.dart';
import 'package:netsales/features/user_sessions/data/datasources/user_sessions_remote_data_source.dart';
import 'package:netsales/features/user_sessions/data/models/user_session_model.dart';

class UserSessionsRemoteDataSourceImpl implements UserSessionsRemoteDataSource {
  const UserSessionsRemoteDataSourceImpl();

  @override
  Future<List<UserSessionModel>> getSessions({
    UserSessionStatus? status,
    String? search,
  }) async {
    final query = <String, dynamic>{
      if (status != null && status.isKnown) 'status': status.wireValue,
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
    };

    final response = await ApiService.instance.get<List<UserSessionModel>>(
      ApiConstants.authSessions,
      queryParameters: query.isEmpty ? null : query,
      fromJson: (json) {
        if (json is! List) return <UserSessionModel>[];
        return json
            .whereType<Map<String, dynamic>>()
            .map((e) => UserSessionModel.fromJson(Map<String, dynamic>.from(e)))
            .toList(growable: false);
      },
    );

    if (!response.success) {
      throw AppException(
        response.message.isNotEmpty
            ? response.message
            : 'تعذر جلب قائمة الجلسات.',
      );
    }

    return response.data ?? const <UserSessionModel>[];
  }

  @override
  Future<void> terminateSession(int sessionId) async {
    final response = await ApiService.instance.delete<void>(
      ApiConstants.terminateAuthSession(sessionId),
    );

    if (!response.success) {
      throw AppException(
        response.message.isNotEmpty ? response.message : 'تعذر إنهاء الجلسة.',
      );
    }
  }
}
