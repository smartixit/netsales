/// ============================================================================
/// وحدة قياس حجم رصيد البيانات الرقمية (DataSizeUnit)
/// ============================================================================
/// تبدأ من أقل وحدة أساسية (البايت - Byte) المخزنة في قاعدة البيانات
/// وتتصاعد حتى التيرابايت لتغطية كافة متطلبات شبكات الإنترنت والاتصالات.
enum DataSizeUnit {
  bytes('بايت', 'B', 1),
  kilobytes('كيلوبايت', 'KB', 1024),
  megabytes('ميجابايت', 'MB', 1048576),
  gigabytes('جيجابايت', 'GB', 1073741824),
  terabytes('تيرابايت', 'TB', 1099511627776);

  final String label;
  final String symbol;
  final int byteFactor;

  const DataSizeUnit(this.label, this.symbol, this.byteFactor);

  /// تحويل القيمة من هذه الوحدة إلى القيمة المعيارية بالبايت (القاعدة الأدنى للتخزين)
  int toCanonicalBytes(num value) => (value * byteFactor).round();

  /// تحويل القيمة المعيارية بالبايت إلى هذه الوحدة
  double fromCanonicalBytes(num bytes) => bytes / byteFactor;

  /// تحديد الوحدة الأنسب والأكثر تعبيراً لقيمة بايت معينة تلقائياً
  static DataSizeUnit resolveBestUnit(num bytes) {
    if (bytes >= terabytes.byteFactor && bytes % gigabytes.byteFactor == 0) {
      return terabytes;
    }
    if (bytes >= gigabytes.byteFactor) {
      return gigabytes;
    }
    if (bytes >= megabytes.byteFactor) {
      return megabytes;
    }
    if (bytes >= kilobytes.byteFactor) {
      return kilobytes;
    }
    return megabytes;
  }
}

/// ============================================================================
/// وحدة قياس الفترات الزمنية الموحدة (TimeDurationUnit)
/// ============================================================================
/// توحد قياس وقت الاستخدام وفترة الصلاحية تحت معيار واحد.
/// تبدأ من أقل وحدة أساسية (الدقيقة - Minute) المخزنة في قاعدة البيانات
/// وتتصاعد حتى السنوات لتغطية كافة أنواع الباقات.
enum TimeDurationUnit {
  minutes('دقيقة', 'Min', 1),
  hours('ساعة', 'Hrs', 60),
  days('يوم', 'Days', 1440),
  weeks('أسبوع', 'Wks', 10080),
  months('شهر', 'Mo', 43200), // 30 يوماً
  years('سنة', 'Yr', 525600); // 365 يوماً

  final String label;
  final String symbol;
  final int minuteFactor;

  const TimeDurationUnit(this.label, this.symbol, this.minuteFactor);

  /// تحويل القيمة من هذه الوحدة إلى القيمة المعيارية بالدقائق (القاعدة الأدنى للتخزين)
  int toCanonicalMinutes(num value) => (value * minuteFactor).round();

  /// تحويل القيمة المعيارية بالدقائق إلى هذه الوحدة
  double fromCanonicalMinutes(num minutes) => minutes / minuteFactor;

  /// تحديد الوحدة الأنسب والأكثر تعبيراً لقيمة دقائق معينة تلقائياً
  static TimeDurationUnit resolveBestUnit(
    num minutes, {
    TimeDurationUnit defaultUnit = hours,
  }) {
    if (minutes <= 0) return defaultUnit;
    if (minutes >= years.minuteFactor && minutes % years.minuteFactor == 0) {
      return years;
    }
    if (minutes >= months.minuteFactor && minutes % months.minuteFactor == 0) {
      return months;
    }
    if (minutes >= weeks.minuteFactor && minutes % weeks.minuteFactor == 0) {
      return weeks;
    }
    if (minutes >= days.minuteFactor && minutes % days.minuteFactor == 0) {
      return days;
    }
    if (minutes >= hours.minuteFactor && minutes % hours.minuteFactor == 0) {
      return hours;
    }
    return minutes >= hours.minuteFactor ? hours : TimeDurationUnit.minutes;
  }
}

/// نتيجة تنسيق حجم البيانات، مع الاحتفاظ بالقيمة والوحدة منفصلتين للعرض.
class FormattedDataSize {
  final String value;
  final String unit;

  const FormattedDataSize({
    required this.value,
    required this.unit,
  });

  bool get hasUnit => unit.isNotEmpty;

