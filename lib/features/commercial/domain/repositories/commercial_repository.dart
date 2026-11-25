import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/features/commercial/domain/entities/network_linkable_pos_entity.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_challenge_entity.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_challenge_status_entity.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_preview_entity.dart';
import 'package:netsales/features/commercial/domain/entities/pos_entity.dart';

/// العقد التجريدي لمستودع العلاقات التجارية ونقاط البيع والشبكات
abstract class CommercialRepository {
  /// استرجاع الشبكات المصرح للمستخدم بالوصول إليها
  Future<List<NetworkEntity>> getMyNetworks();

  /// استرجاع نقاط البيع المصرح للمستخدم بالوصول إليها
  Future<List<PosEntity>> getMyPos();

  /// دليل الشبكات المصرح بها مع البحث والتصفية والترقيم بالمؤشر.
  Future<PaginatedList<NetworkEntity>> getNetworksPage({
    String? search,
    String? status,
    String? cursor,
    int perPage = 15,
  });

  /// دليل نقاط البيع المصرح بها مع البحث والتصفية والترقيم بالمؤشر.
  Future<PaginatedList<PosEntity>> getPosPage({
    String? search,
    String? status,
    String? cursor,
    int perPage = 15,
  });

  /// استرجاع قائمة نقاط البيع المرتبطة بشبكة محددة مع الفلترة والترقيم بالمؤشر
  Future<PaginatedList<NetworkPosLinkEntity>> getNetworkPosList({
    required int networkId,
    bool? status,
    String? search,
    String? cursor,
    int? perPage,
  });

  /// استرجاع قائمة الشبكات المرتبطة بنقطة بيع محددة مع الفلترة والترقيم بالمؤشر
  Future<PaginatedList<NetworkPosLinkEntity>> getPosNetworksList({
    required int posId,
    bool? status,
    String? search,
    String? cursor,
    int? perPage,
  });

  /// ربط مباشر بين شبكة ونقطة بيع
  Future<NetworkPosLinkEntity> createNetworkPosLink({
    required int networkId,
    required int posId,
  });

  /// تبديل حالة نشاط الارتباط التجاري (تفعيل / تجميد)
  Future<NetworkPosLinkEntity> toggleNetworkPosLinkStatus(int networkPosId);

  /// فك الارتباط التجاري بين الشبكة ونقطة البيع
  Future<void> deleteNetworkPosLink(int networkPosId);

  /// التحقق من نقطة بيع محددة بواسطة المعرف التجاري قبل إصدار الدعوة.
  Future<NetworkLinkablePosEntity> resolveNetworkLinkablePos({
    required int networkId,
    required String posBusinessCode,
  });

  /// Search POS candidates eligible for a new invitation in one authorized Network.
  Future<PaginatedList<NetworkLinkablePosEntity>> searchNetworkLinkablePos({
    required int networkId,
    required String search,
    String? cursor,
    int perPage = 15,
  });

  /// إنشاء وتوليد دعوة وتحدي ربط مشفر عبر رمز QR
  Future<NetworkPosLinkChallengeEntity> createNetworkPosLinkChallenge({
    required int networkId,
    required String posUuid,
    int durationMinutes = 15,
  });

  /// فحص ومعاينة دعوة الربط المشفرة
  Future<NetworkPosLinkPreviewEntity> previewNetworkPosLinkChallenge({
    required String payload,
    required String posUuid,
  });

  /// تأكيد اعتماد الربط التجاري عبر التحدي المشفر
  Future<NetworkPosLinkEntity> confirmNetworkPosLinkChallenge({
    required String challengeUuid,
    required String posUuid,
  });

  /// استرجاع الحالة الآمنة الحالية لدعوة الربط.
  Future<NetworkPosLinkChallengeStatusEntity> getNetworkPosLinkChallengeStatus(
    String challengeUuid,
  );

  /// إلغاء وإبطال دعوة الربط المشفرة
  Future<void> revokeNetworkPosLinkChallenge(String challengeUuid);

  /// إنشاء شبكة للمستخدم المصادق عليه. لا يتضمن payload المالك أو الحالة.
  Future<NetworkEntity> createNetwork(Map<String, dynamic> payload);

  /// تحديث بيانات الشبكة فقط دون تغيير علاقاتها أو عضوياتها أو التزاماتها.
  Future<NetworkEntity> updateNetwork(int networkId, Map<String, dynamic> payload);

  /// إنشاء نقطة بيع للمستخدم المصادق عليه. لا يتضمن payload المالك أو الحالة.
  Future<PosEntity> createPos(Map<String, dynamic> payload);

  /// تحديث بيانات نقطة البيع فقط دون تغيير علاقاتها أو عضوياتها أو التزاماتها.
  Future<PosEntity> updatePos(int posId, Map<String, dynamic> payload);

  /// حذف مؤقت للشبكة دون المساس بسجلاتها المالية أو علاقاتها.
  Future<void> deleteNetwork(int networkId);

  /// حذف مؤقت لنقطة البيع دون المساس بسجلاتها المالية أو علاقاتها.
  Future<void> deletePos(int posId);

  /// استرجاع التفاصيل الكاملة لشبكة محددة
  Future<NetworkEntity> getNetworkDetails(int networkId);

  /// استرجاع التفاصيل الكاملة لنقطة بيع محددة
  Future<PosEntity> getPosDetails(int posId);
}
