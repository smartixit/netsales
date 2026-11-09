import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/features/finance/domain/entities/repayment_payment_method.dart';

void main() {
  group('RepaymentPaymentMethod', () {
    test('exposes only the payment methods supported by the backend', () {
      expect(
        RepaymentPaymentMethod.selectableValues.map((method) => method.wireValue),
        ['CASH', 'BANK', 'WALLET'],
      );
      expect(
        RepaymentPaymentMethod.selectableValues.map((method) => method.label),
        ['نقدي', 'بنكي', 'محفظة'],
      );
    });

    test('maps known wire values without changing their casing', () {
      expect(
        RepaymentPaymentMethod.fromWire('CASH'),
        RepaymentPaymentMethod.cash,
      );
      expect(
        RepaymentPaymentMethod.fromWire('BANK'),
        RepaymentPaymentMethod.bank,
      );
      expect(
        RepaymentPaymentMethod.fromWire('WALLET'),
        RepaymentPaymentMethod.wallet,
      );
    });

    test('preserves unsupported values as unknown instead of treating them as cash', () {
      expect(
        RepaymentPaymentMethod.fromWire('UNSUPPORTED'),
        RepaymentPaymentMethod.unknown,
      );
      expect(
        RepaymentPaymentMethod.fromWire(null),
        RepaymentPaymentMethod.unknown,
      );
      expect(
        RepaymentPaymentMethod.selectableValues,
        isNot(contains(RepaymentPaymentMethod.unknown)),
      );
    });

    test('adapts the optional reference field to the selected payment method', () {
      expect(
        RepaymentPaymentMethod.bank.referenceLabel,
        'رقم الحوالة أو الإشعار (اختياري)',
      );
      expect(
        RepaymentPaymentMethod.wallet.referenceHint,
        'أدخل رقم العملية أو مرجع المحفظة...',
      );
      expect(
        RepaymentPaymentMethod.cash.referenceLabel,
        'مرجع سند القبض (اختياري)',
      );
    });
  });
}
