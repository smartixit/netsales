import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/features/partners/data/models/network_model.dart';
import 'package:netsales/features/partners/data/models/network_pos_model.dart';
import 'package:netsales/features/partners/data/models/pos_model.dart';
import 'package:netsales/features/partners/data/models/pos_wallet_model.dart';

/// ============================================================================
/// عقد مصدر البيانات البعيد للشركاء والتوزيع (PartnersRemoteDataSource)
/// ============================================================================
/// يحدد عقود استدعاءات الـ API المتعلقة بالشبكات، نقاط البيع، وعقود الربط.
abstract class PartnersRemoteDataSource {
  /// استرجاع قائمة مزودي الشبكات مع الفلاتر والصفحات
  Future<ApiResponse<List<NetworkModel>>> getNetworks({
    int page = 1,
    int perPage = 20,
    String? search,
    String? status,
    int? governorateId,
    int? directorateId,
  });

  /// استرجاع قائمة نقاط البيع والوكلاء مع الفلاتر والصفحات
  Future<ApiResponse<List<PosModel>>> getPosList({
    int page = 1,
    int perPage = 20,
    String? search,
    String? status,
    int? governorateId,
    int? directorateId,
  });

  /// استرجاع قائمة عقود الربط بين الشبكات ونقاط البيع
  Future<ApiResponse<List<NetworkPosModel>>> getNetworkPosList({
    int page = 1,
    int perPage = 20,
    int? networkId,
    int? posId,
    bool? status,
    String? search,
  });

  /// تبديل حالة عقد الارتباط بين نشط ومعطل
  Future<ApiResponse<NetworkPosModel>> toggleNetworkPosStatus(int networkPosId);

  /// اعتماد طلب تسجيل شبكة وتفعيل حسابها
  Future<ApiResponse<NetworkModel>> approveNetwork(int networkId);

  /// رفض طلب تسجيل شبكة مع توثيق السبب
  Future<ApiResponse<void>> rejectNetwork(int networkId, String reason);

  /// اعتماد طلب تسجيل نقطة بيع وتفعيل حسابها
  Future<ApiResponse<PosModel>> approvePos(int posId);

  /// رفض طلب تسجيل نقطة بيع مع توثيق السبب
  Future<ApiResponse<void>> rejectPos(int posId, String reason);

  /// استرجاع بيانات المحفظة الثنائية لنقطة البيع مع شبكة محددة
  Future<ApiResponse<PosWalletModel>> getPosWallet({
    required int networkId,
    required int posId,
  });

  /// تحويل وشحن رصيد من محفظة الشبكة إلى محفظة نقطة البيع
  Future<ApiResponse<dynamic>> transferNetworkToPos({
    required int networkId,
    required int posId,
    required double amount,
    String? statement,
  });

  /// استرجاع أو توريد رصيد من محفظة نقطة البيع إلى محفظة الشبكة
  Future<ApiResponse<dynamic>> transferPosToNetwork({
    required int networkId,
    required int posId,
    required double amount,
    String? statement,
  });

  /// استرجاع سجل دفتر الأستاذ لحركات محفظة نقطة البيع
  Future<ApiResponse<List<PosWalletLogModel>>> getPosWalletLogs({
    required int walletId,
    int page = 1,
    int perPage = 20,
  });
}

