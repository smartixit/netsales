import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/constants/app_permissions.dart';
import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/routing/screen_registry.dart';

void main() {
  group('M8 workspace navigation registry', () {
    test('network finance workflows are discoverable in the network workspace', () {
      final collection = ScreenRegistry.findByRoute(
        AppRoutes.repaymentCollection,
      );
      final history = ScreenRegistry.findByRoute(AppRoutes.repaymentHistory);
      final wallet = ScreenRegistry.findByRoute(
        AppRoutes.networkWalletStatement,
      );

      expect(collection, isNotNull);
      expect(collection!.screenId, 'NET-13');
      expect(collection.workspace, AppWorkspace.network);
      expect(collection.requiredPermission, AppPermissions.posWalletsCreate);
      expect(collection.isBalanceMutation, isTrue);

      expect(history, isNotNull);
      expect(history!.screenId, 'NET-14');
      expect(history.workspace, AppWorkspace.network);
      expect(history.requiredPermission, AppPermissions.networkWalletsView);

      expect(wallet, isNotNull);
      expect(wallet!.workspace, AppWorkspace.network);
    });

    test('POS debt and wallet workflows are discoverable in the POS workspace', () {
      final debt = ScreenRegistry.findByRoute(AppRoutes.posDebtLedger);
      final wallet = ScreenRegistry.findByRoute(AppRoutes.posWalletStatement);

      expect(debt, isNotNull);
      expect(debt!.screenId, 'POS-10');
      expect(debt.workspace, AppWorkspace.pos);
      expect(debt.requiredPermission, AppPermissions.posWalletsView);

      expect(wallet, isNotNull);
      expect(wallet!.workspace, AppWorkspace.pos);
    });

    test('finance navigation route IDs and routes remain unique', () {
      const financeRoutes = {
        AppRoutes.repaymentCollection,
        AppRoutes.repaymentHistory,
        AppRoutes.posDebtLedger,
        AppRoutes.networkWalletStatement,
        AppRoutes.posWalletStatement,
      };
      const financeIds = {'NET-13', 'NET-14', 'POS-10'};

      final financeDescriptors = ScreenRegistry.allScreens
          .where((screen) => financeRoutes.contains(screen.route))
          .toList();

      expect(
        financeDescriptors.map((screen) => screen.route).toSet(),
        financeRoutes,
      );
      expect(
        financeDescriptors.where((screen) => financeIds.contains(screen.screenId)).length,
        financeIds.length,
      );
      expect(
        financeDescriptors.map((screen) => screen.screenId).toSet().length,
        financeDescriptors.length,
      );
    });
  });
}
