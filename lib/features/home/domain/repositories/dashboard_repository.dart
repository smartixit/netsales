import 'package:netsales/features/home/domain/entities/dashboard_overview_entity.dart';

/// ============================================================================
/// عقد مستودع لوحة القيادة الموحدة (DashboardRepository Contract)
/// ============================================================================
/// يحدد عقود العمليات دون الارتباط بأي مصدر بيانات ملموس.
abstract class DashboardRepository {
  /// جلب النظرة الشاملة للوحة القيادة
  Future<DashboardOverviewEntity> getOverview({
    String period = 'today',
    int? networkId,
    int? posId,
    bool refresh = false,
  });
}
