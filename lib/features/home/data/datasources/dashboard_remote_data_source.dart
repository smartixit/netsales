import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/features/home/data/models/dashboard_overview_model.dart';

/// ============================================================================
/// عقد مصدر البيانات البعيد للوحة القيادة (DashboardRemoteDataSource Contract)
/// ============================================================================
abstract class DashboardRemoteDataSource {
  /// جلب بيانات لوحة القيادة التجميعية من الخادم
  Future<ApiResponse<DashboardOverviewModel>> getOverview({
    String period = 'today',
    int? networkId,
    int? posId,
    bool refresh = false,
  });
}
