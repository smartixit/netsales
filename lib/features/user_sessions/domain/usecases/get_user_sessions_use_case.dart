import 'package:netsales/core/enums/user_session_status.dart';
import 'package:netsales/features/user_sessions/domain/entities/user_session_entity.dart';
import 'package:netsales/features/user_sessions/domain/repositories/user_sessions_repository.dart';

class GetUserSessionsUseCase {
  const GetUserSessionsUseCase(this._repository);

  final UserSessionsRepository _repository;

  Future<List<UserSessionEntity>> call({
    UserSessionStatus? status,
    String? search,
  }) => _repository.getSessions(status: status, search: search);
}
