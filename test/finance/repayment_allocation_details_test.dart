import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/features/finance/data/models/pos_repayment_models.dart';
import 'package:netsales/features/finance/domain/entities/repayment_payment_method.dart';

void main() {
  group('Repayment allocation invoice context', () {
    test('parses invoice values and labels from the nested Laravel resource', () {
      final model = PosRepaymentModel.fromJson({
        'repayment_id': 50,
        'network_id': 1,
        'pos_id': 2,
        'amount': 300000.00,
        'payment_method': 'BANK',
        'status': 'COMPLETED',
        'allocations': [
          {
            'allocation_id': 1,
            'repayment_id': 50,
            'invoice_id': 100,
            'network_id': 1,
            'pos_id': 2,
            'allocated_amount': 200000.00,
            'status': 'COMPLETED',
            'invoice': {
              'invoice_uuid': 'INV-100',
              'invoice_total_amount': 250000.00,
              'paid_amount': 250000.00,
              'remaining_amount': 0.00,
              'payment_status': 'PAID',
              'payment_status_label': 'مسدد',
              'invoice_date': '2026-11-01 09:00:00',
              'sale_type': 'CREDIT',
              'sale_type_label': 'آجل',
            },
          },
        ],
      });

      final allocation = model.allocations.single;

      expect(model.typedPaymentMethod, RepaymentPaymentMethod.bank);
      expect(allocation.invoiceUuid, 'INV-100');
      expect(allocation.invoiceTotalAmount, 250000.00);
      expect(allocation.invoicePaidAmount, 250000.00);
      expect(allocation.invoiceRemainingAmount, 0.00);
      expect(allocation.invoicePaymentStatus, 'PAID');
      expect(allocation.invoicePaymentStatusLabel, 'مسدد');
      expect(allocation.invoiceDate, '2026-11-01 09:00:00');
      expect(allocation.saleType, 'CREDIT');
      expect(allocation.saleTypeLabel, 'آجل');
    });

    test('rejects an allocation response that omits its required nested invoice', () {
      expect(
        () => RepaymentAllocationModel.fromJson({
          'allocation_id': 2,
          'repayment_id': 50,
          'invoice_id': 101,
          'network_id': 1,
          'pos_id': 2,
          'allocated_amount': 100000.00,
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('unknown repayment payment methods remain unknown', () {
      final model = PosRepaymentModel.fromJson({
        'repayment_id': 51,
        'network_id': 1,
        'pos_id': 2,
        'amount': 100.00,
        'payment_method': 'FUTURE_METHOD',
      });

      expect(model.typedPaymentMethod, RepaymentPaymentMethod.unknown);
    });
  });
}
