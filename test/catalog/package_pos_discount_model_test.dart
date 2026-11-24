import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/enums/package_discount_validity_state.dart';
import 'package:netsales/features/catalog/data/models/package_pos_discount_model.dart';

void main() {
  group('PackagePosDiscountModel.fromJson', () {
    test('parses Laravel boolean status and server-calculated prices', () {
      final model = PackagePosDiscountModel.fromJson({
        'discount_id': 12,
        'pos_id': 34,
        'status': true,
        'discount_cash': 15.5,
        'discount_credit': 8,
        'validity_state': 'EFFECTIVE',
        'effective_cash_price': 850.25,
        'effective_credit_price': 920,
        'discount_start_date': '2026-11-01 10:00:00',
        'discount_end_date': null,
        'pos': {'pos_name': 'نقطة البيع الرئيسية'},
      });

      expect(model.discountId, 12);
      expect(model.posId, 34);
      expect(model.isEnabled, isTrue);
      expect(model.validityState, PackageDiscountValidityState.effective);
      expect(model.cashPrice, 850.25);
      expect(model.creditPrice, 920);
      expect(model.posName, 'نقطة البيع الرئيسية');
      expect(model.startDate, isNotNull);
      expect(model.endDate, isNull);
    });

    test('keeps disabled flag independent from lifecycle state', () {
      final model = PackagePosDiscountModel.fromJson({
        'discount_id': 13,
        'pos_id': 35,
        'status': false,
        'discount_cash': 10,
        'discount_credit': 5,
        'validity_state': 'DISABLED',
      });

      expect(model.isEnabled, isFalse);
      expect(model.validityState, PackageDiscountValidityState.disabled);
    });

    test('maps unsupported lifecycle values to unknown and tolerates optional fields', () {
      final model = PackagePosDiscountModel.fromJson({
        'discount_id': 14,
        'pos_id': 36,
        'status': true,
        'discount_cash': null,
        'discount_credit': 'invalid',
        'validity_state': 'UNEXPECTED',
        'discount_start_date': 'not-a-date',
        'effective_cash_price': 'not-a-number',
      });

      expect(model.validityState, PackageDiscountValidityState.unknown);
      expect(model.discountCash, 0);
      expect(model.discountCredit, 0);
      expect(model.startDate, isNull);
      expect(model.cashPrice, isNull);
      expect(model.creditPrice, isNull);
    });

    test('rejects missing required identifiers', () {
      expect(
        () => PackagePosDiscountModel.fromJson({
          'pos_id': 1,
          'status': true,
          'validity_state': 'EFFECTIVE',
        }),
        throwsFormatException,
      );
    });
  });
}
