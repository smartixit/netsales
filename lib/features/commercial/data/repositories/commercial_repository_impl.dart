import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/commercial/data/datasources/commercial_remote_data_source.dart';
import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_challenge_entity.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_preview_entity.dart';
import 'package:netsales/features/commercial/domain/entities/pos_entity.dart';
import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';

/// تطبيق مستودع الكيانات والروابط التجارية
class CommercialRepositoryImpl implements CommercialRepository {
  const CommercialRepositoryImpl(this._remoteDataSource);

  final CommercialRemoteDataSource _remoteDataSource;

  @override
  Future<List<NetworkEntity>> getMyNetworks() async {
    const pageSize = 100;
    final networks = <NetworkEntity>[];
    final seenNetworkIds = <int>{};
    final seenCursors = <String>{};
    String? cursor;

    while (true) {
      final query = <String, dynamic>{
        'per_page': pageSize,
        if (cursor != null) 'cursor': cursor,
      };
      final response = await _remoteDataSource.getMyNetworks(query: query);

      if (!response.success || response.data == null) {
        throw AppException(
          response.message.isNotEmpty
              ? response.message
              : 'تعذر تحميل قائمة الشبكات المصرح بها.',
        );
      }

      for (final network in response.data!) {
        if (network.networkId > 0 && seenNetworkIds.add(network.networkId)) {
          networks.add(network);
        }
      }

      final nextCursor = response.nextCursor?.trim();
      if (nextCursor == null || nextCursor.isEmpty) {
        return networks;
      }
      if (!seenCursors.add(nextCursor)) {
        throw AppException(
          'توقف تحميل الشبكات بسبب تكرار مؤشر الصفحة من الخادم.',
        );
      }
      cursor = nextCursor;
    }
  }

  @override
  Future<List<PosEntity>> getMyPos() async {
    const pageSize = 100;
    final positions = <PosEntity>[];
    final seenPosIds = <int>{};
    final seenCursors = <String>{};
    String? cursor;

    while (true) {
      final query = <String, dynamic>{
        'per_page': pageSize,
        if (cursor != null) 'cursor': cursor,
      };
      final response = await _remoteDataSource.getMyPos(query: query);

      if (!response.success || response.data == null) {
        throw AppException(
          response.message.isNotEmpty
              ? response.message
              : 'تعذر تحميل قائمة نقاط البيع المصرح بها.',
        );
      }

      for (final pos in response.data!) {
        if (pos.posId > 0 && seenPosIds.add(pos.posId)) {
          positions.add(pos);
        }
      }

      final nextCursor = response.nextCursor?.trim();
      if (nextCursor == null || nextCursor.isEmpty) {
        return positions;
      }
      if (!seenCursors.add(nextCursor)) {
        throw AppException(
          'توقف تحميل نقاط البيع بسبب تكرار مؤشر الصفحة من الخادم.',
        );
      }
      cursor = nextCursor;
    }
  }

  @override
  Future<PaginatedList<NetworkPosLinkEntity>> getNetworkPosList(
    int networkId, {
    String? cursor,
    String? search,
    bool? status,
    int? perPage,
    Map<String, dynamic>? query,
  }) async {
    final mergedQuery = <String, dynamic>{
      'cursor': ?cursor,
      if (search != null && search.isNotEmpty) 'search': search,
      if (status != null) 'status': status ? '1' : '0',
      'per_page': ?perPage,
      ...?query,
    };

    final response = await _remoteDataSource.getNetworkPosList(
      networkId,
      query: mergedQuery.isEmpty ? null : mergedQuery,
    );

    if (response.success && response.data != null) {
      return PaginatedList<NetworkPosLinkEntity>(
        items: response.data!,
        nextCursor: response.nextCursor,
        prevCursor: response.prevCursor,
      );
    }

    throw AppException(response.message);
  }

