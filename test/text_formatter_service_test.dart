import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/utils/text_formatter.dart';

void main() {
  group('TextFormatter - Name Formats', () {
    test('twoNames extracts exactly first two names', () {
      expect(
        TextFormatter.twoNames('أحمد صالح محمد علي اليماني'),
        'أحمد صالح',
      );
      expect(TextFormatter.twoNames('محمد'), 'محمد');
      expect(TextFormatter.twoNames(''), '');
      expect(TextFormatter.twoNames(null, fallback: 'ضيف'), 'ضيف');
    });

    test('firstAndLast extracts first and last name correctly', () {
      expect(
        TextFormatter.firstAndLast('أحمد صالح محمد اليماني'),
        'أحمد اليماني',
      );
      expect(TextFormatter.firstAndLast('سالم'), 'سالم');
      expect(TextFormatter.firstAndLast(null, fallback: 'مجهول'), 'مجهول');
    });

    test('firstName and lastName extract respective parts', () {
      expect(
        TextFormatter.firstName('علي حسن العولقي'),
        'علي',
      );
      expect(
        TextFormatter.lastName('علي حسن العولقي'),
        'العولقي',
      );
      expect(
        TextFormatter.lastName('علي'),
        '',
      );
    });

    test('takeWords respects count limit and ellipsis', () {
      const text = 'شبكة الأمان للاتصالات وتقنية المعلومات الحديثة';
      expect(
        TextFormatter.takeWords(text, 3),
        'شبكة الأمان للاتصالات',
      );
      expect(
        TextFormatter.takeWords(text, 2, ellipsis: '...'),
        'شبكة الأمان...',
      );
    });
  });

  group('TextFormatter - Avatar Initials', () {
    test('avatarInitial extracts single uppercase or arabic letter', () {
      expect(TextFormatter.avatarInitial('أحمد صالح'), 'أ');
      expect(TextFormatter.avatarInitial('ibrahim ali'), 'I');
      expect(TextFormatter.avatarInitial(''), 'ن');
      expect(TextFormatter.avatarInitial(null, fallback: 'ش'), 'ش');
    });

    test('avatarInitials extracts two letters with space or joined', () {
      expect(
        TextFormatter.avatarInitials('أحمد صالح اليماني'),
        'أ ص',
      );
      expect(
        TextFormatter.avatarInitials('john doe', spaceBetween: false),
        'JD',
      );
      expect(
        TextFormatter.avatarInitials('وحيد'),
        'و',
      );
    });
  });

  group('TextFormatter - Truncation & Masking', () {
    test('truncate cuts text at maxLength with ellipsis', () {
      expect(
        TextFormatter.truncate('باقة كروت نت 500 ريال', 10),
        'باقة كروت …',
      );
      expect(
        TextFormatter.truncate('قصير', 10),
        'قصير',
      );
    });

    test('mask hides middle characters securely', () {
      expect(
        TextFormatter.mask('777123456', startVisible: 3, endVisible: 2),
        '777****56',
      );
      expect(
        TextFormatter.mask('12345', startVisible: 2, endVisible: 2),
        '12*45',
      );
    });
  });

  group('String Extensions', () {
    test('extension methods work cleanly on String and nullable types', () {
      const String fullName = 'خالد عبد الله المنصوري';
      expect(fullName.twoNames, 'خالد عبد');
      expect(fullName.avatarInitial(), 'خ');
      expect(fullName.avatarInitials(), 'خ ع');
      expect(fullName.takeWords(2), 'خالد عبد');
      expect(fullName.truncateTo(8), 'خالد عبد…');

      const String phone = '771234567';
      expect(phone.maskSecure(startVisible: 3, endVisible: 2), '771****67');
    });
  });
}
