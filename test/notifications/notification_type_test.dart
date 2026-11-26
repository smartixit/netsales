import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/enums/notification_type.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';

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
        'BILLING_SUBSCRIPTION_CANCELLATION_SCHEDULED',
        'BILLING_CREDIT_NOTE_ISSUED',
        'BILLING_REFUND_COMPLETED',
      ];

      for (final value in values) {
        final type = NotificationType.fromWire(value);
        expect(type.isKnown, isTrue, reason: value);
        expect(type.category, 'FINANCIAL', reason: value);
      }
    });

    test('provides a known centralized presentation for every Billing event', () {
      const values = <NotificationType>[
        NotificationType.billingInvoicePaymentReminder,
        NotificationType.billingSubscriptionRenewalReminder,
        NotificationType.billingInvoiceIssued,
        NotificationType.billingPaymentVerified,
        NotificationType.billingPaymentRejected,
        NotificationType.billingSubscriptionActivated,
        NotificationType.billingSubscriptionCanceled,
        NotificationType.billingSubscriptionCancellationScheduled,
        NotificationType.billingCreditNoteIssued,
        NotificationType.billingRefundCompleted,
      ];

      for (final value in values) {
        final presentation =
            EnumPresentationRegistry.resolveNotificationType(value);
        expect(presentation.isKnown, isTrue, reason: value.name);
        expect(presentation.label.trim(), isNotEmpty, reason: value.name);
      }
    });

    test('keeps unknown notification values explicit', () {
      expect(NotificationType.fromWire('BILLING_FUTURE_EVENT'),
          NotificationType.unknown);
    });
  });
}
