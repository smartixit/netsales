import 'package:netsales/features/more/domain/entities/more_overview_entity.dart';
import 'package:netsales/features/more/domain/repositories/more_repository.dart';

/// ============================================================================
/// حالة استخدام جلب ملخص شاشة المزيد (GetMoreOverviewUseCase)
/// ============================================================================
class GetMoreOverviewUseCase {
  final MoreRepository _repository;

  const GetMoreOverviewUseCase(this._repository);

  Future<MoreOverviewEntity> call() {
    return _repository.getMoreOverview();
  }
}
