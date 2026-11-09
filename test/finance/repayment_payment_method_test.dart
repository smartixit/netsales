import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/features/finance/domain/entities/repayment_payment_method.dart';

void main() {
  group('RepaymentPaymentMethod', () {
    test('exposes the backend-supported wire values and Arabic labels', () {
      expect(
        RepaymentPaymentMethod.values.map((method) => method.wireValue),
        ['CASH', 'BANK', 'WALLET'],
      );
      expect(
        RepaymentPaymentMethod.values.map((method) => method.label),
        ['نقدي', 'بنكي', 'محفظة'],
      );
    });

    test('maps known wire values and safely defaults unknown values to cash', () {
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
      expect(
        RepaymentPaymentMethod.fromWire('UNSUPPORTED'),
        RepaymentPaymentMethod.cash,
      );
    });
  });
}
