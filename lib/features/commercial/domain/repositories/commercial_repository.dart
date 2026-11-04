import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_challenge_entity.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_preview_entity.dart';
import 'package:netsales/features/commercial/domain/entities/pos_entity.dart';

/// عقد مستودع الكيانات والروابط التجارية
abstract interface class CommercialRepository {
  /// جلب قائمة الشبكات التابعة للمستخدم الحالي
  Future<List<NetworkEntity>> getMyNetworks();

  /// جلب قائمة نقاط البيع التابعة للمستخدم الحالي
  Future<List<PosEntity>> getMyPos();

  /// جلب قائمة نقاط البيع المرتبطة بشبكة محددة
  Future<List<NetworkPosLinkEntity>> getNetworkPosList(
    int networkId, {
    Map<String, dynamic>? query,
  });

  /// جلب قائمة الشبكات المرتبطة بنقطة بيع محددة
  Future<List<NetworkPosLinkEntity>> getPosNetworksList(
    int posId, {
    Map<String, dynamic>? query,
  });

  /// ربط نقطة بيع بشبكة
  Future<NetworkPosLinkEntity> createNetworkPosLink({
    required int networkId,
    int? posId,
    String? posUuid,
    bool? status,
  });

  /// تبديل حالة الارتباط بين الشبكة ونقطة البيع
  Future<NetworkPosLinkEntity> toggleNetworkPosLinkStatus(int linkId);

  /// فك الارتباط بين الشبكة ونقطة البيع
  Future<void> deleteNetworkPosLink(int linkId);

  /// جلب تفاصيل شبكة محددة
  Future<NetworkEntity> getNetworkDetails(int networkId);

  /// جلب تفاصيل نقطة بيع محددة
  Future<PosEntity> getPosDetails(int posId);

  /// تحديث بيانات شبكة
  Future<NetworkEntity> updateNetworkDetails(
    int networkId,
    Map<String, dynamic> data,
  );

  /// تحديث بيانات نقطة بيع
  Future<PosEntity> updatePosDetails(int posId, Map<String, dynamic> data);

  /// إنشاء تحدي ربط مشفر عبر رمز QR
  Future<NetworkPosLinkChallengeEntity> createLinkChallenge({
    required int networkId,
    int? posId,
    String? posUuid,
    int? durationMinutes,
  });

  /// معاينة وفحص تحدي الربط المشفر من جانب نقطة البيع
  Future<NetworkPosLinkPreviewEntity> previewLinkChallenge({
    required String payload,
    int? posId,
    String? posUuid,
  });

  /// تأكيد واعتماد ربط نقطة البيع بالشبكة عبر التحدي
  Future<NetworkPosLinkEntity> confirmLinkChallenge({
    required String challengeUuid,
    int? posId,
    String? posUuid,
  });

  /// إلغاء وإبطال تحدي الربط
  Future<void> revokeLinkChallenge(String uuid);
}
