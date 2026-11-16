import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/features/commercial/domain/entities/pos_entity.dart';
import 'package:netsales/features/workspace/presentation/mappers/workspace_network_picker_mapper.dart';
import 'package:netsales/features/workspace/presentation/mappers/workspace_pos_picker_mapper.dart';

void main() {
  group('WorkspaceNetworkPickerMapper', () {
    test('maps network details into a display-only model', () {
      const network = NetworkEntity(
        networkId: 12,
        ownerId: 3,
        networkName: 'شبكة صنعاء',
        networkPhoneNumber: '777000001',
        networkProfileLogoUrl: 'https://example.test/network.png',
        governorateName: 'صنعاء',
        directorateName: 'التحرير',
        status: 'ACTIVE',
      );

      final result = WorkspaceNetworkPickerMapper.map([network]);

      expect(result, hasLength(1));
      expect(result.single.id, 12);
      expect(result.single.name, 'شبكة صنعاء');
      expect(result.single.logoUrl, 'https://example.test/network.png');
      expect(result.single.initials, isNotEmpty);
      expect(result.single.subtitle, 'صنعاء • التحرير');
      expect(result.single.isActive, isTrue);
    });

    test('uses phone fallback when location is unavailable', () {
      const network = NetworkEntity(
        networkId: 13,
        ownerId: 3,
        networkName: 'شبكة جديدة',
        networkPhoneNumber: '777000002',
      );

      final result = WorkspaceNetworkPickerMapper.map([network]);

      expect(result.single.subtitle, '777000002');
      expect(result.single.isActive, isFalse);
    });
  });

  group('WorkspacePosPickerMapper', () {
    test('maps POS details into a display-only model', () {
      const pos = PosEntity(
        posId: 22,
        ownerId: 4,
        posUuid: 'POS-022',
        posName: 'متجر صنعاء',
        posPhoneNumber: '711000001',
        posProfileLogoUrl: 'https://example.test/pos.png',
        governorateName: 'صنعاء',
        directorateName: 'حدة',
        status: 'ACTIVE',
      );

      final result = WorkspacePosPickerMapper.map([pos]);

      expect(result, hasLength(1));
      expect(result.single.id, 22);
      expect(result.single.name, 'متجر صنعاء');
      expect(result.single.logoUrl, 'https://example.test/pos.png');
      expect(result.single.subtitle, 'صنعاء • حدة');
      expect(result.single.isActive, isTrue);
    });

    test('uses phone fallback when location is unavailable', () {
      const pos = PosEntity(
        posId: 23,
        ownerId: 4,
        posUuid: 'POS-023',
        posName: 'متجر جديد',
        posPhoneNumber: '711000002',
      );

      final result = WorkspacePosPickerMapper.map([pos]);

      expect(result.single.subtitle, '711000002');
      expect(result.single.isActive, isFalse);
    });
  });
}
