import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/utils/voucher_sheet_calculator.dart';

void main() {
  group('VoucherSheetCalculator', () {
    test('splits an odd-sized sheet into ceiling first half and remainder', () {
      expect(VoucherSheetCalculator.halfSheetCards(51), 26);
      expect(VoucherSheetCalculator.remainingHalfSheetCards(51), 25);
    });

    test('converts full and half sheets into integer voucher counts', () {
      expect(VoucherSheetCalculator.cardsForSheets(0.5, 51), 26);
      expect(VoucherSheetCalculator.cardsForSheets(1, 51), 51);
      expect(VoucherSheetCalculator.cardsForSheets(1.5, 51), 77);
      expect(VoucherSheetCalculator.cardsForSheets(2.5, 51), 128);
    });

    test('rounds non-half fractions up without treating near-half as half', () {
      expect(VoucherSheetCalculator.cardsForSheets(0.25, 51), 13);
      expect(VoucherSheetCalculator.cardsForSheets(0.49, 51), 25);
      expect(VoucherSheetCalculator.cardsForSheets(0.51, 51), 27);
      expect(VoucherSheetCalculator.cardsForSheets(2.25, 51), 115);
    });

    test('returns zero for invalid quantities and invalid sheet sizes', () {
      expect(VoucherSheetCalculator.cardsForSheets(0, 51), 0);
      expect(VoucherSheetCalculator.cardsForSheets(-1, 51), 0);
      expect(VoucherSheetCalculator.cardsForSheets(double.nan, 51), 0);
      expect(VoucherSheetCalculator.cardsForSheets(double.infinity, 51), 0);
      expect(VoucherSheetCalculator.cardsForSheets(1, 0), 0);
      expect(VoucherSheetCalculator.halfSheetCards(0), 0);
    });

    test('describes full sheets, half sheets, and remaining cards', () {
      expect(VoucherSheetCalculator.describe(26, 51), 'نصف ورقة');
      expect(VoucherSheetCalculator.describe(51, 51), 'ورقة واحدة');
      expect(VoucherSheetCalculator.describe(77, 51), 'ورقة ونصف');
      expect(VoucherSheetCalculator.describe(55, 51), 'ورقة واحدة و 4 كرت');
    });

    test('generates wholesale presets while retaining free-form quantities', () {
      final presets = VoucherSheetCalculator.getPresets(51);

      expect(presets.map((preset) => preset.sheets).toList(), [
        0.5,
        1,
        1.5,
        2,
        3,
        5,
        10,
        20,
      ]);
      expect(presets.first.cards, 26);
      expect(presets.last.cards, 1020);
    });
  });
}
