import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/enums/invoice_payment_status.dart';
import 'package:netsales/core/enums/sale_type.dart';
import 'package:netsales/features/invoices/data/models/invoice_item_model.dart';
import 'package:netsales/features/invoices/data/models/invoice_model.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';

void main() {
  group('Invoice Models and Entities Domain Tests', () {
    test(
      'InvoiceItemModel.fromJson should parse correctly with nested package',
      () {
        final json = {
          'item_id': 101,
          'invoice_id': 50,
          'package_id': 12,
          'voucher_price': 15.5,
          'voucher_count': 100,
          'item_discount': 50.0,
          'item_total_amount': 1500.0,
          'created_at': '2026-11-07 12:00:00',
          'package': {
            'package_name': 'باقة النخبة 100 ميجا',
            'package_color': '#10B981',
          },
        };

        final item = InvoiceItemModel.fromJson(json);

        expect(item.itemId, equals(101));
        expect(item.invoiceId, equals(50));
        expect(item.packageId, equals(12));
        expect(item.voucherPrice, equals(15.5));
        expect(item.voucherCount, equals(100));
        expect(item.itemDiscount, equals(50.0));
        expect(item.itemTotalAmount, equals(1500.0));
        expect(item.packageName, equals('باقة النخبة 100 ميجا'));
        expect(item.packageColor, equals('#10B981'));
      },
    );

    test(
      'InvoiceModel.fromJson should parse correctly with nested relationships',
      () {
        final json = {
          'invoice_id': 200,
          'network_id': 1,
          'pos_id': 2,
          'request_id': 88,
          'request_uuid': 'req-uuid-88',
          'invoice_uuid': 'inv-uuid-200',
          'sale_type': 'CREDIT',
          'sale_type_label': 'آجل (ائتمان)',
          'invoice_total_amount': 5000.0,
          'paid_amount': 2000.0,
          'remaining_amount': 3000.0,
          'payment_status': 'PARTIALLY_PAID',
          'payment_status_label': 'مسددة جزئياً',
          'is_fully_paid': false,
          'invoice_date': '2026-11-07 14:00:00',
          'network': {'network_name': 'شبكة الرواد للاتصالات'},
          'pos': {
            'pos_name': 'مركز الأمل للخدمات',
            'pos_phone_number': '777123456',
          },
          'items': [
            {
              'item_id': 1,
              'invoice_id': 200,
              'package_id': 10,
              'voucher_price': 50.0,
              'voucher_count': 100,
              'item_discount': 0.0,
              'item_total_amount': 5000.0,
              'package': {'package_name': 'باقة 5000'},
            },
          ],
        };

        final invoice = InvoiceModel.fromJson(json);

        expect(invoice.invoiceId, equals(200));
        expect(invoice.networkId, equals(1));
        expect(invoice.posId, equals(2));
        expect(invoice.requestId, equals(88));
        expect(invoice.requestUuid, equals('req-uuid-88'));
        expect(invoice.invoiceUuid, equals('inv-uuid-200'));
        expect(invoice.saleType, equals(SaleType.credit));
        expect(
          invoice.paymentStatus,
          equals(InvoicePaymentStatus.partiallyPaid),
        );
        expect(invoice.isPartiallyPaid, isTrue);
        expect(invoice.isPaid, isFalse);
        expect(invoice.invoiceTotalAmount, equals(5000.0));
        expect(invoice.paidAmount, equals(2000.0));
        expect(invoice.remainingAmount, equals(3000.0));
        expect(invoice.networkName, equals('شبكة الرواد للاتصالات'));
        expect(invoice.posName, equals('مركز الأمل للخدمات'));
        expect(invoice.posPhoneNumber, equals('777123456'));
        expect(invoice.items.length, equals(1));
        expect(invoice.items.first.packageName, equals('باقة 5000'));
      },
    );

    test('InvoiceEntity payment state helpers should reflect authoritative status correctly', () {
      const paidInvoice = InvoiceEntity(
        invoiceId: 1,
        networkId: 1,
        posId: 1,
        invoiceTotalAmount: 1000.0,
        paidAmount: 1000.0,
        remainingAmount: 0.0,
        paymentStatusRaw: 'PAID',
        isFullyPaid: true,
      );

      expect(paidInvoice.isPaid, isTrue);
      expect(paidInvoice.isUnpaid, isFalse);
      expect(paidInvoice.isPartiallyPaid, isFalse);

      const unpaidInvoice = InvoiceEntity(
        invoiceId: 2,
        networkId: 1,
        posId: 1,
        invoiceTotalAmount: 1000.0,
        paidAmount: 0.0,
        remainingAmount: 1000.0,
        paymentStatusRaw: 'UNPAID',
        isFullyPaid: false,
      );

      expect(unpaidInvoice.isPaid, isFalse);
      expect(unpaidInvoice.isUnpaid, isTrue);
      expect(unpaidInvoice.isPartiallyPaid, isFalse);
    });
  });
}
