import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_challenge_entity.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_preview_entity.dart';
import 'package:netsales/features/commercial/domain/entities/pos_entity.dart';

/// العقد التجريدي لمستودع العلاقات التجارية ونقاط البيع والشبكات
abstract class CommercialRepository {
  /// جلب الشبكات المصرح للمستخدم بالوصول إليها
  Future<List<NetworkEntity>> getMyNetworks();

  /// جلب نقاط البيع المصرح للمستخدم بالوصول إليها
  Future<List<PosEntity>> getMyPos();

  /// جلب قائمة نقاط البيع المرتبطة بشبكة محددة مع الفلترة والترقيم بالمؤشر
  Future<PaginatedList<NetworkPosLinkEntity>> getNetworkPosList({
    required int networkId,
    bool? status,
    String? search,
    String? cursor,
    int? perPage,
  });

  /// جلب قائمة الشبكات المرتبطة بنقطة بيع محددة مع الفلترة والترقيم بالمؤشر
  Future<PaginatedList<NetworkPosLinkEntity>> getPosNetworksList({
    required int posId,
    bool? status,
    String? search,
    String? cursor,
    int? perPage,
  });

  /// ربط يدوي مباشر بين شبكة ونقطة بيع
  Future<NetworkPosLinkEntity> createNetworkPosLink({
    required int networkId,
    required int posId,
  });

  /// تبديل حالة نشاط الارتباط التجاري (تفعيل / تجميد)
  Future<NetworkPosLinkEntity> toggleNetworkPosLinkStatus(int networkPosId);

  /// فك الارتباط التجاري بين الشبكة ونقطة البيع
  Future<void> deleteNetworkPosLink(int networkPosId);

  /// توليد دعوة وتحدي ربط مشفر عبر رمز QR من جانب الشبكة
  Future<NetworkPosLinkChallengeEntity> createNetworkPosLinkChallenge({
    required int networkId,
    int? posId,
    String? posUuid,
    int durationMinutes = 15,
  });

  /// فحص ومعاينة دعوة الربط المشفرة من جانب نقطة البيع
  Future<NetworkPosLinkPreviewEntity> previewNetworkPosLinkChallenge({
    required String payload,
    int? posId,
    String? posUuid,
  });

  /// تأكيد اعتماد الربط التجاري من جانب نقطة البيع عبر التحدي المشفر
  Future<NetworkPosLinkEntity> confirmNetworkPosLinkChallenge({
    required String challengeUuid,
    int? posId,
    String? posUuid,
  });

  /// إلغاء دعوة الربط المشفرة
  Future<void> revokeNetworkPosLinkChallenge(String challengeUuid);

  /// جلب التفاصيل الكاملة لشبكة محددة
  Future<NetworkEntity> getNetworkDetails(int networkId);

  /// جلب التفاصيل الكاملة لنقطة بيع محددة
  Future<PosEntity> getPosDetails(int posId);
}
