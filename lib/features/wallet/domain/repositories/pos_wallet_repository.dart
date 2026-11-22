import 'package:netsales/core/enums/wallet_operation_type.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/wallet/domain/entities/pos_wallet_entity.dart';
import 'package:netsales/features/wallet/domain/entities/pos_wallet_log_entity.dart';

/// واجهة مستودع محافظ نقاط البيع ودفتر الأستاذ
abstract interface class PosWalletRepository {
  /// جلب بيانات محفظة نقطة البيع بواسطة معرف الشبكة ومعرف نقطة البيع
  Future<PosWalletEntity> getWalletByNetworkAndPos({
    required int networkId,
    required int posId,
  });

  /// جلب بيانات محفظة نقطة البيع بواسطة معرف المحفظة
  Future<PosWalletEntity> getWalletById(int walletId);

  /// جلب قيود دفتر أستاذ المحفظة مع الفلترة والترقيم بالمؤشر (Cursor Pagination)
  Future<PaginatedList<PosWalletLogEntity>> getWalletLogs({
    required int walletId,
    WalletOperationType? operationType,
    String? fromDate,
    String? toDate,
    String? search,
    String? cursor,
    int? perPage,
  });

  /// تحويل وتغذية رصيد من محفظة الشبكة إلى محفظة نقطة البيع
  Future<PosWalletEntity> transferFromNetwork({
    required int networkId,
    required int posId,
    required double amount,
    String? statement,
  });

  /// إيداع مالي مباشر في محفظة نقطة البيع (سند قبض نقدي)
  Future<PosWalletEntity> deposit({
    required int walletId,
    required double amount,
    required String statement,
    String? logDate,
  });

  /// سحب / خصم مالي مباشر من محفظة نقطة البيع
  Future<PosWalletEntity> withdraw({
    required int walletId,
    required double amount,
    required String statement,
    String? logDate,
  });

  /// تحديث السقف الائتماني لمحفظة نقطة البيع من قبل مزود الشبكة
  Future<PosWalletEntity> updateCreditLimit({
    required int walletId,
    required double? creditLimit,
  });
}