  @override
  Future<PaginatedList<NetworkPosLinkEntity>> getPosNetworksList(
    int posId, {
    String? cursor,
    String? search,
    bool? status,
    int? perPage,
    Map<String, dynamic>? query,
  }) async {
    final mergedQuery = <String, dynamic>{
      'cursor': ?cursor,
      if (search != null && search.isNotEmpty) 'search': search,
      if (status != null) 'status': status ? '1' : '0',
      'per_page': ?perPage,
      ...?query,
    };

    final response = await _remoteDataSource.getPosNetworksList(
      posId,
      query: mergedQuery.isEmpty ? null : mergedQuery,
    );

    if (response.success && response.data != null) {
      return PaginatedList<NetworkPosLinkEntity>(
        items: response.data!,
        nextCursor: response.nextCursor,
        prevCursor: response.prevCursor,
      );
    }

    throw AppException(response.message);
  }

  @override
  Future<NetworkPosLinkEntity> createNetworkPosLink({
    required int networkId,
    int? posId,
    String? posUuid,
    bool? status,
  }) async {
    final response = await _remoteDataSource.createNetworkPosLink(
      networkId: networkId,
      posId: posId,
      posUuid: posUuid,
      status: status,
    );

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw AppException(response.message);
  }

  @override
  Future<NetworkPosLinkEntity> toggleNetworkPosLinkStatus(int linkId) async {
    final response = await _remoteDataSource.toggleNetworkPosLinkStatus(linkId);

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw AppException(response.message);
  }

  @override
  Future<void> deleteNetworkPosLink(int linkId) async {
    final response = await _remoteDataSource.deleteNetworkPosLink(linkId);

    if (!response.success) {
      throw AppException(response.message);
    }
  }

  @override
  Future<NetworkEntity> getNetworkDetails(int networkId) async {
    final response = await _remoteDataSource.getNetworkDetails(networkId);

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw AppException(response.message);
  }

  @override
  Future<PosEntity> getPosDetails(int posId) async {
    final response = await _remoteDataSource.getPosDetails(posId);

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw AppException(response.message);
  }

  @override
  Future<NetworkEntity> updateNetworkDetails(
    int networkId,
    Map<String, dynamic> data,
  ) async {
    final response = await _remoteDataSource.updateNetworkDetails(
      networkId,
      data,
    );

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw AppException(response.message);
  }

  @override
  Future<PosEntity> updatePosDetails(
    int posId,
    Map<String, dynamic> data,
  ) async {
    final response = await _remoteDataSource.updatePosDetails(posId, data);

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw AppException(response.message);
  }

  @override
  Future<NetworkPosLinkChallengeEntity> createLinkChallenge({
    required int networkId,
    int? posId,
    String? posUuid,
    int? durationMinutes,
  }) async {
    final response = await _remoteDataSource.createLinkChallenge(
      networkId: networkId,
      posId: posId,
      posUuid: posUuid,
      durationMinutes: durationMinutes,
    );

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw AppException(response.message);
  }

  @override
  Future<NetworkPosLinkPreviewEntity> previewLinkChallenge({
    required String payload,
    int? posId,
    String? posUuid,
  }) async {
    final response = await _remoteDataSource.previewLinkChallenge(
      payload: payload,
      posId: posId,
      posUuid: posUuid,
    );

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw AppException(response.message);
  }

  @override
  Future<NetworkPosLinkEntity> confirmLinkChallenge({
    required String challengeUuid,
    int? posId,
    String? posUuid,
  }) async {
    final response = await _remoteDataSource.confirmLinkChallenge(
      challengeUuid: challengeUuid,
      posId: posId,
      posUuid: posUuid,
    );

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw AppException(response.message);
  }

  @override
  Future<void> revokeLinkChallenge(String uuid) async {
    final response = await _remoteDataSource.revokeLinkChallenge(uuid);

    if (response.success) {
      return;
    }

    throw AppException(response.message);
  }
}
