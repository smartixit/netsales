import 'package:netsales/core/enums/user_session_status.dart';
import 'package:netsales/features/user_sessions/data/datasources/user_sessions_remote_data_source.dart';
import 'package:netsales/features/user_sessions/domain/entities/user_session_entity.dart';
import 'package:netsales/features/user_sessions/domain/repositories/user_sessions_repository.dart';

class UserSessionsRepositoryImpl implements UserSessionsRepository {
  const UserSessionsRepositoryImpl(this._remoteDataSource);

  final UserSessionsRemoteDataSource _remoteDataSource;

  @override
  Future<List<UserSessionEntity>> getSessions({
    UserSessionStatus? status,
    String? search,
  }) => _remoteDataSource.getSessions(status: status, search: search);

  @override
  Future<void> terminateSession(int sessionId) =>
      _remoteDataSource.terminateSession(sessionId);
}
