/// إعدادات تفقيط وتحويل المبلغ إلى كلمات مقروءة (Tafqeet Currency Config)
class CurrencyWordsConfig {
  /// اسم العملة المفرد المذكر/المؤنث (مثال: ريال، دولار، ليرة)
  final String singular;

  /// اسم العملة بالمثنى (مثال: ريالان، دولاران)
  final String dual;

  /// اسم العملة بالجمع 3 إلى 10 (مثال: ريالات، دولارات)
  final String plural;

  /// الوحدة الكسرية بالمفرد (مثال: فلس، هللة، سنت)
  final String fractionSingular;

  /// الوحدة الكسرية بالمثنى (مثال: فلسان، هللتان، سنتان)
  final String fractionDual;

  /// الوحدة الكسرية بالجمع (مثال: فلوس، هللات، سنتات)
  final String fractionPlural;

  /// عدد الخانات العشرية المعتمدة للكسر (افتراضياً 2، مثل الهللات والسنتات)
  final int fractionDecimals;

  const CurrencyWordsConfig({
    required this.singular,
    required this.dual,
    required this.plural,
    required this.fractionSingular,
    required this.fractionDual,
    required this.fractionPlural,
    this.fractionDecimals = 2,
  });

  /// الريال اليمني (YER)
  static const CurrencyWordsConfig yer = CurrencyWordsConfig(
    singular: 'ريال يمني',
    dual: 'ريالان يمنيان',
    plural: 'ريالات يمنية',
    fractionSingular: 'فلس',
    fractionDual: 'فلسان',
    fractionPlural: 'فلوس',
  );

  /// الريال السعودي (SAR)
  static const CurrencyWordsConfig sar = CurrencyWordsConfig(
    singular: 'ريال سعودي',
    dual: 'ريالان سعوديان',
    plural: 'ريالات سعودية',
    fractionSingular: 'هللة',
    fractionDual: 'هللتان',
    fractionPlural: 'هللات',
  );

  /// الدولار الأمريكي (USD)
  static const CurrencyWordsConfig usd = CurrencyWordsConfig(
    singular: 'دولار أمريكي',
    dual: 'دولاران أمريكيان',
    plural: 'دولارات أمريكية',
    fractionSingular: 'سنت',
    fractionDual: 'سنتان',
    fractionPlural: 'سنتات',
  );

  /// العملة الافتراضية العامة لنظام NetSales (ريال يمني)
  static const CurrencyWordsConfig defaultCurrency = yer;

  /// استنتاج الإعداد المناسب بناءً على رمز العملة
  static CurrencyWordsConfig fromCode(String? code) {
    if (code == null || code.trim().isEmpty) return defaultCurrency;
    final normalized = code.trim().toUpperCase();
    switch (normalized) {
      case 'YER':
      case 'ريال يمني':
      case 'ر.ي':
      case 'ريال':
        return yer;
      case 'SAR':
      case 'ريال سعودي':
      case 'ر.س':
        return sar;
      case 'USD':
      case 'دولار':
      case '\$':
        return usd;
      default:
        return defaultCurrency;
    }
  }
}

/// ==============================================================================
/// AmountToWordsConverter
/// أداة نقية (Pure Dart Utility) لتحويل المبالغ والأرقام المالية إلى كلمات ونصوص
/// عربية فصيحة ومقروءة قانونياً (تفقيط Tafqeet) متوافقة مع الأنظمة المالية والمصرفية.
/// ==============================================================================
class AmountToWordsConverter {
  const AmountToWordsConverter._();

  static const List<String> _ones = [
    '',
    'واحد',
    'اثنان',
    'ثلاثة',
    'أربعة',
    'خمسة',
    'ستة',
    'سبعة',
    'ثمانية',
    'تسعة',
    'عشرة',
    'أحد عشر',
    'اثنا عشر',
    'ثلاثة عشر',
    'أربعة عشر',
    'خمسة عشر',
    'ستة عشر',
    'سبعة عشر',
    'ثمانية عشر',
    'تسعة عشر',
  ];

  static const List<String> _tens = [
    '',
    '',
    'عشرون',
    'ثلاثون',
    'أربعون',
    'خمسون',
    'ستون',
    'سبعون',
    'ثمانون',
    'تسعون',
  ];

  static const List<String> _hundreds = [
    '',
    'مائة',
    'مائتان',
    'ثلاثمائة',
    'أربعمائة',
    'خمسمائة',
    'ستمائة',
    'سبعمائة',
    'ثمانمائة',
    'تسعمائة',
  ];

