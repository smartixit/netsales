import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/enums/membership_status.dart';
import 'package:netsales/features/membership/data/models/membership_model.dart';

void main() {
  group('MembershipModel', () {
    test('maps nested user, role, status and authoritative owner flag', () {
      final model = MembershipModel.fromJson({
        'user_id': 42,
        'role_id': 7,
        'status': 'ACTIVE',
        'is_owner': true,
        'user': {
          'user_id': 42,
          'user_full_name': 'Test Member',
          'user_phone_number': '777123456',
          'user_profile_logo_url': 'https://example.test/avatar.png',
        },
        'role': {
          'role_id': 7,
          'role_key': 'NETWORK_USER',
          'role_name': 'Network User',
        },
      });

      expect(model.userId, 42);
      expect(model.fullName, 'Test Member');
      expect(model.phoneNumber, '777123456');
      expect(model.roleId, 7);
      expect(model.roleKey, 'NETWORK_USER');
      expect(model.status, 'ACTIVE');
      expect(model.isOwner, isTrue);
      expect(model.profileLogo, 'https://example.test/avatar.png');
    });

    test('keeps unknown wire status explicit', () {
      expect(MembershipStatus.fromWire('UNRECOGNIZED'), MembershipStatus.unknown);
      expect(MembershipStatus.fromWire('SUSPENDED'), MembershipStatus.suspended);
      expect(MembershipStatus.fromWire('INVITED'), MembershipStatus.invited);
    });
  });
}
