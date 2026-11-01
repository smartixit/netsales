import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/features/partners/domain/entities/network_pos_entity.dart';
import 'package:netsales/features/partners/domain/entities/pos_wallet_entity.dart';
import 'package:netsales/features/wallets/domain/entities/network_wallet_entity.dart';
import 'package:netsales/features/wallets/domain/entities/network_wallet_log_entity.dart';

/// ============================================================================
/// مستودع المحافظ والعمليات المالية الدوميني (WalletsRepository)
/// ============================================================================
/// يُعرّف العقود البرمجية لجلب بيانات محافظ مزودي الشبكات ونقاط البيع وسجلات حركاتها.
abstract class WalletsRepository {
  /// جلب محفظة مزود الشبكة عبر معرف الشبكة
  Future<ApiResponse<NetworkWalletEntity>> getNetworkWallet(int networkId);

  /// جلب سجل حركات دفتر أستاذ محفظة مزود الشبكة
  Future<ApiResponse<List<NetworkWalletLogEntity>>> getNetworkWalletLogs({
    required int walletId,
    int page = 1,
    int perPage = 20,
    String? logOperation,
    String? fromDate,
    String? toDate,
    String? search,
  });

  /// جلب محفظة نقطة البيع الثنائية المرتبطة بشبكة محددة
  Future<ApiResponse<PosWalletEntity>> getPosWallet({
    required int networkId,
    required int posId,
  });

  /// جلب سجل حركات دفتر أستاذ محفظة نقطة البيع مع شبكة محددة
  Future<ApiResponse<List<PosWalletLogEntity>>> getPosWalletLogs({
    required int walletId,
    int page = 1,
    int perPage = 20,
    String? logOperationType,
    String? fromDate,
    String? toDate,
    String? search,
  });

  /// جلب قائمة الشبكات المرتبطة بنقطة البيع (العلاقات الثنائية)
  Future<ApiResponse<List<NetworkPosEntity>>> getPosLinkedNetworks(int posId);
}

