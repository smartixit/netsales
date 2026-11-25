import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/enums/role_scope.dart';
import 'package:netsales/core/services/permission_service.dart';

void main() {
  late PermissionService permissions;

  setUp(() {
    permissions = PermissionService.instance;
    permissions.clear();
    permissions.updateAccess(
      roleKey: 'NETWORK_OWNER',
      permissions: const [
        'requests.approve',
        'sales.view',
        'expenses.view',
      ],
    );
  });

  tearDown(() => permissions.clear());

  test('platform role names do not bypass explicit permission grants', () {
    permissions.updateAccess(
      roleKey: 'SUPER_ADMIN',
      permissions: const [],
    );

    expect(permissions.can('sales.view'), isFalse);
    expect(permissions.canAny(['sales.view', 'requests.approve']), isFalse);
    expect(permissions.canAll(['sales.view']), isFalse);
  });


  test('fails closed when only account-wide permission union is available', () {
    permissions.updateAccess(
      roleKey: 'NETWORK_OWNER',
      permissions: const ['sales.view', 'requests.approve'],
    );

    expect(permissions.hasWorkspaceContext, isFalse);
    expect(permissions.currentRole, isEmpty);
    expect(permissions.can('sales.view'), isFalse);
    expect(permissions.canAny(['sales.view', 'requests.approve']), isFalse);
    expect(permissions.canAll(['sales.view']), isFalse);
  });

  test('rejects Platform and unknown scopes as operational permission contexts', () {
    permissions.setWorkspaceContext(
      scope: RoleScope.platform,
      tenantId: 12,
      roleKey: 'SUPER_ADMIN',
      permissions: const ['sales.view'],
    );
    expect(permissions.hasWorkspaceContext, isFalse);
    expect(permissions.can('sales.view'), isFalse);

    permissions.setWorkspaceContext(
      scope: RoleScope.unknown,
      tenantId: 12,
      roleKey: 'NETWORK_OWNER',
      permissions: const ['sales.view'],
    );
    expect(permissions.hasWorkspaceContext, isFalse);
    expect(permissions.can('sales.view'), isFalse);
  });

  test('uses only permissions from the active Network membership', () {
    permissions.setWorkspaceContext(
      scope: RoleScope.network,
      tenantId: 12,
      roleKey: 'NETWORK_ACCOUNTANT',
      permissions: const ['sales.view'],
    );

    expect(permissions.can('sales.view'), isTrue);
    expect(permissions.can('requests.approve'), isFalse);
    expect(permissions.can('expenses.view'), isFalse);
    expect(permissions.currentRole, 'NETWORK_ACCOUNTANT');
  });

  test('accepts only the declared operational roles for each scope', () {
    const cases = <({RoleScope scope, String roleKey})>[
      (scope: RoleScope.network, roleKey: 'NETWORK_OWNER'),
      (scope: RoleScope.network, roleKey: 'NETWORK_USER'),
      (scope: RoleScope.network, roleKey: 'NETWORK_ACCOUNTANT'),
      (scope: RoleScope.pos, roleKey: 'POS_AGENT'),
      (scope: RoleScope.pos, roleKey: 'POS_USER'),
      (scope: RoleScope.pos, roleKey: 'POS_ACCOUNTANT'),
    ];

    for (final item in cases) {
      permissions.setWorkspaceContext(
        scope: item.scope,
        tenantId: 12,
        roleKey: item.roleKey,
        permissions: const ['sales.view'],
      );

      expect(permissions.hasWorkspaceContext, isTrue,
          reason: '${item.scope.wireValue} / ${item.roleKey}');
      expect(permissions.can('sales.view'), isTrue,
          reason: '${item.scope.wireValue} / ${item.roleKey}');
    }
  });

  test('rejects a Network role bound to a POS tenant', () {
    permissions.setWorkspaceContext(
      scope: RoleScope.pos,
      tenantId: 12,
      roleKey: 'NETWORK_OWNER',
      permissions: const ['sales.view'],
    );

    expect(permissions.hasWorkspaceContext, isFalse);
    expect(permissions.currentRole, isEmpty);
    expect(permissions.can('sales.view'), isFalse);
  });

  test('rejects a POS role bound to a Network tenant', () {
    permissions.setWorkspaceContext(
      scope: RoleScope.network,
      tenantId: 12,
      roleKey: 'POS_AGENT',
      permissions: const ['sales.view'],
    );

    expect(permissions.hasWorkspaceContext, isFalse);
    expect(permissions.currentRole, isEmpty);
    expect(permissions.can('sales.view'), isFalse);
  });

  test('rejects unknown operational role keys', () {
    permissions.setWorkspaceContext(
      scope: RoleScope.network,
      tenantId: 12,
      roleKey: 'CUSTOM_UNKNOWN_ROLE',
      permissions: const ['sales.view'],
    );

    expect(permissions.hasWorkspaceContext, isFalse);
    expect(permissions.can('sales.view'), isFalse);
  });

  test('does not fall back to account-wide permissions without a tenant', () {
    permissions.setWorkspaceContext(
      scope: RoleScope.pos,
      tenantId: 0,
      roleKey: '',
      permissions: const [],
    );

    expect(permissions.can('sales.view'), isFalse);
    expect(permissions.can('requests.approve'), isFalse);
  });

  test('switching tenants replaces, rather than merges, capabilities', () {
    permissions.setWorkspaceContext(
      scope: RoleScope.network,
      tenantId: 12,
      roleKey: 'NETWORK_OWNER',
      permissions: const ['requests.approve'],
    );
    expect(permissions.can('requests.approve'), isTrue);

    permissions.setWorkspaceContext(
      scope: RoleScope.network,
      tenantId: 18,
      roleKey: 'NETWORK_ACCOUNTANT',
      permissions: const ['sales.view'],
    );

    expect(permissions.can('requests.approve'), isFalse);
    expect(permissions.can('sales.view'), isTrue);
  });
}
