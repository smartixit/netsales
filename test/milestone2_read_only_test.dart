import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/routing/screen_registry.dart';
import 'package:netsales/features/operations/data/models/sale_invoice_model.dart';
import 'package:netsales/features/operations/data/models/voucher_request_model.dart';

void main() {
  group('Milestone 2 - Screen Registry Canonical Verification', () {
    test('enforces exact canonical IDs and implementation states for NETWORK screens', () {
      final netScreens = [
        'NET-01', 'NET-02', 'NET-03', 'NET-04', 'NET-05',
        'NET-06', 'NET-07', 'NET-08', 'NET-09', 'NET-10', 'NET-11',
      ];

      for (final id in netScreens) {
        final screen = ScreenRegistry.findById(id);
        expect(screen, isNotNull, reason: 'Screen $id must be present in registry');
      }

      expect(ScreenRegistry.findById('NET-01')!.titleEn, equals('Network Dashboard'));
      expect(ScreenRegistry.findById('NET-02')!.titleEn, equals('Supply Requests'));
      expect(ScreenRegistry.findById('NET-03')!.titleEn, equals('Wholesale Invoices'));
      expect(ScreenRegistry.findById('NET-04')!.titleEn, equals('Network Wallet Statement'));
      expect(ScreenRegistry.findById('NET-05')!.titleEn, equals('Affiliated POS Directory'));
      expect(ScreenRegistry.findById('NET-06')!.titleEn, equals('Voucher Package Catalog'));
      expect(ScreenRegistry.findById('NET-07')!.titleEn, equals('Operational Expenses'));
      expect(ScreenRegistry.findById('NET-08')!.titleEn, equals('Network Staff'));
      expect(ScreenRegistry.findById('NET-09')!.titleEn, equals('Provider Subscription'));
      expect(ScreenRegistry.findById('NET-10')!.titleEn, equals('Supply Request Details'));
      expect(ScreenRegistry.findById('NET-11')!.titleEn, equals('Wholesale Invoice Details'));
    });

    test('enforces exact canonical IDs and implementation states for POS screens', () {
      final posScreens = [
        'POS-01', 'POS-02', 'POS-03', 'POS-04', 'POS-05',
        'POS-06', 'POS-07', 'POS-08', 'POS-09',
      ];

      for (final id in posScreens) {
        final screen = ScreenRegistry.findById(id);
        expect(screen, isNotNull, reason: 'Screen $id must be present in registry');
      }

      expect(ScreenRegistry.findById('POS-01')!.titleEn, equals('POS Dashboard'));
      expect(ScreenRegistry.findById('POS-02')!.titleEn, equals('New Procurement Order'));
      expect(ScreenRegistry.findById('POS-03')!.titleEn, equals('Purchase Invoices'));
      expect(ScreenRegistry.findById('POS-04')!.titleEn, equals('POS Wallet Statement'));
      expect(ScreenRegistry.findById('POS-05')!.titleEn, equals('Procurement Tracking'));
      expect(ScreenRegistry.findById('POS-06')!.titleEn, equals('Linked Networks and Catalog'));
      expect(ScreenRegistry.findById('POS-07')!.titleEn, equals('POS Staff'));
      expect(ScreenRegistry.findById('POS-08')!.titleEn, equals('Procurement Order Details'));
      expect(ScreenRegistry.findById('POS-09')!.titleEn, equals('Purchase Invoice Details'));
    });
  });

  group('Milestone 2 - Read-Only Model & Serialization Verification', () {
    test('SaleInvoiceModel correctly parses backend server payload without local calculations', () {
      final serverJson = <String, dynamic>{
        'invoice_id': 105,
        'network_id': 2,
        'pos_id': 8,
        'invoice_uuid': 'INV-2026-9901',
        'sale_type': 'CREDIT',
        'sale_type_label': 'آجل (على الحساب)',
        'invoice_total_amount': 250000.0,
        'paid_amount': 50000.0,
        'remaining_amount': 200000.0,
        'payment_status': 'PARTIALLY_PAID',
        'payment_status_label': 'مسددة جزئياً',
        'is_fully_paid': false,
        'invoice_date': '2026-11-01 12:00:00',
        'created_by': 14,
        'created_at': '2026-11-01 12:00:00',
        'network': {
          'network_id': 2,
          'network_name': 'شبكة الأمل',
        },
        'pos': {
          'pos_id': 8,
          'pos_name': 'نقطة بيع النور',
          'pos_code': 'POS-88',
        },
        'items': [
          {
            'item_id': 1,
            'package_id': 4,
            'voucher_price': 1000.0,
            'voucher_count': 250,
            'item_discount': 0.0,
            'item_total_amount': 250000.0,
          }
        ],
      };

      final model = SaleInvoiceModel.fromJson(serverJson);
      expect(model.invoiceId, equals(105));
      expect(model.invoiceTotalAmount, equals(250000.0));
      expect(model.remainingAmount, equals(200000.0));
      expect(model.isCredit, isTrue);
      expect(model.networkName, equals('شبكة الأمل'));
      expect(model.posName, equals('نقطة بيع النور'));
      expect(model.items?.length, equals(1));
    });

    test('VoucherRequestModel correctly parses backend server payload', () {
      final serverJson = <String, dynamic>{
        'request_id': 204,
        'network_id': 2,
        'pos_id': 8,
        'request_uuid': 'REQ-2026-1002',
        'sale_type': 'CREDIT',
        'sale_type_label': 'طلب آجل',
        'request_total_amount': 150000.0,
        'request_date': '2026-11-01 10:30:00',
        'status': 'PENDING',
        'status_label': 'قيد الانتظار',
        'created_by': 14,
        'request_note': 'يرجى التوريد بشكل عاجل',
        'network': {
          'network_id': 2,
          'network_name': 'شبكة الأمل',
        },
        'pos': {
          'pos_id': 8,
          'pos_name': 'نقطة بيع النور',
          'pos_code': 'POS-88',
        },
        'items': [
          {
            'item_id': 1,
            'package_id': 4,
            'quantity': 150,
            'unit_price': 1000.0,
            'total_price': 150000.0,
          }
        ],
      };

      final model = VoucherRequestModel.fromJson(serverJson);
      expect(model.requestId, equals(204));
      expect(model.requestTotalAmount, equals(150000.0));
      expect(model.isPending, isTrue);
      expect(model.networkName, equals('شبكة الأمل'));
      expect(model.items?.length, equals(1));
    });
  });
}

