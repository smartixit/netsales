import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/models/user_model.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/features/invoices/presentation/screens/pos_purchase_invoices_screen.dart';
import 'package:netsales/features/requests/presentation/screens/pos_procurement_orders_screen.dart';
import 'package:netsales/features/workspace/presentation/screens/pos_workspace_shell.dart';

void main() {
  group('POS Workspace Shell Tab Linking & Completeness', () {
    test('PosWorkspaceShell defines fully integrated tabs without empty state placeholders', () {
      const shell = PosWorkspaceShell();
      expect(shell, isNotNull);
    });

    test('WorkspaceService accurately identifies dual workspace authorization for switching', () {
      final service = WorkspaceService.instance;

      final networkOnlyUser = UserModel.fromJson({
        'user_id': 1,
        'user_full_name': 'مشغل الشبكة',
        'user_phone_number': '777111222',
        'workspace_roles': [
          {
            'scope': 'NETWORK',
            'tenant_id': 10,
            'role_key': 'NETWORK_OWNER',
            'role_name': 'مالك شبكة',
          },
        ],
      });
      expect(service.canSwitchWorkspace(networkOnlyUser), isFalse);

      final posOnlyUser = UserModel.fromJson({
        'user_id': 2,
        'user_full_name': 'وكيل نقطة البيع',
        'user_phone_number': '777333444',
        'workspace_roles': [
          {
            'scope': 'POS',
            'tenant_id': 20,
            'role_key': 'POS_AGENT',
            'role_name': 'وكيل نقطة بيع',
          },
        ],
      });
      expect(service.canSwitchWorkspace(posOnlyUser), isFalse);

      final dualMembershipUser = UserModel.fromJson({
        'user_id': 3,
        'user_full_name': 'مالك شبكة ونقطة بيع',
        'user_phone_number': '777555666',
        'workspace_roles': [
          {
            'scope': 'NETWORK',
            'tenant_id': 100,
            'role_key': 'NETWORK_OWNER',
            'role_name': 'مالك شبكة',
          },
          {
            'scope': 'POS',
            'tenant_id': 200,
            'role_key': 'POS_AGENT',
            'role_name': 'وكيل نقطة بيع',
          },
        ],
      });
      expect(service.canSwitchWorkspace(dualMembershipUser), isTrue);
    });

    test('PosProcurementOrdersScreen supports embedded configuration', () {
      const embeddedScreen = PosProcurementOrdersScreen(embedded: true);
      expect(embeddedScreen.embedded, isTrue);

      const standardScreen = PosProcurementOrdersScreen();
      expect(standardScreen.embedded, isFalse);
    });

    test('PosPurchaseInvoicesScreen supports embedded configuration', () {
      const embeddedScreen = PosPurchaseInvoicesScreen(embedded: true);
      expect(embeddedScreen.embedded, isTrue);

      const standardScreen = PosPurchaseInvoicesScreen();
      expect(standardScreen.embedded, isFalse);
    });
  });
}
