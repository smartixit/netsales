import 'package:netsales/features/partners/domain/entities/network_entity.dart';
import 'package:netsales/features/partners/domain/entities/network_pos_entity.dart';
import 'package:netsales/features/partners/domain/entities/pos_entity.dart';
import 'package:netsales/features/partners/domain/entities/pos_wallet_entity.dart';

/// ============================================================================
/// عقد مستودع الشركاء ونقاط التوزيع الدوميني المجرد (PartnersRepository)
/// ============================================================================
/// العقد الحصري المجرد لطبقة الدومين، ولا يعتمد على أي تفاصيل تقنية تخص HTTP أو التخزين.
abstract class PartnersRepository {
  /// جلب قائمة مزودي الشبكات مع الفلاتر والبحث
  Future<List<NetworkEntity>> getNetworks({
    int page = 1,
    int perPage = 20,
    String? search,
    String? status,
    int? governorateId,
    int? directorateId,
  });

  /// جلب قائمة نقاط البيع والوكلاء مع الفلاتر والبحث
  Future<List<PosEntity>> getPosList({
    int page = 1,
    int perPage = 20,
    String? search,
    String? status,
    int? governorateId,
    int? directorateId,
  });

  /// جلب قائمة عقود ربط الشبكات بنقاط البيع
  Future<List<NetworkPosEntity>> getNetworkPosList({
    int page = 1,
    int perPage = 20,
    int? networkId,
    int? posId,
    bool? status,
    String? search,
  });

  /// إنشاء وتوثيق عقد ارتباط وتوزيع جديد بين شبكة ونقطة بيع
  Future<NetworkPosEntity?> createNetworkPos({
    required int networkId,
    required String posUuid,
    bool status = true,
  });

  /// تبديل حالة عقد الربط بين نشط ومعطل
  Future<bool> toggleNetworkPosStatus(int networkPosId);

  /// اعتماد طلب تسجيل شبكة جديدة
  Future<bool> approveNetwork(int networkId);

  /// رفض طلب تسجيل شبكة جديدة مع ذكر السبب
  Future<bool> rejectNetwork(int networkId, String reason);

  /// اعتماد طلب تسجيل نقطة بيع جديدة
  Future<bool> approvePos(int posId);

  /// رفض طلب تسجيل نقطة بيع جديدة مع ذكر السبب
  Future<bool> rejectPos(int posId, String reason);

  /// جلب بيانات المحفظة الثنائية المشتركة لنقطة البيع مع شبكة معينة
  Future<PosWalletEntity?> getPosWallet({
    required int networkId,
    required int posId,
  });

  /// تحويل وشحن رصيد من محفظة الشبكة إلى محفظة نقطة البيع
  Future<bool> transferNetworkToPos({
    required int networkId,
    required int posId,
    required double amount,
    String? statement,
  });

  /// استرجاع أو توريد رصيد من محفظة نقطة البيع إلى محفظة الشبكة
  Future<bool> transferPosToNetwork({
    required int networkId,
    required int posId,
    required double amount,
    String? statement,
  });

  /// جلب سجل دفتر الأستاذ لحركات محفظة نقطة البيع المشتركة
  Future<List<PosWalletLogEntity>> getPosWalletLogs({
    required int networkId,
    required int posId,
    int page = 1,
    int perPage = 20,
  });
}

