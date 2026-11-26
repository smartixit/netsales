import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/features/billing/domain/value_objects/billing_amount_parser.dart';

void main() {
  group('BillingAmountParser', () {
    test('converts decimal input exactly for two decimal places', () {
      expect(BillingAmountParser.toMinor('125.40', 2), 12540);
    });

    test('converts currencies without fractional minor units', () {
      expect(BillingAmountParser.toMinor('125', 0), 125);
    });

    test('pads fractional digits to the currency precision', () {
      expect(BillingAmountParser.toMinor('12.5', 3), 12500);
    });

    test('rejects excess precision, separators and negative amounts', () {
      expect(BillingAmountParser.toMinor('12.345', 2), isNull);
      expect(BillingAmountParser.toMinor('1,200.00', 2), isNull);
      expect(BillingAmountParser.toMinor('-1.00', 2), isNull);
    });

    test('rejects zero, invalid precision and integer overflow', () {
      expect(BillingAmountParser.toMinor('0.00', 2), isNull);
      expect(BillingAmountParser.toMinor('1', 10), isNull);
      expect(
        BillingAmountParser.toMinor('999999999999999999999999', 2),
        isNull,
      );
    });
  });
}
