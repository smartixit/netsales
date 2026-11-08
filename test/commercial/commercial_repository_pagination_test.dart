import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/features/commercial/data/datasources/commercial_remote_data_source.dart';
import 'package:netsales/features/commercial/data/models/network_model.dart';
import 'package:netsales/features/commercial/data/models/network_pos_link_challenge_model.dart';
import 'package:netsales/features/commercial/data/models/network_pos_link_model.dart';
import 'package:netsales/features/commercial/data/models/network_pos_link_preview_model.dart';
import 'package:netsales/features/commercial/data/models/pos_model.dart';
import 'package:netsales/features/commercial/data/repositories/commercial_repository_impl.dart';

class _PagedCommercialRemoteDataSource implements CommercialRemoteDataSource {
  final Map<String?, ApiResponse<List<NetworkModel>>> networkPages = {};
  final Map<String?, ApiResponse<List<PosModel>>> posPages = {};
  final List<Map<String, dynamic>> networkQueries = [];
  final List<Map<String, dynamic>> posQueries = [];

  @override
  Future<ApiResponse<List<NetworkModel>>> getMyNetworks({
    Map<String, dynamic>? query,
  }) async {
    final normalizedQuery = Map<String, dynamic>.of(query ?? const {});
    networkQueries.add(normalizedQuery);
    final cursor = normalizedQuery['cursor']?.toString();
    return networkPages[cursor] ??
        ApiResponse<List<NetworkModel>>(
          success: false,
          message: 'Missing network test page for cursor: $cursor',
        );
  }

  @override
  Future<ApiResponse<List<PosModel>>> getMyPos({
    Map<String, dynamic>? query,
  }) async {
    final normalizedQuery = Map<String, dynamic>.of(query ?? const {});
    posQueries.add(normalizedQuery);
    final cursor = normalizedQuery['cursor']?.toString();
    return posPages[cursor] ??
        ApiResponse<List<PosModel>>(
          success: false,
          message: 'Missing POS test page for cursor: $cursor',
        );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

NetworkModel _network(int id) => NetworkModel(
  networkId: id,
  ownerId: 1,
  networkName: 'Network $id',
  networkPhoneNumber: '777000$id',
);

PosModel _pos(int id) => PosModel(
  posId: id,
  ownerId: 1,
  posUuid: 'pos-$id',
  posName: 'POS $id',
  posPhoneNumber: '777100$id',
);

void main() {
  group('Commercial repository cursor pagination', () {
    test('loads every authorized network page and removes duplicate IDs', () async {
      final remote = _PagedCommercialRemoteDataSource()
        ..networkPages[null] = ApiResponse<List<NetworkModel>>(
          success: true,
          message: 'first page',
          data: [_network(1), _network(2)],
          nextCursor: 'network-page-2',
        )
        ..networkPages['network-page-2'] = ApiResponse<List<NetworkModel>>(
          success: true,
          message: 'last page',
          data: [_network(2), _network(3)],
        );

      final result = await CommercialRepositoryImpl(remote).getMyNetworks();

      expect(result.map((item) => item.networkId), [1, 2, 3]);
      expect(remote.networkQueries, [
        {'per_page': 100},
        {'per_page': 100, 'cursor': 'network-page-2'},
      ]);
    });

    test('loads every authorized POS page and removes duplicate IDs', () async {
      final remote = _PagedCommercialRemoteDataSource()
        ..posPages[null] = ApiResponse<List<PosModel>>(
          success: true,
          message: 'first page',
          data: [_pos(10), _pos(20)],
          nextCursor: 'pos-page-2',
        )
        ..posPages['pos-page-2'] = ApiResponse<List<PosModel>>(
          success: true,
          message: 'last page',
          data: [_pos(20), _pos(30)],
        );

      final result = await CommercialRepositoryImpl(remote).getMyPos();

      expect(result.map((item) => item.posId), [10, 20, 30]);
      expect(remote.posQueries, [
        {'per_page': 100},
        {'per_page': 100, 'cursor': 'pos-page-2'},
      ]);
    });

    test('does not return partial network options when a later page fails', () async {
      final remote = _PagedCommercialRemoteDataSource()
        ..networkPages[null] = ApiResponse<List<NetworkModel>>(
          success: true,
          message: 'first page',
          data: [_network(1)],
          nextCursor: 'network-page-2',
        )
        ..networkPages['network-page-2'] = ApiResponse<List<NetworkModel>>(
          success: false,
          message: 'second page failed',
        );

      await expectLater(
        CommercialRepositoryImpl(remote).getMyNetworks(),
        throwsA(isA<AppException>()),
      );
    });

    test('stops with an explicit error when the server repeats a cursor', () async {
      final remote = _PagedCommercialRemoteDataSource()
        ..networkPages[null] = ApiResponse<List<NetworkModel>>(
          success: true,
          message: 'first page',
          data: [_network(1)],
          nextCursor: 'same-cursor',
        )
        ..networkPages['same-cursor'] = ApiResponse<List<NetworkModel>>(
          success: true,
          message: 'repeated cursor',
          data: [_network(2)],
          nextCursor: 'same-cursor',
        );

      await expectLater(
        CommercialRepositoryImpl(remote).getMyNetworks(),
        throwsA(isA<AppException>()),
      );
    });
  });
}
