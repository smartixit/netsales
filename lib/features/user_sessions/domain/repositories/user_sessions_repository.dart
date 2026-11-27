import 'package:netsales/core/enums/user_session_status.dart';
import 'package:netsales/features/user_sessions/domain/entities/user_session_entity.dart';

/// عقد المستودع لوحدة جلسات تسجيل الدخول.
abstract interface class UserSessionsRepository {
  Future<List<UserSessionEntity>> getSessions({
    UserSessionStatus? status,
    String? search,
  });

  Future<void> terminateSession(int sessionId);
}
