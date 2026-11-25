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
