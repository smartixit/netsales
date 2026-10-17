import 'package:get/get.dart';

/// أداة مركزية موحدة لمعالجة وتنسيق الأسماء واقتطاع أجزائها
/// في كل شاشات وتقارير التطبيق لمنع تكرار الكود.
class NameFormatter {
  const NameFormatter._();

  /// اقتطاع الاسم الأول والأخير من الاسم الكامل (سلسلة نصية عادية).
  ///
  /// - إذا كان الاسم كلمة واحدة يعيده كما هو.
  /// - إذا كان فارغاً أو 'المستخدم' يعيد [fallback].
  /// - إذا كان أكثر من اسم يدمج الأول والأخير فقط.
  static String firstAndLast(String? name, {String fallback = ''}) {
    if (name == null) return fallback;
    final trimmed = name.trim();
    if (trimmed.isEmpty || trimmed == 'المستخدم') return fallback;

    final parts = trimmed
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return fallback;
    if (parts.length == 1) return parts.first;

    return '${parts.first} ${parts.last}';
  }

  /// اقتطاع الاسم الأول والأخير كـ [RxString] متفاعل مع GetX.
  static RxString firstAndLastRx(RxString userName, {String fallback = ''}) {
    final formatted = firstAndLast(userName.value, fallback: fallback);
    return formatted.obs;
  }

  /// اقتطاع الاسم الأول فقط.
  static String firstName(String? name, {String fallback = ''}) {
    if (name == null) return fallback;
    final trimmed = name.trim();
    if (trimmed.isEmpty || trimmed == 'المستخدم') return fallback;

    final parts = trimmed
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    return parts.isNotEmpty ? parts.first : fallback;
  }

  /// اقتطاع الاسم الأخير فقط (إن وُجد أكثر من اسم).
  static String lastName(String? name, {String fallback = ''}) {
    if (name == null) return fallback;
    final trimmed = name.trim();
    if (trimmed.isEmpty || trimmed == 'المستخدم') return fallback;

    final parts = trimmed
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    return parts.length > 1 ? parts.last : fallback;
  }

  /// اختصار الاسم بعدد محدد من الكلمات (الافتراضي كلمتان).
  static String shortName(
    String? name, {
    int maxWords = 2,
    String fallback = '',
  }) {
    if (name == null) return fallback;
    final trimmed = name.trim();
    if (trimmed.isEmpty || trimmed == 'المستخدم') return fallback;

    final parts = trimmed
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return fallback;
    return parts.take(maxWords).join(' ');
  }

  /// استخراج الحروف الأولى للأفاتار والرموز الشخصية.
  static String initials(
    String? name, {
    int maxChars = 2,
    String fallback = '?',
  }) {
    if (name == null) return fallback;
    final trimmed = name.trim();
    if (trimmed.isEmpty) return fallback;

    final parts = trimmed
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return fallback;
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length.clamp(1, maxChars));
    }
    return parts.take(maxChars).map((p) => p.isNotEmpty ? p[0] : '').join();
  }
}

/// ملحق (Extension) لتسهيل استدعاء دوال التنسيق مباشرة على أي String أو RxString.
extension NameFormatterExtension on String? {
  String get firstAndLastName => NameFormatter.firstAndLast(this);
  String get firstName => NameFormatter.firstName(this);
  String get lastName => NameFormatter.lastName(this);
  String shortName({int maxWords = 2, String fallback = ''}) =>
      NameFormatter.shortName(this, maxWords: maxWords, fallback: fallback);
  String initials({int maxChars = 2, String fallback = '?'}) =>
      NameFormatter.initials(this, maxChars: maxChars, fallback: fallback);
}

extension RxNameFormatterExtension on RxString {
  RxString get firstAndLastNameRx => NameFormatter.firstAndLastRx(this);
}
