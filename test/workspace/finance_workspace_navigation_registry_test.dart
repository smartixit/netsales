import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/routing/screen_registry.dart';

void main() {
  group('Workspace navigation excludes deferred financial workflows', () {
    test('workspace registry does not expose debt, repayment or wallet routes', () {
      const deferredRoutes = {
        AppRoutes.repaymentCollection,
        AppRoutes.repaymentHistory,
        AppRoutes.posDebtLedger,
        AppRoutes.networkWalletStatement,
        AppRoutes.posWalletStatement,
      };

      for (final route in deferredRoutes) {
        expect(
          ScreenRegistry.findByRoute(route),
          isNull,
          reason: 'Deferred financial route must not be part of Workspace navigation metadata.',
        );
      }
    });

    test('operational invoice and procurement routes remain registered', () {
      expect(ScreenRegistry.findByRoute(AppRoutes.wholesaleInvoices), isNotNull);
      expect(ScreenRegistry.findByRoute(AppRoutes.purchaseInvoices), isNotNull);
      expect(ScreenRegistry.findByRoute(AppRoutes.procurementOrders), isNotNull);
    });
  });
}