  /// تحويل القيمة الرقمية أو النصية إلى تفقيط عربي مالي مع العملة
  static String convert(
    dynamic amount, {
    CurrencyWordsConfig? currency,
    String? currencyCode,
    String prefix = 'فقط',
    String suffix = 'لا غير',
    bool includeCurrency = true,
  }) {
    if (amount == null) return '';

    double numericValue;
    if (amount is num) {
      numericValue = amount.toDouble();
    } else if (amount is String) {
      final sanitized = amount.replaceAll(',', '').trim();
      if (sanitized.isEmpty) return '';
      final parsed = double.tryParse(sanitized);
      if (parsed == null) return '';
      numericValue = parsed;
    } else {
      return '';
    }

    if (numericValue == 0) return '';

    final isNegative = numericValue < 0;
    numericValue = numericValue.abs();

    final config = currency ?? CurrencyWordsConfig.fromCode(currencyCode);

    final intPart = numericValue.floor();
    // استخراج الكسر بالتقريب
    final multiplier = _getMultiplier(config.fractionDecimals);
    final decimalPart = ((numericValue - intPart) * multiplier).round();

    final buffer = StringBuffer();

    if (prefix.isNotEmpty) {
      buffer.write('$prefix ');
    }

    if (isNegative) {
      buffer.write('سالب ');
    }

    // 1. معالجة الجزء الصحيح
    if (intPart > 0) {
      buffer.write(_convertInteger(intPart));
      if (includeCurrency) {
        buffer.write(' ');
        buffer.write(_resolveCurrencyLabel(intPart, config, isFraction: false));
      }
    }

    // 2. معالجة الجزء الكسري
    if (decimalPart > 0) {
      if (intPart > 0) {
        buffer.write(' و');
      }
      buffer.write(_convertInteger(decimalPart));
      if (includeCurrency) {
        buffer.write(' ');
        buffer.write(_resolveCurrencyLabel(decimalPart, config, isFraction: true));
      }
    }

    if (suffix.isNotEmpty) {
      buffer.write(' $suffix');
    }

    return buffer.toString().trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// تحويل رقم صحيح إلى كلمات عربية فصيحة
  static String _convertInteger(int number) {
    if (number == 0) return 'صفر';
    if (number < 0) return 'سالب ${_convertInteger(-number)}';

    final parts = <String>[];

    // ترليونات (10^12)
    final trillions = (number / 1000000000000).floor();
    final remainderTrillions = number % 1000000000000;
    if (trillions > 0) {
      parts.add(_formatScaleGroup(trillions, 'ترليون', 'ترليونان', 'ترليونات'));
    }

    // مليارات (10^9)
    final billions = (remainderTrillions / 1000000000).floor();
    final remainderBillions = remainderTrillions % 1000000000;
    if (billions > 0) {
      parts.add(_formatScaleGroup(billions, 'مليار', 'ملياران', 'مليارات'));
    }

    // ملايين (10^6)
    final millions = (remainderBillions / 1000000).floor();
    final remainderMillions = remainderBillions % 1000000;
    if (millions > 0) {
      parts.add(_formatScaleGroup(millions, 'مليون', 'مليونان', 'ملايين'));
    }

    // آلاف (10^3)
    final thousands = (remainderMillions / 1000).floor();
    final remainderThousands = remainderMillions % 1000;
    if (thousands > 0) {
      parts.add(_formatScaleGroup(thousands, 'ألف', 'ألفان', 'آلاف'));
    }

    // المئات والآحاد والعشرات (< 1000)
    if (remainderThousands > 0) {
      parts.add(_convertGroupUnder1000(remainderThousands));
    }

    return parts.join(' و');
  }

  /// صياغة الفئات العددية الكبرى (آلاف، ملايين، مليارات، ترليونات)
  static String _formatScaleGroup(
    int count,
    String singular,
    String dual,
    String plural,
  ) {
    if (count == 1) return singular;
    if (count == 2) return dual;
    if (count >= 3 && count <= 10) {
      return '${_convertGroupUnder1000(count)} $plural';
    }
    return '${_convertGroupUnder1000(count)} $singular';
  }

  /// تحويل أي مجموعة مكونة من 3 خانات (أقل من 1000)
  static String _convertGroupUnder1000(int number) {
    if (number == 0) return '';
    final parts = <String>[];

    final hundreds = number ~/ 100;
    final remainder = number % 100;

    if (hundreds > 0) {
      parts.add(_hundreds[hundreds]);
    }

    if (remainder > 0) {
      if (remainder < 20) {
        parts.add(_ones[remainder]);
      } else {
        final ones = remainder % 10;
        final tens = remainder ~/ 10;
        if (ones > 0) {
          parts.add('${_ones[ones]} و${_tens[tens]}');
        } else {
          parts.add(_tens[tens]);
        }
      }
    }

    return parts.join(' و');
  }

  /// تحديد اسم وتصريف العملة وفقاً للعدد
  static String _resolveCurrencyLabel(
    int value,
    CurrencyWordsConfig config, {
    required bool isFraction,
  }) {
    final singular = isFraction ? config.fractionSingular : config.singular;
    final dual = isFraction ? config.fractionDual : config.dual;
    final plural = isFraction ? config.fractionPlural : config.plural;

    if (value == 1) return singular;
    if (value == 2) return dual;
    if (value >= 3 && value <= 10) return plural;
    return singular;
  }

  static int _getMultiplier(int decimals) {
    var m = 1;
    for (var i = 0; i < decimals; i++) {
      m *= 10;
    }
    return m;
  }
}

