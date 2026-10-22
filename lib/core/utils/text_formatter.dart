import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

/// ============================================================================
/// أداة معالجة واختزال وتنسيق النصوص والأسماء (TextFormatter Utility)
/// ============================================================================
/// أداة نفعية مركزية (Pure Stateless Utility) مبنية بدوال نقية خالية من الحالة
/// لمعالجة واختزال النصوص، استخراج أجزاء الأسماء، توليد رموز الأفاتار،
/// وقص وحجب النصوص الحساسة عبر كافة شاشات ونماذج النظام.
class TextFormatter {
  const TextFormatter._();

  /// استخراج أول كلمتين من الاسم (الاسم الأول والثاني فقط).
  ///
  /// مثال:
  /// - 'أحمد صالح اليماني' -> 'أحمد صالح'
  /// - 'محمد' -> 'محمد'
  /// - null أو '' -> [fallback]
  static String twoNames(String? name, {String fallback = ''}) {
    return takeWords(name, 2, fallback: fallback);
  }

  /// استخراج الاسم الأول والأخير فقط من الاسم الكامل.
  ///
  /// مثال:
  /// - 'أحمد صالح محمد اليماني' -> 'أحمد اليماني'
  /// - 'سالم' -> 'سالم'
  static String firstAndLast(String? name, {String fallback = ''}) {
    if (name == null) return fallback;
    final trimmed = name.trim();
    if (trimmed.isEmpty || trimmed == 'المستخدم') return fallback;

    final parts = _splitWords(trimmed);
    if (parts.isEmpty) return fallback;
    if (parts.length == 1) return parts.first;

    return '${parts.first} ${parts.last}';
  }

  /// استخراج الاسم الأول فقط.
  static String firstName(String? name, {String fallback = ''}) {
    if (name == null) return fallback;
    final trimmed = name.trim();
    if (trimmed.isEmpty || trimmed == 'المستخدم') return fallback;

    final parts = _splitWords(trimmed);
    return parts.isNotEmpty ? parts.first : fallback;
  }

  /// استخراج الاسم الأخير فقط (العائلة / اللقب).
  static String lastName(String? name, {String fallback = ''}) {
    if (name == null) return fallback;
    final trimmed = name.trim();
    if (trimmed.isEmpty || trimmed == 'المستخدم') return fallback;

    final parts = _splitWords(trimmed);
    return parts.length > 1 ? parts.last : fallback;
  }

  /// اختزال النص بعدد محدد من الكلمات الأولى.
  ///
  /// مثال:
  /// - takeWords('شبكة الأمان للاتصالات وتقنية المعلومات', 3) -> 'شبكة الأمان للاتصالات'
  static String takeWords(
    String? text,
    int count, {
    String fallback = '',
    String ellipsis = '',
  }) {
    if (text == null) return fallback;
    final trimmed = text.trim();
    if (trimmed.isEmpty || trimmed == 'المستخدم') return fallback;

    final parts = _splitWords(trimmed);
    if (parts.isEmpty) return fallback;
    if (parts.length <= count) return parts.join(' ');

    final result = parts.take(count).join(' ');
    return ellipsis.isNotEmpty ? '$result$ellipsis' : result;
  }

  /// استخراج حرف واحد بارز لعرضه داخل الأفاتار الشخصي الدائري.
  ///
  /// يتعامل بذكاء مع الحروف العربية والإنجليزية.
  /// مثال:
  /// - 'أحمد صالح' -> 'أ'
  /// - 'ibrahim' -> 'I'
  /// - null أو '' -> [fallback] (الافتراضي: 'ن')
  static String avatarInitial(String? name, {String fallback = 'ن'}) {
    if (name == null) return fallback;
    final trimmed = name.trim();
    if (trimmed.isEmpty) return fallback;

    final parts = _splitWords(trimmed);
    if (parts.isEmpty) return fallback;

    final firstChar = parts.first.characters.first;
    return _normalizeInitial(firstChar);
  }

