import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/enums/notification_type.dart';

void main() {
  group('Billing notification wire contract', () {
    test('recognizes all billing lifecycle notification types', () {
      const values = <String>[
        'BILLING_INVOICE_PAYMENT_REMINDER',
        'BILLING_SUBSCRIPTION_RENEWAL_REMINDER',
        'BILLING_INVOICE_ISSUED',
        'BILLING_PAYMENT_VERIFIED',
        'BILLING_PAYMENT_REJECTED',
        'BILLING_SUBSCRIPTION_ACTIVATED',
        'BILLING_SUBSCRIPTION_CANCELED',
        'BILLING_CREDIT_NOTE_ISSUED',
        'BILLING_REFUND_COMPLETED',
      ];

      for (final value in values) {
        final type = NotificationType.fromWire(value);
        expect(type.isKnown, isTrue, reason: value);
        expect(type.category, 'FINANCIAL', reason: value);
      }
    });

    test('keeps unknown notification values explicit', () {
      expect(NotificationType.fromWire('BILLING_FUTURE_EVENT'),
          NotificationType.unknown);
    });
  });
}
