import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/commercial/data/datasources/commercial_remote_data_source.dart';
import 'package:netsales/features/commercial/data/models/network_model.dart';
import 'package:netsales/features/commercial/data/models/network_pos_link_model.dart';
import 'package:netsales/features/commercial/data/models/pos_model.dart';
import 'package:netsales/features/commercial/data/repositories/commercial_repository_impl.dart';

class _MockCommercialRemoteDataSource implements CommercialRemoteDataSource {
  final Map<String?, PaginatedList<NetworkPosLinkModel>> pages = {};
  final List<String?> requestedCursors = [];

  @override
  Future<List<NetworkModel>> getMyNetworks() async {
    return const [
      NetworkModel(
        networkId: 1,
        ownerId: 1,
        networkName: 'شبكة 1',
        networkPhoneNumber: '770000001',
      ),
    ];
  }

  @override
  Future<List<PosModel>> getMyPos() async {
    return const [
      PosModel(
        posId: 10,
        ownerId: 2,
        posUuid: 'POS-UUID-10',
        posName: 'نقطة 10',
        posPhoneNumber: '771000010',
      ),
    ];
  }

  @override
  Future<PaginatedList<NetworkPosLinkModel>> getNetworkPosList({
    required int networkId,
    bool? status,
    String? search,
    String? cursor,
    int? perPage,
  }) async {
    requestedCursors.add(cursor);
    return pages[cursor] ?? const PaginatedList(items: []);
  }

  @override
  Future<PaginatedList<NetworkPosLinkModel>> getPosNetworksList({
    required int posId,
    bool? status,
    String? search,
    String? cursor,
    int? perPage,
  }) async {
    requestedCursors.add(cursor);
    return pages[cursor] ?? const PaginatedList(items: []);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

NetworkPosLinkModel _link(int id, int netId, int posId) => NetworkPosLinkModel(
      networkPosId: id,
      networkId: netId,
      posId: posId,
      status: true,
    );

void main() {
  group('CommercialRepositoryImpl Pagination Tests', () {
    late _MockCommercialRemoteDataSource remote;
    late CommercialRepositoryImpl repository;

    setUp(() {
      remote = _MockCommercialRemoteDataSource();
      repository = CommercialRepositoryImpl(remote);
    });

    test('getNetworkPosList passes cursor to remote data source and returns page', () async {
      remote.pages[null] = PaginatedList(
        items: [_link(1, 10, 20)],
        nextCursor: 'cursor_page_2',
      );
      remote.pages['cursor_page_2'] = PaginatedList(
        items: [_link(2, 10, 21)],
        nextCursor: null,
      );

      final firstPage = await repository.getNetworkPosList(networkId: 10);
      expect(firstPage.items.length, equals(1));
      expect(firstPage.nextCursor, equals('cursor_page_2'));
      expect(firstPage.hasMore, isTrue);

      final secondPage = await repository.getNetworkPosList(
        networkId: 10,
        cursor: firstPage.nextCursor,
      );
      expect(secondPage.items.length, equals(1));
      expect(secondPage.nextCursor, isNull);
      expect(secondPage.hasMore, isFalse);

      expect(remote.requestedCursors, equals([null, 'cursor_page_2']));
    });

    test('getPosNetworksList forwards cursor and pagination parameters correctly', () async {
      remote.pages[null] = PaginatedList(
        items: [_link(1, 10, 30), _link(2, 11, 30)],
        nextCursor: 'next_pos_cursor',
      );

      final result = await repository.getPosNetworksList(
        posId: 30,
        status: true,
        search: 'Al-Amal',
        perPage: 20,
      );

      expect(result.items.length, equals(2));
      expect(result.nextCursor, equals('next_pos_cursor'));
      expect(remote.requestedCursors, equals([null]));
    });
  });
}
