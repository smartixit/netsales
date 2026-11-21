import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/workspace/presentation/mappers/pos_linked_network_option_mapper.dart';

void main() {
  group('PosLinkedNetworkOptionMapper', () {
    test('preserves distinct relationship IDs for the same network', () {
      const links = [
        NetworkPosLinkEntity(
          networkPosId: 101,
          networkId: 7,
          posId: 22,
          status: true,
        ),
        NetworkPosLinkEntity(
          networkPosId: 102,
          networkId: 7,
          posId: 22,
          status: true,
        ),
      ];

      final result = PosLinkedNetworkOptionMapper.map(
        links: links,
        selectedNetworkPosId: 102,
      );

      expect(result, hasLength(2));
      expect(result.map((item) => item.networkPosId), [101, 102]);
      expect(result.where((item) => item.isSelected).single.networkPosId, 102);
    });

    test('excludes inactive relationships', () {
      const links = [
        NetworkPosLinkEntity(
          networkPosId: 101,
          networkId: 7,
          posId: 22,
          status: true,
        ),
        NetworkPosLinkEntity(
          networkPosId: 102,
          networkId: 8,
          posId: 22,
          status: false,
        ),
      ];

      final result = PosLinkedNetworkOptionMapper.map(
        links: links,
        selectedNetworkPosId: null,
      );

      expect(result, hasLength(1));
      expect(result.single.networkPosId, 101);
      expect(result.single.isSelected, isFalse);
    });
  });
}
