import 'package:netsales/features/home/domain/entities/dashboard_overview_entity.dart';
import 'package:netsales/features/home/domain/repositories/dashboard_repository.dart';

/// ============================================================================
/// حالة استخدام جلب مؤشرات لوحة القيادة (GetDashboardOverviewUseCase)
/// ============================================================================
class GetDashboardOverviewUseCase {
  final DashboardRepository _repository;

  const GetDashboardOverviewUseCase(this._repository);

  Future<DashboardOverviewEntity> call({
    String period = 'today',
    int? networkId,
    int? posId,
    bool refresh = false,
  }) {
    return _repository.getOverview(
      period: period,
      networkId: networkId,
      posId: posId,
      refresh: refresh,
    );
  }
}
