import 'package:netsales/core/enums/user_session_status.dart';
import 'package:netsales/features/user_sessions/data/models/user_session_model.dart';

abstract interface class UserSessionsRemoteDataSource {
  Future<List<UserSessionModel>> getSessions({
    UserSessionStatus? status,
    String? search,
  });

  Future<void> terminateSession(int sessionId);
}