  String get displayText => hasUnit ? '$value $unit' : value;
}

/// ============================================================================
/// مساعد تنسيق وتحويل المواصفات الفنية للباقات (PackageSpecFormatter)
/// ============================================================================
/// أداة هندسية شاملة ومكتملة، قابلة للاستخدام في أي مشروع برمجيات:
/// - تعتمد مبدأ التخزين السيادي في قاعدة البيانات بأقل وحدة قياس (Bytes للبايتات، و Minutes للزمن).
/// - تتولى التحويلات الرياضية بين الوحدات بدقة صفرية للأخطاء.
/// - توفر تنسيقاً لغوياً فصيحاً يدعم قواعد الإعراب والمثنى والجمع في اللغة العربية.
class PackageSpecFormatter {
  const PackageSpecFormatter._();

  // ──────────────────────────────────────────────────────────────────────────
  // 1. عمليات وتحويلات حجم البيانات (Data Size)
  // ──────────────────────────────────────────────────────────────────────────

  /// تحويل قيمة حجم البيانات بين أي وحدتين
  static double convertData(num value, DataSizeUnit from, DataSizeUnit to) {
    if (from == to) return value.toDouble();
    final canonicalBytes = value * from.byteFactor;
    return canonicalBytes / to.byteFactor;
  }

  /// تحويل القيمة المدخلة إلى بايت (القيمة الأدنى المخزنة في قاعدة البيانات)
  static int toCanonicalBytes(num value, DataSizeUnit unit) {
    return (value * unit.byteFactor).round();
  }

  /// تحويل القيمة بالبايت إلى الوحدة المطلوبة
  static double fromCanonicalBytes(num bytes, DataSizeUnit targetUnit) {
    return bytes / targetUnit.byteFactor;
  }

  /// تنسيق ذكي لحجم البيانات مع فصل القيمة عن الوحدة لدعم اختلاف أسلوب العرض.
  static FormattedDataSize formatDataParts(
    dynamic rawBytes, {
    String fallback = 'بلا رصيد محدد',
  }) {
    if (rawBytes == null) {
      return FormattedDataSize(value: fallback, unit: '');
    }

    final bytes = (rawBytes is num)
        ? rawBytes.toDouble()
        : (double.tryParse(rawBytes.toString()) ?? 0.0);

    if (bytes <= 0) {
      return FormattedDataSize(value: fallback, unit: '');
    }

    if (bytes >= DataSizeUnit.terabytes.byteFactor) {
      final tb = bytes / DataSizeUnit.terabytes.byteFactor;
      return FormattedDataSize(
        value: _formatNumber(tb),
        unit: 'تيرابايت',
      );
    }
    if (bytes >= DataSizeUnit.gigabytes.byteFactor) {
      final gb = bytes / DataSizeUnit.gigabytes.byteFactor;
      return FormattedDataSize(
        value: _formatNumber(gb),
        unit: 'جيجابايت',
      );
    }
    if (bytes >= DataSizeUnit.megabytes.byteFactor) {
      final mb = bytes / DataSizeUnit.megabytes.byteFactor;
      return FormattedDataSize(
        value: _formatNumber(mb),
        unit: 'ميجابايت',
      );
    }
    if (bytes >= DataSizeUnit.kilobytes.byteFactor) {
      final kb = bytes / DataSizeUnit.kilobytes.byteFactor;
      return FormattedDataSize(
        value: _formatNumber(kb),
        unit: 'كيلوبايت',
      );
    }

    return FormattedDataSize(
      value: bytes.toInt().toString(),
      unit: 'بايت',
    );
  }

