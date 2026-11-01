import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/constants/app_permissions.dart';
import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/core/models/role_model.dart';
import 'package:netsales/core/models/user_model.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/routing/screen_registry.dart';
import 'package:netsales/core/services/integration_gate_service.dart';
import 'package:netsales/core/services/workspace_service.dart';

void main() {
  group('Workspace Resolution & Service Tests', () {
    final workspaceService = WorkspaceService.instance;

    test('resolves null user to unsupported workspace', () {
      final workspace = workspaceService.resolveWorkspaceForUser(null);
      expect(workspace, equals(AppWorkspace.unsupported));
    });

    test('resolves SUPER_ADMIN and SUPPORT_AGENT to unsupported platform workspace', () {
      const superAdminUser = UserModel(
        userId: 1,
        userFullName: 'Platform Super Admin',
        userPhoneNumber: '777000001',
        role: RoleModel(roleId: 1, roleKey: AppRoles.superAdmin, roleName: 'مدير عام المنصة'),
      );
      expect(workspaceService.resolveWorkspaceForUser(superAdminUser), equals(AppWorkspace.unsupported));

      const supportUser = UserModel(
        userId: 2,
        userFullName: 'Support Agent',
        userPhoneNumber: '777000002',
        role: RoleModel(roleId: 7, roleKey: AppRoles.supportAgent, roleName: 'وكيل دعم فني'),
      );
      expect(workspaceService.resolveWorkspaceForUser(supportUser), equals(AppWorkspace.unsupported));
    });

    test('resolves NETWORK roles to network workspace', () {
      const networkOwner = UserModel(
        userId: 10,
        userFullName: 'Network Owner User',
        userPhoneNumber: '777111222',
        role: RoleModel(roleId: 2, roleKey: AppRoles.networkOwner, roleName: 'مالك شبكة'),
      );
      expect(workspaceService.resolveWorkspaceForUser(networkOwner), equals(AppWorkspace.network));

      const networkStaff = UserModel(
        userId: 11,
        userFullName: 'Network Staff User',
        userPhoneNumber: '777111333',
        role: RoleModel(roleId: 3, roleKey: AppRoles.networkUser, roleName: 'موظف شبكة'),
      );
      expect(workspaceService.resolveWorkspaceForUser(networkStaff), equals(AppWorkspace.network));

      const networkAccountant = UserModel(
        userId: 12,
        userFullName: 'Network Accountant',
        userPhoneNumber: '777111444',
        role: RoleModel(roleId: 6, roleKey: 'NETWORK_ACCOUNTANT', roleName: 'محاسب شبكة'),
      );
      expect(workspaceService.resolveWorkspaceForUser(networkAccountant), equals(AppWorkspace.network));
    });

    test('resolves POS roles to pos workspace', () {
      const posAgent = UserModel(
        userId: 20,
        userFullName: 'POS Agent Owner',
        userPhoneNumber: '711222333',
        role: RoleModel(roleId: 4, roleKey: AppRoles.posAgent, roleName: 'وكيل نقطة بيع'),
      );
      expect(workspaceService.resolveWorkspaceForUser(posAgent), equals(AppWorkspace.pos));

      const posStaff = UserModel(
        userId: 21,
        userFullName: 'POS Staff Member',
        userPhoneNumber: '711222444',
        role: RoleModel(roleId: 5, roleKey: AppRoles.posUser, roleName: 'موظف نقطة بيع'),
      );
      expect(workspaceService.resolveWorkspaceForUser(posStaff), equals(AppWorkspace.pos));

      const posAccountant = UserModel(
        userId: 22,
        userFullName: 'POS Accountant',
        userPhoneNumber: '711222555',
        role: RoleModel(roleId: 9, roleKey: 'POS_ACCOUNTANT', roleName: 'محاسب نقطة بيع'),
      );
      expect(workspaceService.resolveWorkspaceForUser(posAccountant), equals(AppWorkspace.pos));
    });
  });

  group('Controlled Integration Gate Service Tests', () {
    final gateService = IntegrationGateService.instance;

    test('locks all balance-changing mutations by default during Phase 4 Milestone 1', () {
      expect(gateService.isLiveMutationEnabled(ControlledMutation.walletDeposit), isFalse);
      expect(gateService.isLiveMutationEnabled(ControlledMutation.walletWithdrawal), isFalse);
      expect(gateService.isLiveMutationEnabled(ControlledMutation.walletTransfer), isFalse);
      expect(gateService.isLiveMutationEnabled(ControlledMutation.invoiceCreation), isFalse);
      expect(gateService.isLiveMutationEnabled(ControlledMutation.invoiceSettlement), isFalse);
      expect(gateService.isLiveMutationEnabled(ControlledMutation.creditProcurementApproval), isFalse);
      expect(gateService.isLiveMutationEnabled(ControlledMutation.requestApproval), isFalse);
      expect(gateService.isLiveMutationEnabled(ControlledMutation.requestCancellation), isFalse);
    });

    test('provides Arabic security explanations for locked mutations', () {
      final depositExplanation = gateService.getGateExplanation(ControlledMutation.walletDeposit);
      expect(depositExplanation, contains('بوابة أمان محاسبية مشروطة'));

      final invoiceExplanation = gateService.getGateExplanation(ControlledMutation.invoiceCreation);
      expect(invoiceExplanation, contains('مقفل في هذه النسخة التطويرية'));
    });
  });

  group('Screen Registry Tests', () {
    test('contains all canonical Screen IDs with valid routes and metadata', () {
      final auth06 = ScreenRegistry.findById('AUTH-06');
      expect(auth06, isNotNull);
      expect(auth06!.route, equals(AppRoutes.unsupportedPlatform));
      expect(auth06.titleAr, contains('المنصة العامة'));

      final net01 = ScreenRegistry.findById('NET-01');
      expect(net01, isNotNull);
      expect(net01!.route, equals(AppRoutes.networkWorkspace));
      expect(net01.workspace, equals(AppWorkspace.network));

      final net02 = ScreenRegistry.findById('NET-02');
      expect(net02, isNotNull);
      expect(net02!.titleEn, equals('Supply Requests'));

      final pos01 = ScreenRegistry.findById('POS-01');
      expect(pos01, isNotNull);
      expect(pos01!.route, equals(AppRoutes.posWorkspace));
      expect(pos01.workspace, equals(AppWorkspace.pos));

      final pos02 = ScreenRegistry.findById('POS-02');
      expect(pos02, isNotNull);
      expect(pos02!.isBalanceMutation, isFalse);
      expect(pos02.implementationState,
          equals(ScreenImplementationState.implemented));
    });

    test('resolves screen descriptor by canonical route', () {
      final descriptor = ScreenRegistry.findByRoute(AppRoutes.networkWorkspace);
      expect(descriptor, isNotNull);
      expect(descriptor!.screenId, equals('NET-01'));
    });
  });
}

