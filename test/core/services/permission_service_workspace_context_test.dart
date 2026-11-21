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