  /// تنسيق نصي متوافق مع الاستخدامات الحالية التي تحتاج قيمة واحدة جاهزة للعرض.
  static String formatData(
    dynamic rawBytes, {
    String fallback = 'بلا رصيد محدد',
  }) {
    return formatDataParts(rawBytes, fallback: fallback).displayText;
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 2. عمليات وتحويلات الفترات الزمنية الموحدة (Duration)
  // ──────────────────────────────────────────────────────────────────────────

  /// تحويل مدة زمنية بين أي وحدتين
  static double convertDuration(
    num value,
    TimeDurationUnit from,
    TimeDurationUnit to,
  ) {
    if (from == to) return value.toDouble();
    final canonicalMinutes = value * from.minuteFactor;
    return canonicalMinutes / to.minuteFactor;
  }

  /// تحويل القيمة المدخلة إلى دقائق (القيمة الأدنى المخزنة في قاعدة البيانات)
  static int toCanonicalMinutes(num value, TimeDurationUnit unit) {
    return (value * unit.minuteFactor).round();
  }

  /// تحويل الدقائق إلى الوحدة المستهدفة
  static double fromCanonicalMinutes(num minutes, TimeDurationUnit targetUnit) {
    return minutes / targetUnit.minuteFactor;
  }

  /// تنسيق لغوي عربي فصيح ودقيق للمدد الزمنية بالدقائق
  static String formatDuration(
    dynamic rawMinutes, {
    String fallback = 'مفتوح',
  }) {
    if (rawMinutes == null) return fallback;
    final totalMinutes = (rawMinutes is num)
        ? rawMinutes.toDouble()
        : (double.tryParse(rawMinutes.toString()) ?? 0.0);

    if (totalMinutes <= 0) return fallback;

    // 1. السنوات
    if (totalMinutes >= TimeDurationUnit.years.minuteFactor &&
        totalMinutes % TimeDurationUnit.years.minuteFactor == 0) {
      final years = (totalMinutes / TimeDurationUnit.years.minuteFactor)
          .toInt();
      return _arabicQuantity(
        years,
        single: 'سنة',
        dual: 'سنتان',
        plural: 'سنوات',
        rule: 'سنة',
      );
    }

    // 2. الأشهر (30 يوماً = 43200 دقيقة)
    if (totalMinutes >= TimeDurationUnit.months.minuteFactor &&
        totalMinutes % TimeDurationUnit.months.minuteFactor == 0) {
      final months = (totalMinutes / TimeDurationUnit.months.minuteFactor)
          .toInt();
      return _arabicQuantity(
        months,
        single: 'شهر',
        dual: 'شهران',
        plural: 'أشهر',
        rule: 'شهراً',
      );
    }

    // 3. الأسابيع (7 أيام = 10080 دقيقة)
    if (totalMinutes >= TimeDurationUnit.weeks.minuteFactor &&
        totalMinutes % TimeDurationUnit.weeks.minuteFactor == 0) {
      final weeks = (totalMinutes / TimeDurationUnit.weeks.minuteFactor)
          .toInt();
      return _arabicQuantity(
        weeks,
        single: 'أسبوع',
        dual: 'أسبوعان',
        plural: 'أسابيع',
        rule: 'أسبوعاً',
      );
    }

    // 4. الأيام (24 ساعة = 1440 دقيقة)
    if (totalMinutes >= TimeDurationUnit.days.minuteFactor &&
        totalMinutes % TimeDurationUnit.days.minuteFactor == 0) {
      final days = (totalMinutes / TimeDurationUnit.days.minuteFactor).toInt();
      return _arabicQuantity(
        days,
        single: 'يوم',
        dual: 'يومان',
        plural: 'أيام',
        rule: 'يوماً',
      );
    }

    // 5. الساعات (60 دقيقة)
    if (totalMinutes >= TimeDurationUnit.hours.minuteFactor) {
      final hours = totalMinutes / TimeDurationUnit.hours.minuteFactor;
      if (hours % 1 == 0) {
        final h = hours.toInt();
        return _arabicQuantity(
          h,
          single: 'ساعة',
          dual: 'ساعتان',
          plural: 'ساعات',
          rule: 'ساعة',
        );
      }
      return '${_formatNumber(hours)} ساعة';
    }

    // 6. الدقائق
    final m = totalMinutes.toInt();
    return _arabicQuantity(
      m,
      single: 'دقيقة',
      dual: 'دقيقتان',
      plural: 'دقائق',
      rule: 'دقيقة',
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 3. دوال المعالجة المساعدة
  // ──────────────────────────────────────────────────────────────────────────

  /// تنسيق الأرقام العشرية والتخلص من الأصفار الزائدة مع دعم دقيق حتى خانتين عشريتين
  static String _formatNumber(double num) {
    if (num % 1 == 0) return num.toInt().toString();
    return num.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
  }

  /// صياغة المعدود العربي الصحيح (المفرد، المثنى، الجمع، وتمييز الأعداد 11-99)
  static String _arabicQuantity(
    int count, {
    required String single,
    required String dual,
    required String plural,
    required String rule,
  }) {
    if (count == 1) return single;
    if (count == 2) return dual;
    if (count >= 3 && count <= 10) return '$count $plural';
    return '$count $rule';
  }
}
