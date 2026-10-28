import 'package:netsales/features/more/domain/entities/user_session_entity.dart';
import 'package:netsales/features/more/domain/repositories/more_repository.dart';

/// ============================================================================
/// حالة استخدام جلب الجلسات المصرح بها (GetUserSessionsUseCase)
/// ============================================================================
class GetUserSessionsUseCase {
  final MoreRepository _repository;

  const GetUserSessionsUseCase(this._repository);

  Future<List<UserSessionEntity>> call(int userId) =>
      _repository.getUserSessions(userId);
}
