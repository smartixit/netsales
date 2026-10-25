import 'package:netsales/core/services/session_service.dart';
import 'package:netsales/features/more/data/datasources/more_remote_data_source.dart';
import 'package:netsales/features/more/domain/entities/more_overview_entity.dart';
import 'package:netsales/features/more/domain/entities/more_subscription_entity.dart';
import 'package:netsales/features/more/domain/entities/more_wallet_entity.dart';
import 'package:netsales/features/more/domain/repositories/more_repository.dart';

/// ============================================================================
/// تطبيق مستودع قطاع المزيد والمركز المالي (MoreRepositoryImpl)
/// ============================================================================
class MoreRepositoryImpl implements MoreRepository {
  final MoreRemoteDataSource _remoteDataSource;

  const MoreRepositoryImpl(this._remoteDataSource);

  @override
  Future<MoreOverviewEntity> getMoreOverview() async {
    try {
      final response = await _remoteDataSource.getMoreOverview();
      if (response.success && response.data != null) {
        return response.data!;
      }
    } catch (_) {
      // إخفاق صامت والرجوع للقيم الافتراضية لمنع تجميد الشاشة
    }
    return const MoreOverviewEntity();
  }

  @override
  Future<MoreWalletEntity?> getWalletSummary() async {
    try {
      final response = await _remoteDataSource.getWalletSummary();
      if (response.success) {
        return response.data;
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<MoreSubscriptionEntity?> getActiveSubscription() async {
    try {
      final response = await _remoteDataSource.getActiveSubscription();
      if (response.success) {
        return response.data;
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<bool> logout() async {
    try {
      await _remoteDataSource.logout();
    } catch (_) {
      // نتجاهل أخطاء الشبكة أثناء تسجيل الخروج لضمان تنظيف الجلسة محلياً دائماً
    }
    await SessionService.instance.terminateSession();
    return true;
  }
}
