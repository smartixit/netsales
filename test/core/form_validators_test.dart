import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/utils/form_validators.dart';

void main() {
  group('FormValidators positiveIntegerValidator & integerValidator Tests', () {
    test('positiveIntegerValidator validates positive integers and bounds', () {
      final validator = FormValidators.positiveIntegerValidator(
        fieldName: 'الكمية',
        min: 1,
        max: 1000,
      );

      // Invalid cases
      expect(validator(null), equals('الكمية مطلوب.'));
      expect(validator(''), equals('الكمية مطلوب.'));
      expect(validator('   '), equals('الكمية مطلوب.'));
      expect(validator('0'), equals('الكمية يجب أن تكون 1 على الأقل'));
      expect(validator('-1'), equals('الكمية يجب أن تكون 1 على الأقل'));
      expect(validator('abc'), equals('الكمية يجب أن تكون عدداً صحيحاً'));
      expect(validator('12.5'), equals('الكمية يجب أن تكون عدداً صحيحاً'));
      expect(validator('1001'), equals('الكمية يجب ألا تتجاوز 1000'));

      // Valid cases
      expect(validator('1'), isNull);
      expect(validator('51'), isNull);
      expect(validator('1000'), isNull);
      expect(validator(' 51 '), isNull); // trimmed
      expect(validator('1,000'), isNull); // commas cleaned
    });

    test('integerValidator validates with optional min and max bounds', () {
      final boundedValidator = FormValidators.integerValidator(
        fieldName: 'الرقم',
        minValue: 10,
        maxValue: 50,
      );

      expect(boundedValidator('9'), equals('الرقم يجب ان يكون أكبر من أو يساوي 10'));
      expect(boundedValidator('51'), equals('الرقم يجب ان يكون أقل من أو يساوي 50'));
      expect(boundedValidator('25'), isNull);
    });
  });
}

