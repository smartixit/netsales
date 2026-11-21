import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
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
  Future<PosEntity> resolveNetworkLinkablePos({
    required int networkId,
    required String posBusinessCode,
  });

  /// إنشاء وتوليد دعوة وتحدي ربط مشفر عبر رمز QR
  Future<NetworkPosLinkChallengeEntity> createNetworkPosLinkChallenge({
    required int networkId,
    int? posId,
    String? posUuid,
    int durationMinutes = 15,
  });

  /// فحص ومعاينة دعوة الربط المشفرة
  Future<NetworkPosLinkPreviewEntity> previewNetworkPosLinkChallenge({
    required String payload,
    int? posId,
    String? posUuid,
  });

  /// تأكيد اعتماد الربط التجاري عبر التحدي المشفر
  Future<NetworkPosLinkEntity> confirmNetworkPosLinkChallenge({
    required String challengeUuid,
    int? posId,
    String? posUuid,
  });

  /// استرجاع الحالة الآمنة الحالية لدعوة الربط.
  Future<NetworkPosLinkChallengeStatusEntity> getNetworkPosLinkChallengeStatus(
    String challengeUuid,
  );

  /// إلغاء وإبطال دعوة الربط المشفرة
  Future<void> revokeNetworkPosLinkChallenge(String challengeUuid);

  /// استرجاع التفاصيل الكاملة لشبكة محددة
  Future<NetworkEntity> getNetworkDetails(int networkId);

  /// استرجاع التفاصيل الكاملة لنقطة بيع محددة
  Future<PosEntity> getPosDetails(int posId);
}
