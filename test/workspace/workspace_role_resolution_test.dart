import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/core/models/user_model.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/features/auth/data/models/login_response_model.dart';

void main() {
  group('WorkspaceService scoped role resolution', () {
    test('maps top-level workspace roles from the login response into the user session', () {
      final response = LoginResponseModel.fromJson({
        'session_id': 'session-token',
        'device_uuid': 'device-1',
        'permissions': ['networks.view'],
        'workspace_roles': [
          {
            'scope': 'NETWORK',
            'tenant_id': 17,
            'role_key': 'NETWORK_OWNER',
            'role_name': 'مالك الشبكة',
          },
        ],
        'user': {
          'user_id': 12,
          'user_full_name': 'Login Network Owner',
          'user_phone_number': '700000012',
          'role_id': null,
          'role': null,
        },
      });

      expect(response.user, isNotNull);
      expect(response.user!.role, isNull);
      expect(response.user!.workspaceRoles, ['NETWORK_OWNER']);
      expect(response.permissions, ['networks.view']);
    });

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

    test('uses the exact backend primary role when dual scope has no saved preference', () {
      final networkPrimary = UserModel.fromJson({
        'user_id': 13,
        'user_full_name': 'Network Primary',
        'user_phone_number': '700000013',
        'role_key': 'NETWORK_OWNER',
        'workspace_roles': [
          {
            'scope': 'NETWORK',
            'tenant_id': 17,
            'role_key': 'NETWORK_OWNER',
            'role_name': 'مالك الشبكة',
          },
          {
            'scope': 'POS',
            'tenant_id': 21,
            'role_key': 'POS_USER',
            'role_name': 'مستخدم نقطة بيع',
          },
        ],
      });
      final posPrimary = UserModel.fromJson({
        'user_id': 14,
        'user_full_name': 'POS Primary',
        'user_phone_number': '700000014',
        'role_key': 'POS_AGENT',
        'workspace_roles': [
          {
            'scope': 'NETWORK',
            'tenant_id': 17,
            'role_key': 'NETWORK_OWNER',
            'role_name': 'مالك الشبكة',
          },
          {
            'scope': 'POS',
            'tenant_id': 21,
            'role_key': 'POS_AGENT',
            'role_name': 'وكيل نقطة بيع',
          },
        ],
      });

      expect(
        WorkspaceService.instance.resolveWorkspaceForUser(networkPrimary),
        AppWorkspace.network,
      );
      expect(
        WorkspaceService.instance.resolveWorkspaceForUser(posPrimary),
        AppWorkspace.pos,
      );
    });

    test('does not guess a workspace for dual scope without backend preference', () {
      final user = UserModel.fromJson({
        'user_id': 15,
        'user_full_name': 'Dual Scope Without Primary Role',
        'user_phone_number': '700000015',
        'workspace_roles': [
          {
            'scope': 'NETWORK',
            'tenant_id': 17,
            'role_key': 'NETWORK_OWNER',
            'role_name': 'مالك الشبكة',
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
        () => WorkspaceService.instance.resolveWorkspaceForUser(user),
        throwsStateError,
      );
    });

    test('keeps all Platform roles outside mobile workspaces', () {
      for (final roleKey in [
        'SUPER_ADMIN',
        'SUPPORT_AGENT',
        'ACCOUNTANT',
      ]) {
        final user = UserModel.fromJson({
          'user_id': 99,
          'user_full_name': 'Platform User',
          'user_phone_number': '700000099',
          'role_key': roleKey,
          'workspace_roles': const [],
          'is_super_admin': roleKey == 'SUPER_ADMIN',
        });

        expect(user.isPlatformUser, isTrue, reason: roleKey);
        expect(
          () => WorkspaceService.instance.resolveWorkspaceForUser(user),
          throwsStateError,
          reason: roleKey,
        );
      }
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
