/// وحدات قياس حجم رصيد البيانات
enum DataUnit {
  mb('ميجابايت', 'MB', 1.0),
  gb('جيجابايت', 'GB', 1024.0);

  final String label;
  final String symbol;
  final double mbFactor;

  const DataUnit(this.label, this.symbol, this.mbFactor);
}

/// وحدات قياس وقت الاستخدام
enum UptimeUnit {
  minutes('دقيقة', 'Min', 1.0),
  hours('ساعة', 'Hrs', 60.0),
  days('يوم', 'Days', 1440.0);

  final String label;
  final String symbol;
  final double minuteFactor;

  const UptimeUnit(this.label, this.symbol, this.minuteFactor);
}

/// وحدات قياس فترة الصلاحية
enum ValidityUnit {
  hours('ساعة', 'Hrs', 1.0),
  days('يوم', 'Days', 24.0),
  weeks('أسبوع', 'Wks', 168.0),
  months('شهر (30 يوم)', 'Mo', 720.0);

  final String label;
  final String symbol;
  final double hourFactor;

  const ValidityUnit(this.label, this.symbol, this.hourFactor);
}

/// ============================================================================
/// مساعد تنسيق وتحويل المواصفات الفنية للباقات (PackageSpecFormatter)
/// ============================================================================
/// يعزل منطق التحويلات والتنسيق الرياضي تماماً عن طبقة العرض (UI Layer)
/// لضمان الالتزام بقواعد الحوكمة ونظافة الكود.
class PackageSpecFormatter {
  PackageSpecFormatter._();

  // --------------------------------------------------------------------------
  // 1. تحويلات وتنسيق حجم الرصيد (Data Balance)
  // --------------------------------------------------------------------------

  /// تحويل قيمة حجم البيانات بين وحدتين
  static double convertData(double value, DataUnit from, DataUnit to) {
    if (from == to) return value;
    final inMb = value * from.mbFactor;
    return inMb / to.mbFactor;
  }

  /// تنسيق حجم الرصيد للعرض الذكي في الواجهات (مثال: 5 جيجابايت أو 512 ميجابايت)
  static String formatBalance(num balanceMb) {
    if (balanceMb <= 0) return 'بلا رصيد محدد';
    final mb = balanceMb.toDouble();

    if (mb >= 1024 && (mb % 1024 == 0 || mb >= 2048)) {
      final gb = mb / 1024.0;
      final formatted = gb % 1 == 0
          ? gb.toInt().toString()
          : gb.toStringAsFixed(1);
      return '$formatted جيجابايت';
    }

    final formatted = mb % 1 == 0
        ? mb.toInt().toString()
        : mb.toStringAsFixed(1);
    return '$formatted ميجابايت';
  }

  // --------------------------------------------------------------------------
  // 2. تحويلات وتنسيق وقت الاستخدام (Uptime)
  // --------------------------------------------------------------------------

  /// تحويل وقت الاستخدام بين وحدتين
  static double convertUptime(double value, UptimeUnit from, UptimeUnit to) {
    if (from == to) return value;
    final inMinutes = value * from.minuteFactor;
    return inMinutes / to.minuteFactor;
  }

  /// تنسيق وقت الاستخدام للعرض الذكي (مثال: 2 ساعة أو 45 دقيقة أو 3 أيام)
  static String formatUptime(dynamic rawUptime) {
    if (rawUptime == null) return 'مفتوح';
    final totalMinutes = double.tryParse(rawUptime.toString()) ?? 0;
    if (totalMinutes <= 0) return 'مفتوح';

    if (totalMinutes >= 1440 && totalMinutes % 1440 == 0) {
      final days = (totalMinutes / 1440).toInt();
      return '$days ${days == 1
          ? "يوم"
          : days == 2
          ? "يومان"
          : "أيام"}';
    }

    if (totalMinutes >= 60) {
      final hours = totalMinutes / 60;
      if (hours % 1 == 0) {
        final h = hours.toInt();
        return '$h ${h == 1
            ? "ساعة"
            : h == 2
            ? "ساعتان"
            : "ساعات"}';
      }
      return '${hours.toStringAsFixed(1)} ساعة';
    }

    return '${totalMinutes.toInt()} دقيقة';
  }

  // --------------------------------------------------------------------------
  // 3. تحويلات وتنسيق مدة الصلاحية (Validity)
  // --------------------------------------------------------------------------

  /// تحويل فترة الصلاحية بين وحدتين
  static double convertValidity(
    double value,
    ValidityUnit from,
    ValidityUnit to,
  ) {
    if (from == to) return value;
    final inHours = value * from.hourFactor;
    return inHours / to.hourFactor;
  }

  /// تنسيق فترة الصلاحية للعرض الذكي (مثال: 30 يوم أو 24 ساعة أو أسبوعان)
  static String formatValidity(dynamic rawValidity) {
    if (rawValidity == null) return 'غير محدود';
    final totalHours = double.tryParse(rawValidity.toString()) ?? 0;
    if (totalHours <= 0) return 'غير محدود';

    if (totalHours >= 720 && totalHours % 720 == 0) {
      final months = (totalHours / 720).toInt();
      return '$months ${months == 1
          ? "شهر"
          : months == 2
          ? "شهران"
          : "أشهر"}';
    }

    if (totalHours >= 168 && totalHours % 168 == 0) {
      final weeks = (totalHours / 168).toInt();
      return '$weeks ${weeks == 1
          ? "أسبوع"
          : weeks == 2
          ? "أسبوعان"
          : "أسابيع"}';
    }

    if (totalHours >= 24) {
      final days = totalHours / 24;
      if (days % 1 == 0) {
        final d = days.toInt();
        return '$d ${d == 1
            ? "يوم"
            : d == 2
            ? "يومان"
            : "أيام"}';
      }
      return '${days.toStringAsFixed(1)} يوم';
    }

    return '${totalHours.toInt()} ساعة';
  }
}
