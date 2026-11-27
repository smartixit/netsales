import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/enums/membership_status.dart';
import 'package:netsales/features/membership/data/models/workspace_member_model.dart';

void main() {
  group('WorkspaceMemberModel', () {
    test('maps the backend membership, user and role resource contracts', () {
      final model = WorkspaceMemberModel.fromJson({
        'id': 91,
        'network_id': 12,
        'user_id': 42,
        'role_id': 7,
        'status': 'ACTIVE',
        'status_label': 'نشط',
        'last_event_seq': 3,
        'is_owner': true,
        'created_at': '2026-11-27T10:00:00.000000Z',
        'updated_at': '2026-11-27T11:00:00.000000Z',
        'user': {
          'user_id': 42,
          'user_full_name': 'Test Member',
          'user_phone_number': '777123456',
          'user_email': 'member@example.test',
          'user_profile_logo': 'https://example.test/avatar.png',
        },
        'role': {
          'role_id': 7,
          'role_key': 'NETWORK_USER',
          'role_name': 'Network User',
          'role_desc': 'Operational network member',
          'scope': 'NETWORK',
        },
      });

      expect(model.id, 91);
      expect(model.tenantId, 12);
      expect(model.userId, 42);
      expect(model.fullName, 'Test Member');
      expect(model.phoneNumber, '777123456');
      expect(model.roleId, 7);
      expect(model.roleKey, 'NETWORK_USER');
      expect(model.role?.description, 'Operational network member');
      expect(model.role?.scope, 'NETWORK');
      expect(model.status, MembershipStatus.active);
      expect(model.statusRaw, 'ACTIVE');
      expect(model.lastEventSeq, 3);
      expect(model.isOwner, isTrue);
      expect(model.profileLogo, 'https://example.test/avatar.png');
      expect(model.statusLabel, 'نشط');
    });

    test('keeps unknown wire status explicit', () {
      expect(MembershipStatus.fromWire('UNRECOGNIZED'), MembershipStatus.unknown);
      expect(MembershipStatus.fromWire('SUSPENDED'), MembershipStatus.suspended);
      expect(MembershipStatus.fromWire('INVITED'), MembershipStatus.invited);
    });
  });
}
