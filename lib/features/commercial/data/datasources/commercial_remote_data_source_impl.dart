import 'package:netsales/core/constants/api_constants.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/core/services/api_service.dart';
import 'package:netsales/features/commercial/data/datasources/commercial_remote_data_source.dart';
import 'package:netsales/features/commercial/data/models/network_model.dart';
import 'package:netsales/features/commercial/data/models/network_pos_link_challenge_model.dart';
import 'package:netsales/features/commercial/data/models/network_pos_link_model.dart';
import 'package:netsales/features/commercial/data/models/network_pos_link_preview_model.dart';
import 'package:netsales/features/commercial/data/models/pos_model.dart';

/// تطبيق مصدر البيانات البعيد للعلاقات التجارية عبر [ApiService] المعتمد
class CommercialRemoteDataSourceImpl implements CommercialRemoteDataSource {
  const CommercialRemoteDataSourceImpl();

  @override
  Future<List<NetworkModel>> getMyNetworks() async {
    final response = await ApiService.instance.get<List<NetworkModel>>(
      ApiConstants.networks,
      fromJson: (data) {
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map(NetworkModel.fromJson)
              .toList(growable: false);
        }
        return const [];
      },
    );
    return response.data ?? const [];
  }

  @override
  Future<List<PosModel>> getMyPos() async {
    final response = await ApiService.instance.get<List<PosModel>>(
      ApiConstants.pos,
      fromJson: (data) {
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map(PosModel.fromJson)
              .toList(growable: false);
        }
        return const [];
      },
    );
    return response.data ?? const [];
  }

  @override
  Future<PaginatedList<NetworkPosLinkModel>> getNetworkPosList({
    required int networkId,
    bool? status,
    String? search,
    String? cursor,
    int? perPage,
  }) async {
    final queryParams = <String, dynamic>{
      if (status != null) 'status': status ? 1 : 0,
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
      'per_page': perPage ?? 15,
    };

    final response =
        await ApiService.instance.get<List<NetworkPosLinkModel>>(
      ApiConstants.networkPosList(networkId),
      queryParameters: queryParams,
      fromJson: (data) {
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map(NetworkPosLinkModel.fromJson)
              .toList(growable: false);
        }
        return const [];
      },
    );

    return PaginatedList<NetworkPosLinkModel>(
      items: response.data ?? const [],
      nextCursor: response.meta?['next_cursor'] as String?,
      prevCursor: response.meta?['prev_cursor'] as String?,
      perPage: response.meta?['per_page'] as int? ?? perPage ?? 15,
    );
  }

  @override
  Future<PaginatedList<NetworkPosLinkModel>> getPosNetworksList({
    required int posId,
    bool? status,
    String? search,
    String? cursor,
    int? perPage,
  }) async {
    final queryParams = <String, dynamic>{
      if (status != null) 'status': status ? 1 : 0,
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
      'per_page': perPage ?? 15,
    };

    final response =
        await ApiService.instance.get<List<NetworkPosLinkModel>>(
      ApiConstants.posNetworksList(posId),
      queryParameters: queryParams,
      fromJson: (data) {
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map(NetworkPosLinkModel.fromJson)
              .toList(growable: false);
        }
        return const [];
      },
    );

    return PaginatedList<NetworkPosLinkModel>(
      items: response.data ?? const [],
      nextCursor: response.meta?['next_cursor'] as String?,
      prevCursor: response.meta?['prev_cursor'] as String?,
      perPage: response.meta?['per_page'] as int? ?? perPage ?? 15,
    );
  }

  @override
  Future<NetworkPosLinkModel> createNetworkPosLink({
    required int networkId,
    required int posId,
  }) async {
    final response = await ApiService.instance.post<NetworkPosLinkModel>(
      ApiConstants.networkPos,
      data: {
        'network_id': networkId,
        'pos_id': posId,
      },
      fromJson: (data) =>
          NetworkPosLinkModel.fromJson(data as Map<String, dynamic>),
    );

    final result = response.data;
    if (result == null) {
      throw Exception('فشل إنشاء ارتباط نقطة البيع بالشبكة.');
    }
    return result;
  }

  @override
  Future<NetworkPosLinkModel> toggleNetworkPosLinkStatus(
      int networkPosId) async {
    final response = await ApiService.instance.patch<NetworkPosLinkModel>(
      ApiConstants.networkPosToggleStatus(networkPosId),
      fromJson: (data) =>
          NetworkPosLinkModel.fromJson(data as Map<String, dynamic>),
    );

    final result = response.data;
    if (result == null) {
      throw Exception('فشل تبديل حالة الارتباط التجاري.');
    }
    return result;
  }

  @override
  Future<void> deleteNetworkPosLink(int networkPosId) async {
    await ApiService.instance.delete<dynamic>(
      ApiConstants.networkPosItem(networkPosId),
    );
  }

  @override
  Future<NetworkPosLinkChallengeModel> createNetworkPosLinkChallenge({
    required int networkId,
    int? posId,
    String? posUuid,
    int durationMinutes = 15,
  }) async {
    final payload = <String, dynamic>{
      'network_id': networkId,
      'pos_id': ?posId,
      if (posUuid != null && posUuid.trim().isNotEmpty) 'pos_uuid': posUuid.trim(),
      'duration_minutes': durationMinutes,
    };

    final response =
        await ApiService.instance.post<NetworkPosLinkChallengeModel>(
      ApiConstants.networkPosChallenges,
      data: payload,
      fromJson: (data) =>
          NetworkPosLinkChallengeModel.fromJson(data as Map<String, dynamic>),
    );

    final result = response.data;
    if (result == null) {
      throw Exception('فشل توليد رمز دعوة الارتباط التجاري.');
    }
    return result;
  }

  @override
  Future<NetworkPosLinkPreviewModel> previewNetworkPosLinkChallenge({
    required String payload,
    int? posId,
    String? posUuid,
  }) async {
    final body = <String, dynamic>{
      'payload': payload,
      'pos_id': ?posId,
      if (posUuid != null && posUuid.trim().isNotEmpty) 'pos_uuid': posUuid.trim(),
    };

    final response =
        await ApiService.instance.post<NetworkPosLinkPreviewModel>(
      ApiConstants.networkPosChallengesPreview,
      data: body,
      fromJson: (data) => NetworkPosLinkPreviewModel.fromJson(
          data as Map<String, dynamic>),
    );

    final result = response.data;
    if (result == null) {
      throw Exception('فشل فحص بيانات دعوة الارتباط التجاري.');
    }
    return result;
  }

  @override
  Future<NetworkPosLinkModel> confirmNetworkPosLinkChallenge({
    required String challengeUuid,
    int? posId,
    String? posUuid,
  }) async {
    final body = <String, dynamic>{
      'challenge_uuid': challengeUuid,
      'pos_id': ?posId,
      if (posUuid != null && posUuid.trim().isNotEmpty) 'pos_uuid': posUuid.trim(),
    };

    final response = await ApiService.instance.post<NetworkPosLinkModel>(
      ApiConstants.networkPosChallengesConfirm,
      data: body,
      fromJson: (data) =>
          NetworkPosLinkModel.fromJson(data as Map<String, dynamic>),
    );

    final result = response.data;
    if (result == null) {
      throw Exception('فشل تأكيد الارتباط التجاري عبر الرمز المشفر.');
    }
    return result;
  }

  @override
  Future<void> revokeNetworkPosLinkChallenge(String challengeUuid) async {
    await ApiService.instance.delete<dynamic>(
      ApiConstants.networkPosChallengeRevoke(challengeUuid),
    );
  }

  @override
  Future<NetworkModel> getNetworkDetails(int networkId) async {
    final response = await ApiService.instance.get<NetworkModel>(
      ApiConstants.network(networkId),
      fromJson: (data) => NetworkModel.fromJson(data as Map<String, dynamic>),
    );

    final result = response.data;
    if (result == null) {
      throw Exception('لم يتم العثور على بيانات الشبكة المحددة.');
    }
    return result;
  }

  @override
  Future<PosModel> getPosDetails(int posId) async {
    final response = await ApiService.instance.get<PosModel>(
      ApiConstants.posItem(posId),
      fromJson: (data) => PosModel.fromJson(data as Map<String, dynamic>),
    );

    final result = response.data;
    if (result == null) {
      throw Exception('لم يتم العثور على بيانات نقطة البيع المحددة.');
    }
    return result;
  }
}
