import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/core/models/user_model.dart';
import 'package:netsales/core/services/workspace_service.dart';

void main() {
  group('WorkspaceService scoped role resolution', () {
    test('resolves a network-only account without users.role_id', () {
      final user = UserModel.fromJson({
        'user_id': 10,
        'user_full_name': 'Network Owner',
        'user_phone_number': '700000010',
        'workspace_roles': [
          {
            'scope': 'NETWORK',
            'tenant_id': 17,
            'role_key': 'NETWORK_OWNER',
            'role_name': 'مالك الشبكة',
          },
        ],
      });

      expect(user.role, isNull);
      expect(user.isNetworkOwner, isTrue);
      expect(
        WorkspaceService.instance.resolveWorkspaceForUser(
          user,
          preferredWorkspace: 'network',
        ),
        AppWorkspace.network,
      );
    });

    test('honors the saved workspace when the account has both scopes', () {
      final user = UserModel.fromJson({
        'user_id': 11,
        'user_full_name': 'Multi Scope User',
        'user_phone_number': '700000011',
        'workspace_roles': [
          {
            'scope': 'NETWORK',
            'tenant_id': 17,
            'role_key': 'NETWORK_USER',
            'role_name': 'مستخدم شبكة',
          },
          {
            'scope': 'POS',
            'tenant_id': 21,
            'role_key': 'POS_USER',
            'role_name': 'مستخدم نقطة بيع',
          },
        ],
      });

      expect(
        WorkspaceService.instance.resolveWorkspaceForUser(
          user,
          preferredWorkspace: 'network',
        ),
        AppWorkspace.network,
      );
      expect(
        WorkspaceService.instance.resolveWorkspaceForUser(
          user,
          preferredWorkspace: 'pos',
        ),
        AppWorkspace.pos,
      );
    });
  });
}
