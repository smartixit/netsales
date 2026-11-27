import 'package:netsales/features/user_sessions/domain/repositories/user_sessions_repository.dart';

class TerminateUserSessionUseCase {
  const TerminateUserSessionUseCase(this._repository);

  final UserSessionsRepository _repository;

  Future<void> call(int sessionId) => _repository.terminateSession(sessionId);
}
