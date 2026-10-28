import 'package:netsales/features/more/domain/repositories/more_repository.dart';

/// ============================================================================
/// حالة استخدام إنهاء جلسة محددة عن بُعد (TerminateSessionUseCase)
/// ============================================================================
class TerminateSessionUseCase {
  final MoreRepository _repository;

  const TerminateSessionUseCase(this._repository);

  Future<bool> call(int sessionId) => _repository.terminateSession(sessionId);
}