  /// استخراج حرفين أوليين للأفاتار (حرف من الاسم الأول وحرف من الثاني).
  ///
  /// مثال:
  /// - 'أحمد صالح' -> 'أ ص'
  /// - 'John Doe' -> 'JD'
  /// - 'نقطة بيع النور' -> 'ن ب'
  static String avatarInitials(
    String? name, {
    int maxChars = 2,
    bool spaceBetween = true,
    String fallback = 'نت',
  }) {
    if (name == null) return fallback;
    final trimmed = name.trim();
    if (trimmed.isEmpty) return fallback;

    final parts = _splitWords(trimmed);
    if (parts.isEmpty) return fallback;

    if (parts.length == 1) {
      return _normalizeInitial(parts.first.characters.first);
    }

    final selected = parts.take(maxChars).map((part) {
      final char = part.characters.first;
      return _normalizeInitial(char);
    }).toList();

    return selected.join(spaceBetween ? ' ' : '');
  }

  /// قص النص عند حد معين من الأحرف مع إضافة نقاط الاختزال.
  ///
  /// مثال:
  /// - truncate('فاتورة مبيعات كروت باقة 1000 ريال', 15) -> 'فاتورة مبيعات ك…'
  static String truncate(
    String? text,
    int maxLength, {
    String ellipsis = '…',
    String fallback = '',
  }) {
    if (text == null) return fallback;
    final trimmed = text.trim();
    if (trimmed.length <= maxLength) return trimmed;
    if (maxLength <= 0) return '';

    return '${trimmed.characters.take(maxLength).string}$ellipsis';
  }

  /// حجب جزء من النص لحماية البيانات الحساسة (مثل أرقام الهواتف أو الكروت).
  ///
  /// مثال:
  /// - mask('777123456', startVisible: 3, endVisible: 2) -> '777****56'
  static String mask(
    String? text, {
    int startVisible = 3,
    int endVisible = 2,
    String maskChar = '*',
  }) {
    if (text == null || text.isEmpty) return '';
    if (text.length <= startVisible + endVisible) return text;

    final start = text.substring(0, startVisible);
    final end = text.substring(text.length - endVisible);
    final maskLength = text.length - (startVisible + endVisible);
    final masked = maskChar * maskLength;

    return '$start$masked$end';
  }

  /// تقسيم النص إلى كلمات نقية مع تجاهل المسافات الزائدة
  static List<String> _splitWords(String text) {
    return text.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  }

  /// توحيد وتحسين الحرف الأولي للأفاتار
  static String _normalizeInitial(String char) {
    if (char.isEmpty) return '';
    return char.toUpperCase();
  }
}

/// ============================================================================
/// ملحقات برمجية (Extensions) للاستخدام المباشر والسلس على أي String
/// ============================================================================
extension TextFormatterExtensions on String? {
  /// أول كلمتين من الاسم
  String get twoNames => TextFormatter.twoNames(this);

  /// الاسم الأول والأخير فقط
  String get firstAndLastName => TextFormatter.firstAndLast(this);

  /// الاسم الأول فقط
  String get firstName => TextFormatter.firstName(this);

  /// الاسم الأخير فقط
  String get lastName => TextFormatter.lastName(this);

  /// حرف واحد بارز للأفاتار
  String avatarInitial({String fallback = 'ن'}) =>
      TextFormatter.avatarInitial(this, fallback: fallback);

  /// حرفان أوليان للأفاتار
  String avatarInitials({
    int maxChars = 2,
    bool spaceBetween = true,
    String fallback = 'نت',
  }) =>
      TextFormatter.avatarInitials(
        this,
        maxChars: maxChars,
        spaceBetween: spaceBetween,
        fallback: fallback,
      );

  /// اختزال بعدد الكلمات
  String takeWords(int count, {String fallback = '', String ellipsis = ''}) =>
      TextFormatter.takeWords(
        this,
        count,
        fallback: fallback,
        ellipsis: ellipsis,
      );

  /// قص النص بطول محدد
  String truncateTo(
    int maxLength, {
    String ellipsis = '…',
    String fallback = '',
  }) =>
      TextFormatter.truncate(
        this,
        maxLength,
        ellipsis: ellipsis,
        fallback: fallback,
      );

  /// حجب البيانات الحساسة
  String maskSecure({
    int startVisible = 3,
    int endVisible = 2,
    String maskChar = '*',
  }) =>
      TextFormatter.mask(
        this,
        startVisible: startVisible,
        endVisible: endVisible,
        maskChar: maskChar,
      );
}

/// ملحق التفاعل مع GetX RxString
extension RxTextFormatterExtensions on RxString {
  String get twoNames => TextFormatter.twoNames(value);
  String get firstAndLastName => TextFormatter.firstAndLast(value);
  String get firstName => TextFormatter.firstName(value);
}
