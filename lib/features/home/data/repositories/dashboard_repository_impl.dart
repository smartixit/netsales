import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/features/home/data/datasources/dashboard_remote_data_source.dart';
import 'package:netsales/features/home/domain/entities/dashboard_overview_entity.dart';
import 'package:netsales/features/home/domain/repositories/dashboard_repository.dart';

/// ============================================================================
/// تطبيق مستودع لوحة القيادة الموحدة (DashboardRepositoryImpl)
/// ============================================================================
/// يطبق عقد الدومين، يستدعي مصدر البيانات البعيد، ويعيد الكيانات مباشرة.
class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource _remoteDataSource;

  const DashboardRepositoryImpl(this._remoteDataSource);

  @override
  Future<DashboardOverviewEntity> getOverview({
    String period = 'today',
    int? networkId,
    int? posId,
    bool refresh = false,
  }) async {
    final response = await _remoteDataSource.getOverview(
      period: period,
      networkId: networkId,
      posId: posId,
      refresh: refresh,
    );

    if (response.data != null) {
      return response.data!;
    }

    throw AppException(
      response.message.isNotEmpty
          ? response.message
          : 'تعذر جلب بيانات لوحة القيادة',
    );
  }
}

