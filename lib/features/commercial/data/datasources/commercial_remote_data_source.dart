import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/features/commercial/data/models/network_model.dart';
import 'package:netsales/features/commercial/data/models/network_pos_link_challenge_model.dart';
import 'package:netsales/features/commercial/data/models/network_pos_link_model.dart';
import 'package:netsales/features/commercial/data/models/network_pos_link_preview_model.dart';
import 'package:netsales/features/commercial/data/models/pos_model.dart';

/// عقد مصدر البيانات البعيد للكيانات والروابط التجارية
abstract interface class CommercialRemoteDataSource {
  /// جلب قائمة الشبكات التابعة للمستخدم الحالي
  Future<ApiResponse<List<NetworkModel>>> getMyNetworks({
    Map<String, dynamic>? query,
  });

  /// جلب قائمة نقاط البيع التابعة للمستخدم الحالي
  Future<ApiResponse<List<PosModel>>> getMyPos({
    Map<String, dynamic>? query,
  });

  /// جلب قائمة نقاط البيع المرتبطة بشبكة
  Future<ApiResponse<List<NetworkPosLinkModel>>> getNetworkPosList(
    int networkId, {
    Map<String, dynamic>? query,
  });

  /// جلب قائمة الشبكات المرتبطة بنقطة بيع
  Future<ApiResponse<List<NetworkPosLinkModel>>> getPosNetworksList(
    int posId, {
    Map<String, dynamic>? query,
  });

  /// ربط نقطة بيع بشبكة
  Future<ApiResponse<NetworkPosLinkModel>> createNetworkPosLink({
    required int networkId,
    int? posId,
    String? posUuid,
    bool? status,
  });

  /// تبديل حالة الارتباط
  Future<ApiResponse<NetworkPosLinkModel>> toggleNetworkPosLinkStatus(
    int linkId,
  );

  /// فك الارتباط
  Future<ApiResponse<void>> deleteNetworkPosLink(int linkId);

  /// جلب تفاصيل شبكة
  Future<ApiResponse<NetworkModel>> getNetworkDetails(int networkId);

  /// جلب تفاصيل نقطة بيع
  Future<ApiResponse<PosModel>> getPosDetails(int posId);

  /// تحديث بيانات شبكة
  Future<ApiResponse<NetworkModel>> updateNetworkDetails(
    int networkId,
    Map<String, dynamic> data,
  );

  /// تحديث بيانات نقطة بيع
  Future<ApiResponse<PosModel>> updatePosDetails(
    int posId,
    Map<String, dynamic> data,
  );

  /// إنشاء تحدي ربط مشفر عبر رمز QR
  Future<ApiResponse<NetworkPosLinkChallengeModel>> createLinkChallenge({
    required int networkId,
    int? posId,
    String? posUuid,
    int? durationMinutes,
  });

  /// معاينة وفحص تحدي ربط مشفر من جانب نقطة البيع
  Future<ApiResponse<NetworkPosLinkPreviewModel>> previewLinkChallenge({
    required String payload,
    int? posId,
    String? posUuid,
  });

  /// تأكيد واعتماد ربط نقطة البيع بالشبكة عبر التحدي
  Future<ApiResponse<NetworkPosLinkModel>> confirmLinkChallenge({
    required String challengeUuid,
    int? posId,
    String? posUuid,
  });

  /// إلغاء وإبطال تحدي الربط
  Future<ApiResponse<void>> revokeLinkChallenge(String uuid);
}
