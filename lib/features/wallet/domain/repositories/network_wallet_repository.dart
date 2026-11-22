import 'package:netsales/core/enums/wallet_operation_type.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/wallet/domain/entities/network_wallet_entity.dart';
import 'package:netsales/features/wallet/domain/entities/network_wallet_log_entity.dart';

/// واجهة مستودع محفظة مزود الشبكة ودفتر الأستاذ (Network Wallet Repository)
abstract interface class NetworkWalletRepository {
  /// جلب بيانات محفظة الشبكة بواسطة معرف الشبكة
  Future<NetworkWalletEntity> getWalletByNetworkId(int networkId);

  /// جلب بيانات محفظة الشبكة بواسطة معرف المحفظة
  Future<NetworkWalletEntity> getWalletById(int walletId);

  /// جلب قيود دفتر أستاذ محفظة الشبكة مع الفلترة والترقيم بالمؤشر (Cursor)
  Future<PaginatedList<NetworkWalletLogEntity>> getWalletLogs({
    required int walletId,
    WalletOperationType? operationType,
    String? fromDate,
    String? toDate,
    String? search,
    String? cursor,
    int? perPage,
  });
}
