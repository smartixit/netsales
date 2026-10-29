import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// ============================================================================
/// Display-Only Policy Tests (AGENTS.md §34)
/// ============================================================================
/// Verifies that the frontend does NOT send computed financial values
/// in submission payloads, and does NOT perform financial arithmetic
/// in controllers (except documented display helpers).
void main() {
  group('Display-Only Policy — Create Sale Invoice Controller', () {
    test('submitInvoice payload must not include computed totals/price/discount', () {
      final source = File(
        'lib/features/operations/presentation/controllers/create_sale_invoice_controller.dart',
      ).readAsStringSync();

      // Forbidden keys in items payload
      expect(source, isNot(contains("'voucher_price'")));
      expect(source, isNot(contains("'item_discount'")));
      expect(source, isNot(contains("'invoice_total_amount'")));
      expect(source, isNot(contains("'remaining_amount'")));
      expect(source, isNot(contains("'total_net_amount'")));

      // paidAmount must be nullable (null for cash)
      expect(source, contains('double? get paidAmount'));
      expect(source, contains('if (saleType.value == \'CASH\') return null;'));
    });

    test('preview getters must be documented as DISPLAY-ONLY', () {
      final source = File(
        'lib/features/operations/presentation/controllers/create_sale_invoice_controller.dart',
      ).readAsStringSync();

      expect(source, contains('DISPLAY-ONLY PREVIEW'));
    });
  });

  group('Display-Only Policy — Create Voucher Request Controller', () {
    test('submit payload must not include computed totals/price/discount', () {
      final source = File(
        'lib/features/operations/presentation/controllers/create_voucher_request_controller.dart',
      ).readAsStringSync();

      expect(source, isNot(contains("'voucher_price'")));
      expect(source, isNot(contains("'item_discount'")));
      expect(source, isNot(contains("'request_total_amount'")));
    });
  });

  group('Display-Only Policy — Edit Voucher Request Controller', () {
    test('submit payload must not include computed totals/price/discount', () {
      final source = File(
        'lib/features/operations/presentation/controllers/edit_voucher_request_controller.dart',
      ).readAsStringSync();

      expect(source, isNot(contains("'voucher_price'")));
      expect(source, isNot(contains("'item_discount'")));
    });
  });

  group('Display-Only Policy — Backend Authority (FormRequests)', () {
    test('StoreSaleInvoiceRequest must not validate voucher_price/item_discount', () {
      final source = File(
        '../netsales_api/app/Http/Requests/API/V1/SaleInvoice/StoreSaleInvoiceRequest.php',
      ).readAsStringSync();

      // These fields should be removed (backend uses catalog/effective)
      expect(source, isNot(contains("items.*.voucher_price")));
      expect(source, isNot(contains("items.*.item_discount")));
    });
  });

  group('Display-Only Policy — No Fabricated Data', () {
    test('dashboard trend chart must not use fabricated multipliers', () {
      final source = File(
        'lib/features/home/presentation/widgets/dashboard/dashboard_sales_trend_chart.dart',
      ).readAsStringSync();

      expect(source, isNot(contains('totalAmount * 0.')));
    });
  });
}
