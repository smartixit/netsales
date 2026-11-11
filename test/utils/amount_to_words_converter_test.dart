import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/utils/amount_to_words_converter.dart';

void main() {
  group('AmountToWordsConverter Unit Tests', () {
    test('Zero and empty amounts return empty string', () {
      expect(AmountToWordsConverter.convert(0), isEmpty);
      expect(AmountToWordsConverter.convert('0'), isEmpty);
      expect(AmountToWordsConverter.convert('0.00'), isEmpty);
      expect(AmountToWordsConverter.convert(null), isEmpty);
      expect(AmountToWordsConverter.convert(''), isEmpty);
    });

    test('Ones and tens conversion', () {
      expect(
        AmountToWordsConverter.convert(1, currencyCode: 'YER'),
        'فقط واحد ريال يمني لا غير',
      );
      expect(
        AmountToWordsConverter.convert(2, currencyCode: 'YER'),
        'فقط اثنان ريالان يمنيان لا غير',
      );
      expect(
        AmountToWordsConverter.convert(5, currencyCode: 'YER'),
        'فقط خمسة ريالات يمنية لا غير',
      );
      expect(
        AmountToWordsConverter.convert(15, currencyCode: 'YER'),
        'فقط خمسة عشر ريال يمني لا غير',
      );
      expect(
        AmountToWordsConverter.convert(25, currencyCode: 'YER'),
        'فقط خمسة وعشرون ريال يمني لا غير',
      );
    });

    test('Hundreds and Thousands conversion', () {
      expect(
        AmountToWordsConverter.convert(100, currencyCode: 'SAR'),
        'فقط مائة ريال سعودي لا غير',
      );
      expect(
        AmountToWordsConverter.convert(1000, currencyCode: 'YER'),
        'فقط ألف ريال يمني لا غير',
      );
      expect(
        AmountToWordsConverter.convert(2000, currencyCode: 'YER'),
        'فقط ألفان ريال يمني لا غير',
      );
      expect(
        AmountToWordsConverter.convert(5000, currencyCode: 'YER'),
        'فقط خمسة آلاف ريال يمني لا غير',
      );
      expect(
        AmountToWordsConverter.convert(15450, currencyCode: 'YER'),
        'فقط خمسة عشر ألف وأربعمائة وخمسون ريال يمني لا غير',
      );
    });

    test('Millions and Billions conversion', () {
      expect(
        AmountToWordsConverter.convert(1000000, currencyCode: 'YER'),
        'فقط مليون ريال يمني لا غير',
      );
      expect(
        AmountToWordsConverter.convert(2500000, currencyCode: 'YER'),
        'فقط مليونان وخمسمائة ألف ريال يمني لا غير',
      );
      expect(
        AmountToWordsConverter.convert(1000000000, currencyCode: 'USD'),
        'فقط مليار دولار أمريكي لا غير',
      );
    });

    test('Decimal fractions conversion', () {
      expect(
        AmountToWordsConverter.convert(150.50, currencyCode: 'SAR'),
        'فقط مائة وخمسون ريال سعودي وخمسون هللة لا غير',
      );
      expect(
        AmountToWordsConverter.convert(1.05, currencyCode: 'USD'),
        'فقط واحد دولار أمريكي وخمسة سنتات لا غير',
      );
    });

    test('Default currency is YER (ريال يمني)', () {
      expect(
        AmountToWordsConverter.convert(1),
        'فقط واحد ريال يمني لا غير',
      );
      expect(
        AmountToWordsConverter.convert(100),
        'فقط مائة ريال يمني لا غير',
      );
    });

    test('String formatted inputs with commas', () {
      expect(
        AmountToWordsConverter.convert('1,250,000', currencyCode: 'YER'),
        'فقط مليون ومائتان وخمسون ألف ريال يمني لا غير',
      );
    });
  });
}

