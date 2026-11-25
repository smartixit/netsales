import 'package:netsales/core/constants/api_constants.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/core/services/api_service.dart';
import 'package:netsales/features/commercial/data/datasources/commercial_remote_data_source.dart';
import 'package:netsales/features/commercial/data/models/network_linkable_pos_model.dart';
import 'package:netsales/features/commercial/data/models/network_model.dart';
import 'package:netsales/features/commercial/data/models/network_pos_link_challenge_model.dart';
import 'package:netsales/features/commercial/data/models/network_pos_link_challenge_status_model.dart';
import 'package:netsales/features/commercial/data/models/network_pos_link_model.dart';
import 'package:netsales/features/commercial/data/models/network_pos_link_preview_model.dart';
import 'package:netsales/features/commercial/data/models/pos_model.dart';

/// تطبيق مصدر البيانات البعيد للعلاقات التجارية عبر [ApiService]
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
  Future<PaginatedList<NetworkModel>> getNetworksPage({
    String? search,
    String? status,
    String? cursor,
    int perPage = 15,
  }) async {
    final response = await ApiService.instance.getList<NetworkModel>(
      ApiConstants.networks,
      fromJson: (data) => NetworkModel.fromJson(data as Map<String, dynamic>),
      queryParameters: {
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (status != null && status.isNotEmpty) 'status': status,
      },
      cursor: cursor,
      perPage: perPage,
    );
    return PaginatedList<NetworkModel>(
      items: response.data ?? const [],
      nextCursor: response.nextCursor,
      prevCursor: response.prevCursor,
      perPage: perPage,
    );
  }

  @override
  Future<PaginatedList<PosModel>> getPosPage({
    String? search,
    String? status,
    String? cursor,
    int perPage = 15,
  }) async {
    final response = await ApiService.instance.getList<PosModel>(
      ApiConstants.pos,
      fromJson: (data) => PosModel.fromJson(data as Map<String, dynamic>),
      queryParameters: {
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (status != null && status.isNotEmpty) 'status': status,
      },
      cursor: cursor,
      perPage: perPage,
    );
    return PaginatedList<PosModel>(
      items: response.data ?? const [],
      nextCursor: response.nextCursor,
      prevCursor: response.prevCursor,
      perPage: perPage,
    );
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

    final response = await ApiService.instance.get<List<NetworkPosLinkModel>>(
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
      nextCursor: response.nextCursor,
      prevCursor: response.prevCursor,
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

    final response = await ApiService.instance.get<List<NetworkPosLinkModel>>(
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
      nextCursor: response.nextCursor,
      prevCursor: response.prevCursor,
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
      data: {'network_id': networkId, 'pos_id': posId},
      fromJson: (data) =>
          NetworkPosLinkModel.fromJson(data as Map<String, dynamic>),
    );

    final result = response.data;
    if (result == null) {
      throw AppException('فشل إنشاء ارتباط نقطة البيع بالشبكة.');
    }
    return result;
  }

  @override
  Future<NetworkPosLinkModel> toggleNetworkPosLinkStatus(
    int networkPosId,
  ) async {
    final response = await ApiService.instance.post<NetworkPosLinkModel>(
      ApiConstants.networkPosToggleStatus(networkPosId),
      fromJson: (data) =>
          NetworkPosLinkModel.fromJson(data as Map<String, dynamic>),
    );

    final result = response.data;
    if (result == null) {
      throw AppException('فشل تبديل حالة الارتباط التجاري.');
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
  Future<PaginatedList<NetworkLinkablePosModel>> searchNetworkLinkablePos({
    required int networkId,
    required String search,
    String? cursor,
    int perPage = 15,
  }) async {
    final response = await ApiService.instance.get<List<NetworkLinkablePosModel>>(
      ApiConstants.networkPosChallengesLinkableTargets,
      queryParameters: {
        'network_id': networkId,
        'search': search.trim(),
        'per_page': perPage,
        if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
      },
      fromJson: (data) {
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map(NetworkLinkablePosModel.fromJson)
              .toList(growable: false);
        }
        return const [];
      },
    );

    return PaginatedList<NetworkLinkablePosModel>(
      items: response.data ?? const [],
      nextCursor: response.nextCursor,
      prevCursor: response.prevCursor,
      perPage: perPage,
    );
  }

  @override
  Future<NetworkLinkablePosModel> resolveNetworkLinkablePos({
    required int networkId,
    required String posBusinessCode,
  }) async {
    final response = await ApiService.instance.post<NetworkLinkablePosModel>(
      ApiConstants.networkPosChallengesResolveTarget,
      data: {
        'network_id': networkId,
        'pos_uuid': posBusinessCode.trim().toUpperCase(),
      },
      fromJson: (data) => NetworkLinkablePosModel.fromJson(data as Map<String, dynamic>),
    );

    final result = response.data;
    if (result == null ||
        result.posId <= 0 ||
        result.posUuid.trim().isEmpty ||
        result.posName.trim().isEmpty) {
      throw AppException('تعذر التحقق من نقطة البيع المستهدفة.');
    }
    return result;
  }

  @override
  Future<NetworkPosLinkChallengeModel> createNetworkPosLinkChallenge({
    required int networkId,
    required String posUuid,
    int durationMinutes = 15,
  }) async {
    final payload = <String, dynamic>{
      'network_id': networkId,
      'pos_uuid': posUuid.trim(),
      'duration_minutes': durationMinutes,
    };

    final response = await ApiService.instance
        .post<NetworkPosLinkChallengeModel>(
          ApiConstants.networkPosChallenges,
          data: payload,
          fromJson: (data) => NetworkPosLinkChallengeModel.fromJson(
            data as Map<String, dynamic>,
          ),
        );

    final result = response.data;
    if (result == null) {
      throw AppException('فشل توليد رمز دعوة الارتباط التجاري.');
    }
    return result;
  }

  @override
  Future<NetworkPosLinkPreviewModel> previewNetworkPosLinkChallenge({
    required String payload,
    required String posUuid,
  }) async {
    final body = <String, dynamic>{
      'payload': payload,
      'pos_uuid': posUuid.trim(),
    };

    final response = await ApiService.instance.post<NetworkPosLinkPreviewModel>(
      ApiConstants.networkPosChallengesPreview,
      data: body,
      fromJson: (data) =>
          NetworkPosLinkPreviewModel.fromJson(data as Map<String, dynamic>),
    );

    final result = response.data;
    if (result == null) {
      throw AppException('فشل فحص بيانات دعوة الارتباط التجاري.');
    }
    return result;
  }

  @override
  Future<NetworkPosLinkModel> confirmNetworkPosLinkChallenge({
    required String challengeUuid,
    required String posUuid,
  }) async {
    final body = <String, dynamic>{
      'challenge_uuid': challengeUuid,
      'pos_uuid': posUuid.trim(),
    };

    final response = await ApiService.instance.post<NetworkPosLinkModel>(
      ApiConstants.networkPosChallengesConfirm,
      data: body,
      fromJson: (data) =>
          NetworkPosLinkModel.fromJson(data as Map<String, dynamic>),
    );

    final result = response.data;
    if (result == null) {
      throw AppException('فشل تأكيد الارتباط التجاري عبر الرمز المشفر.');
    }
    return result;
  }

  @override
  Future<NetworkPosLinkChallengeStatusModel>
  getNetworkPosLinkChallengeStatus(String challengeUuid) async {
    final response =
        await ApiService.instance.get<NetworkPosLinkChallengeStatusModel>(
      ApiConstants.networkPosChallengeStatus(challengeUuid),
      fromJson: (data) => NetworkPosLinkChallengeStatusModel.fromJson(
        data as Map<String, dynamic>,
      ),
    );

    final result = response.data;
    if (result == null) {
      throw AppException('تعذر استرجاع حالة دعوة الربط.');
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
  Future<NetworkModel> createNetwork(Map<String, dynamic> payload) async {
    final fields = Map<String, dynamic>.from(payload);
    final logoPath = fields.remove('_network_logo_path') as String?;
    final response = logoPath != null
        ? await ApiService.instance.uploadFile<NetworkModel>(
            ApiConstants.networks,
            filePath: logoPath,
            fileField: 'network_logo',
            extraFields: fields,
            fromJson: (data) => NetworkModel.fromJson(data as Map<String, dynamic>),
          )
        : await ApiService.instance.post<NetworkModel>(
            ApiConstants.networks,
            data: fields,
            fromJson: (data) => NetworkModel.fromJson(data as Map<String, dynamic>),
          );
    final result = response.data;
    if (result == null) {
      throw AppException('فشل إنشاء الشبكة.');
    }
    return result;
  }

  @override
  Future<NetworkModel> updateNetwork(
    int networkId,
    Map<String, dynamic> payload,
  ) async {
    final fields = Map<String, dynamic>.from(payload);
    final logoPath = fields.remove('_network_logo_path') as String?;
    final response = logoPath != null
        ? await ApiService.instance.uploadFile<NetworkModel>(
            ApiConstants.network(networkId),
            filePath: logoPath,
            fileField: 'network_logo',
            extraFields: {...fields, '_method': 'PUT'},
            fromJson: (data) => NetworkModel.fromJson(data as Map<String, dynamic>),
          )
        : await ApiService.instance.put<NetworkModel>(
            ApiConstants.network(networkId),
            data: fields,
            fromJson: (data) => NetworkModel.fromJson(data as Map<String, dynamic>),
          );
    final result = response.data;
    if (result == null) {
      throw AppException('فشل تحديث بيانات الشبكة.');
    }
    return result;
  }

  @override
  Future<PosModel> createPos(Map<String, dynamic> payload) async {
    final fields = Map<String, dynamic>.from(payload);
    final logoPath = fields.remove('_pos_logo_path') as String?;
    final response = logoPath != null
        ? await ApiService.instance.uploadFile<PosModel>(
            ApiConstants.pos,
            filePath: logoPath,
            fileField: 'pos_profile_logo',
            extraFields: fields,
            fromJson: (data) => PosModel.fromJson(data as Map<String, dynamic>),
          )
        : await ApiService.instance.post<PosModel>(
            ApiConstants.pos,
            data: fields,
            fromJson: (data) => PosModel.fromJson(data as Map<String, dynamic>),
          );
    final result = response.data;
    if (result == null) {
      throw AppException('فشل إنشاء نقطة البيع.');
    }
    return result;
  }

  @override
  Future<PosModel> updatePos(
    int posId,
    Map<String, dynamic> payload,
  ) async {
    final fields = Map<String, dynamic>.from(payload);
    final logoPath = fields.remove('_pos_logo_path') as String?;
    final response = logoPath != null
        ? await ApiService.instance.uploadFile<PosModel>(
            ApiConstants.posItem(posId),
            filePath: logoPath,
            fileField: 'pos_profile_logo',
            extraFields: {...fields, '_method': 'PUT'},
            fromJson: (data) => PosModel.fromJson(data as Map<String, dynamic>),
          )
        : await ApiService.instance.put<PosModel>(
            ApiConstants.posItem(posId),
            data: fields,
            fromJson: (data) => PosModel.fromJson(data as Map<String, dynamic>),
          );
    final result = response.data;
    if (result == null) {
      throw AppException('فشل تحديث بيانات نقطة البيع.');
    }
    return result;
  }

  @override
  Future<void> deleteNetwork(int networkId) async {
    final response = await ApiService.instance.delete<void>(
      ApiConstants.network(networkId),
    );
    if (!response.success) {
      throw AppException(response.message.isNotEmpty ? response.message : 'تعذر حذف الشبكة.');
    }
  }

  @override
  Future<void> deletePos(int posId) async {
    final response = await ApiService.instance.delete<void>(
      ApiConstants.posItem(posId),
    );
    if (!response.success) {
      throw AppException(response.message.isNotEmpty ? response.message : 'تعذر حذف نقطة البيع.');
    }
  }

  @override
  Future<NetworkModel> getNetworkDetails(int networkId) async {
    final response = await ApiService.instance.get<NetworkModel>(
      ApiConstants.network(networkId),
      fromJson: (data) => NetworkModel.fromJson(data as Map<String, dynamic>),
    );

    final result = response.data;
    if (result == null) {
      throw AppException('لم يتم العثور على بيانات الشبكة المحددة.');
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
      throw AppException('لم يتم العثور على بيانات نقطة البيع المحددة.');
    }
    return result;
  }
}
