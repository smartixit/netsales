import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/utils/voucher_sheet_calculator.dart';

void main() {
  group('VoucherSheetCalculator - Odd Sheet Size (51 cards per sheet)', () {
    const sheetSize = 51;

    test('halfSheetCards returns 26 for 51', () {
      expect(VoucherSheetCalculator.halfSheetCards(sheetSize), 26);
      expect(VoucherSheetCalculator.remainingHalfSheetCards(sheetSize), 25);
    });

    test('cardsForSheets calculates exact counts for sheets and half sheets', () {
      // Half sheet: 26 cards
      expect(VoucherSheetCalculator.cardsForSheets(0.5, sheetSize), 26);
      // 1 full sheet: 51 cards
      expect(VoucherSheetCalculator.cardsForSheets(1.0, sheetSize), 51);
      // 1.5 sheets: 51 + 26 = 77 cards
      expect(VoucherSheetCalculator.cardsForSheets(1.5, sheetSize), 77);
      // 2 full sheets: 102 cards
      expect(VoucherSheetCalculator.cardsForSheets(2.0, sheetSize), 102);
      // 2.5 sheets: 102 + 26 = 128 cards
      expect(VoucherSheetCalculator.cardsForSheets(2.5, sheetSize), 128);
      // 3 full sheets: 153 cards
      expect(VoucherSheetCalculator.cardsForSheets(3.0, sheetSize), 153);
    });

    test('describe generates fluent Arabic descriptions', () {
      expect(VoucherSheetCalculator.describe(26, sheetSize), 'نصف ورقة');
      expect(VoucherSheetCalculator.describe(51, sheetSize), 'ورقة واحدة');
      expect(VoucherSheetCalculator.describe(77, sheetSize), 'ورقة ونصف');
      expect(VoucherSheetCalculator.describe(102, sheetSize), 'ورقتان');
      expect(VoucherSheetCalculator.describe(128, sheetSize), 'ورقتان ونصف');
      expect(VoucherSheetCalculator.describe(153, sheetSize), '3 ورقات');
      expect(VoucherSheetCalculator.describe(204, sheetSize), '4 ورقات');
      expect(VoucherSheetCalculator.describe(55, sheetSize), 'ورقة واحدة و 4 كرت');
    });

    test('getPresets returns 5 standard quick presets', () {
      final presets = VoucherSheetCalculator.getPresets(sheetSize);
      expect(presets.length, 5);
      expect(presets[0].cards, 26);
      expect(presets[0].sheets, 0.5);
      expect(presets[1].cards, 51);
      expect(presets[1].sheets, 1.0);
      expect(presets[2].cards, 77);
      expect(presets[2].sheets, 1.5);
      expect(presets[3].cards, 102);
      expect(presets[3].sheets, 2.0);
      expect(presets[4].cards, 153);
      expect(presets[4].sheets, 3.0);
    });
  });

  group('VoucherSheetCalculator - Even Sheet Size (50 cards per sheet)', () {
    const sheetSize = 50;

    test('halfSheetCards returns 25 for 50', () {
      expect(VoucherSheetCalculator.halfSheetCards(sheetSize), 25);
      expect(VoucherSheetCalculator.remainingHalfSheetCards(sheetSize), 25);
    });

    test('cardsForSheets calculates exact counts', () {
      expect(VoucherSheetCalculator.cardsForSheets(0.5, sheetSize), 25);
      expect(VoucherSheetCalculator.cardsForSheets(1.0, sheetSize), 50);
      expect(VoucherSheetCalculator.cardsForSheets(1.5, sheetSize), 75);
      expect(VoucherSheetCalculator.cardsForSheets(2.0, sheetSize), 100);
    });
  });

  group('VoucherSheetCalculator - Edge Cases', () {
    test('handles 0 or negative quantities safely', () {
      expect(VoucherSheetCalculator.cardsForSheets(0, 51), 0);
      expect(VoucherSheetCalculator.cardsForSheets(-1, 51), 0);
      expect(VoucherSheetCalculator.halfSheetCards(0), 0);
      expect(VoucherSheetCalculator.describe(0, 51), '');
      expect(VoucherSheetCalculator.getPresets(0), isEmpty);
    });
  });
}
