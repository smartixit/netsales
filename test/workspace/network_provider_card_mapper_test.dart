import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/features/workspace/presentation/mappers/network_provider_card_mapper.dart';

void main() {
  group('NetworkProviderCardMapper', () {
    test('maps network identity, location, owner and active selection', () {
      const network = NetworkEntity(
        networkId: 7,
        ownerId: 2,
        networkName: 'شبكة صنعاء',
        networkPhoneNumber: '777000000',
        networkUuid: 'NET-007',
        governorateName: 'صنعاء',
        directorateName: 'التحرير',
        ownerName: 'المزود',
        status: 'active',
      );

      final result = NetworkProviderCardMapper.map(
        networks: const [network],
        selectedNetworkId: 7,
        overview: null,
      );

      expect(result, hasLength(1));
      expect(result.single.networkId, 7);
      expect(result.single.networkName, 'شبكة صنعاء');
      expect(result.single.subtitle, 'صنعاء • التحرير');
      expect(result.single.networkCode, 'NET-007');
      expect(result.single.ownerDisplay, 'المزود');
      expect(result.single.isActive, isTrue);
      expect(result.single.isSelected, isTrue);
      expect(result.single.cardIndex, 0);
    });

    test('uses safe display fallbacks when optional network fields are absent', () {
      const network = NetworkEntity(
        networkId: 8,
        ownerId: 2,
        networkName: 'شبكة جديدة',
        networkPhoneNumber: '777000001',
      );

      final result = NetworkProviderCardMapper.map(
        networks: const [network],
        selectedNetworkId: null,
        overview: null,
      );

      expect(result.single.subtitle, 'شبكة مصرحة ومعتمدة');
      expect(result.single.networkCode, isEmpty);
      expect(result.single.ownerDisplay, 'المزود المعتمد');
      expect(result.single.isSelected, isFalse);
      expect(result.single.cardIndex, 0);
    });
  });
}
