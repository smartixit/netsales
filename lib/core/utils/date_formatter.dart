import 'package:hijri/hijri_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart'
    hide TextDirection; // مهم: منع تعارض TextDirection مع Flutter

/// ============================================================
/// DateFormatter (نسخة intl)
/// تنسيق شامل للتاريخ والوقت
/// الميلادي عبر intl + الهجري عبر حزمة hijri
///
/// ============================================================

enum DateLang { ar, en }

class DateFormatter {
  DateFormatter._();

  static final DateFormatter instance = DateFormatter._();

  static bool _initialized = false;

  /// تهيئة كسولة تلقائية عند الحاجة الأولى دون الحاجة لتعطيل إقلاع التطبيق في main()
  static void ensureInitialized() {
    if (_initialized) return;
    _initialized = true;
    initializeDateFormatting('ar', null);
    initializeDateFormatting('en', null);
  }

  /// اجعلها true إذا أردت الأرقام المشرقية (١٢٣) في المخرجات العربية
  static bool arabicIndicDigits = false;

  static String _locale(DateLang lang) {
    ensureInitialized();
    return lang == DateLang.ar ? 'ar' : 'en';
  }

  /// تحويل ٠١٢٣٤٥٦٧٨٩ إلى 0123456789 (intl بالعربية يُخرج أرقاماً مشرقية)
  static String _digits(String s) {
    if (arabicIndicDigits) return s;
    const arD = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    for (var i = 0; i < arD.length; i++) {
      s = s.replaceAll(arD[i], '$i');
    }
    return s;
  }

  // ---------- التاريخ الميلادي ----------

  /// 17/07/2026 — أرقام فقط (تعمل حتى بدون init).
  ///
  /// لا يعتمد على بيانات الـ locale (يعمل حتى في السياقات خارج التطبيق مثل
  /// تصدير PDF أو الاختبارات) — يلجأ لتنسيق يدوي إذا لم تُهيّأ بيانات اللغة.
  static String date(DateTime d, {String separator = '/'}) {
    String two(int n) => n.toString().padLeft(2, '0');
    final manual = '${two(d.day)}$separator${two(d.month)}$separator${d.year}';
    try {
      return DateFormat('dd${separator}MM${separator}yyyy', 'en').format(d);
    } catch (_) {
      return manual;
    }
  }

  /// 2026-07-17 — صيغة API
  static String iso(DateTime d) => DateFormat('yyyy-MM-dd', 'en').format(d);

  /// الخميس / Thursday
  static String dayName(DateTime d, {DateLang lang = DateLang.ar}) =>
      _digits(DateFormat('EEEE', _locale(lang)).format(d));

  /// يوليو / July
  static String monthName(DateTime d, {DateLang lang = DateLang.ar}) =>
      _digits(DateFormat('MMMM', _locale(lang)).format(d));

  /// الخميس 17 يوليو 2026
  static String fullDate(DateTime d, {DateLang lang = DateLang.ar}) =>
      _digits(DateFormat('EEEE d MMMM yyyy', _locale(lang)).format(d));

  /// 17 يوليو 2026
  static String longDate(DateTime d, {DateLang lang = DateLang.ar}) =>
      _digits(DateFormat('d MMMM yyyy', _locale(lang)).format(d));

  // ---------- الوقت ----------

  /// 02:30 م / 02:30 PM
  static String time(
    DateTime d, {
    DateLang lang = DateLang.ar,
    bool withSeconds = false,
  }) => _digits(
    DateFormat(withSeconds ? 'hh:mm:ss a' : 'hh:mm a', _locale(lang)).format(d),
  );

  /// 14:30 — نظام 24 ساعة
  static String time24(DateTime d, {bool withSeconds = false}) =>
      DateFormat(withSeconds ? 'HH:mm:ss' : 'HH:mm', 'en').format(d);

  /// الخميس 17 يوليو 2026 - 02:30 م
  static String dateTime(DateTime d, {DateLang lang = DateLang.ar}) =>
      '${fullDate(d, lang: lang)} - ${time(d, lang: lang)}';

  /// 2026-07-17 14:30:00 — صيغة API
  static String apiDateTime(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    final h = d.hour.toString().padLeft(2, '0');
    final min = d.minute.toString().padLeft(2, '0');
    final s = d.second.toString().padLeft(2, '0');
    return '$y-$m-$day $h:$min:$s';
  }

  // ---------- تنسيق مخصص ----------

  /// تنسيق حر بأي نمط intl — مثال:
  /// format(now, 'EEEE dd MMMM yyyy | hh:mm a')
  /// النتيجة: الخميس 17 يوليو 2026 | 02:30 م
  static String format(
    DateTime d,
    String pattern, {
    DateLang lang = DateLang.ar,
  }) => _digits(DateFormat(pattern, _locale(lang)).format(d));

  // ---------- التاريخ الهجري ----------

  static const List<String> _arHijriMonths = [
    'محرم',
    'صفر',
    'ربيع الأول',
    'ربيع الآخر',
    'جمادى الأولى',
    'جمادى الآخرة',
    'رجب',
    'شعبان',
    'رمضان',
    'شوال',
    'ذو القعدة',
    'ذو الحجة',
  ];
  static const List<String> _enHijriMonths = [
    'Muharram',
    'Safar',
    'Rabi al-Awwal',
    'Rabi al-Thani',
    'Jumada al-Ula',
    'Jumada al-Akhirah',
    'Rajab',
    'Shaban',
    'Ramadan',
    'Shawwal',
    'Dhul-Qidah',
    'Dhul-Hijjah',
  ];

  /// الخميس 2 صفر 1448هـ
  static String hijri(
    DateTime d, {
    DateLang lang = DateLang.ar,
    bool withDayName = true,
  }) {
    final h = HijriCalendar.fromDate(d);
    final mName = lang == DateLang.ar
        ? _arHijriMonths[h.hMonth - 1]
        : _enHijriMonths[h.hMonth - 1];
    final suffix = lang == DateLang.ar ? 'هـ' : 'AH';
    final base = '${h.hDay} $mName ${h.hYear}$suffix';
    return withDayName ? '${dayName(d, lang: lang)} $base' : base;
  }

  /// 02/02/1448
  static String hijriShort(DateTime d, {String separator = '/'}) {
    final h = HijriCalendar.fromDate(d);
    final dd = h.hDay.toString().padLeft(2, '0');
    final mm = h.hMonth.toString().padLeft(2, '0');
    return '$dd$separator$mm$separator${h.hYear}';
  }

  /// اسم الشهر الهجري فقط: صفر
  static String hijriMonthName(DateTime d, {DateLang lang = DateLang.ar}) {
    final h = HijriCalendar.fromDate(d);
    return lang == DateLang.ar
        ? _arHijriMonths[h.hMonth - 1]
        : _enHijriMonths[h.hMonth - 1];
  }

  /// ميلادي + هجري معاً: 17 يوليو 2026م - 2 صفر 1448هـ
  static String combined(DateTime d, {DateLang lang = DateLang.ar}) {
    final gSuffix = lang == DateLang.ar ? 'م' : '';
    return '${longDate(d, lang: lang)}$gSuffix - '
        '${hijri(d, lang: lang, withDayName: false)}';
  }

  /// تحويل تاريخ هجري إلى ميلادي
  static DateTime hijriToGregorian(int hYear, int hMonth, int hDay) =>
      HijriCalendar().hijriToGregorian(hYear, hMonth, hDay);

  // ---------- الوقت النسبي (غير موجود في intl — يدوي) ----------

  /// منذ 5 دقائق / 3 hours ago
  static String timeAgo(DateTime d, {DateLang lang = DateLang.ar}) {
    final diff = DateTime.now().difference(d);
    if (diff.isNegative || diff.inSeconds < 60) {
      return lang == DateLang.ar ? 'الآن' : 'just now';
    }
    if (diff.inMinutes < 60) {
      return lang == DateLang.ar
          ? _arAgo(diff.inMinutes, 'دقيقة', 'دقيقتين', 'دقائق')
          : _enAgo(diff.inMinutes, 'minute');
    }
    if (diff.inHours < 24) {
      return lang == DateLang.ar
          ? _arAgo(diff.inHours, 'ساعة', 'ساعتين', 'ساعات')
          : _enAgo(diff.inHours, 'hour');
    }
    if (diff.inDays < 7) {
      return lang == DateLang.ar
          ? _arAgo(diff.inDays, 'يوم', 'يومين', 'أيام')
          : _enAgo(diff.inDays, 'day');
    }
    final weeks = diff.inDays ~/ 7;
    if (weeks < 5) {
      return lang == DateLang.ar
          ? _arAgo(weeks, 'أسبوع', 'أسبوعين', 'أسابيع')
          : _enAgo(weeks, 'week');
    }
    final months = diff.inDays ~/ 30;
    if (months < 12) {
      return lang == DateLang.ar
          ? _arAgo(months, 'شهر', 'شهرين', 'أشهر')
          : _enAgo(months, 'month');
    }
    final years = diff.inDays ~/ 365;
    return lang == DateLang.ar
        ? _arAgo(years, 'سنة', 'سنتين', 'سنوات')
        : _enAgo(years, 'year');
  }

  /// قواعد الجمع العربية: 1 مفرد، 2 مثنى، 3-10 جمع، 11+ مفرد
  static String _arAgo(int n, String one, String two, String few) {
    if (n == 1) return 'منذ $one';
    if (n == 2) return 'منذ $two';
    if (n >= 3 && n <= 10) return 'منذ $n $few';
    return 'منذ $n $one';
  }

  static String _enAgo(int n, String unit) =>
      n == 1 ? '1 $unit ago' : '$n ${unit}s ago';

  // ---------- الوقت المتبقي ----------

  /// متبقي 3 أيام / 3 days left
  static String remaining(DateTime future, {DateLang lang = DateLang.ar}) {
    final diff = future.difference(DateTime.now());
    if (diff.isNegative) return lang == DateLang.ar ? 'انتهى' : 'ended';
    if (diff.inMinutes < 60) {
      return lang == DateLang.ar
          ? 'متبقي ${diff.inMinutes} دقيقة'
          : '${diff.inMinutes} min left';
    }
    if (diff.inHours < 24) {
      return lang == DateLang.ar
          ? 'متبقي ${diff.inHours} ساعة'
          : '${diff.inHours} hours left';
    }
    return lang == DateLang.ar
        ? 'متبقي ${diff.inDays} يوم'
        : '${diff.inDays} days left';
  }

  // ---------- فحوصات ----------

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static bool isToday(DateTime d) => isSameDay(d, DateTime.now());

  static bool isYesterday(DateTime d) =>
      isSameDay(d, DateTime.now().subtract(const Duration(days: 1)));

  static bool isTomorrow(DateTime d) =>
      isSameDay(d, DateTime.now().add(const Duration(days: 1)));

  /// عدد الأيام بين تاريخين (بدون احتساب الوقت)
  static int daysBetween(DateTime from, DateTime to) {
    final a = DateTime(from.year, from.month, from.day);
    final b = DateTime(to.year, to.month, to.day);
    return b.difference(a).inDays;
  }

  // ---------- تنسيق ذكي (للمحادثات والقوائم) ----------

  /// اليوم → الوقت | أمس → «أمس» | خلال أسبوع → اسم اليوم | أقدم → التاريخ
  static String smart(DateTime d, {DateLang lang = DateLang.ar}) {
    if (isToday(d)) return time(d, lang: lang);
    if (isYesterday(d)) return lang == DateLang.ar ? 'أمس' : 'Yesterday';
    if (isTomorrow(d)) return lang == DateLang.ar ? 'غداً' : 'Tomorrow';
    final diff = DateTime.now().difference(d).inDays;
    if (diff > 0 && diff < 7) return dayName(d, lang: lang);
    return date(d);
  }

  // ---------- التحليل (Parsing) ----------

  /// يقبل: ISO 8601 أو yyyy-MM-dd أو dd/MM/yyyy أو dd-MM-yyyy
  /// أو Timestamp رقمي بالثواني/الميلي ثانية (Unixtime).
  static DateTime? tryParse(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;

    // رقم نقي: قد يكون Timestamp بالثواني (10 أرقام) أو الميلي ثانية (13 رقم).
    if (RegExp(r'^\d{1,16}$').hasMatch(trimmed)) {
      final asInt = int.tryParse(trimmed);
      if (asInt != null) {
        if (trimmed.length >= 13) {
          return DateTime.fromMillisecondsSinceEpoch(asInt);
        }
        if (trimmed.length >= 10) {
          return DateTime.fromMillisecondsSinceEpoch(asInt * 1000);
        }
        // أرقام أقصر (سنة مثل 2026) — لا نعتبرها timestamp.
      }
    }

    final iso = DateTime.tryParse(trimmed);
    if (iso != null) return iso;

    final parts = trimmed.split(RegExp(r'[/\-.]'));
    if (parts.length == 3) {
      final a = int.tryParse(parts[0]);
      final b = int.tryParse(parts[1]);
      final c = int.tryParse(parts[2]);
      if (a != null && b != null && c != null) {
        if (parts[0].length == 4) return DateTime(a, b, c); // yyyy/MM/dd
        if (parts[2].length == 4) return DateTime(c, b, a); // dd/MM/yyyy
      }
    }
    return null;
  }

  /// من Timestamp بالمللي ثانية أو بالثواني
  static DateTime fromMillis(int ms) => DateTime.fromMillisecondsSinceEpoch(ms);
  static DateTime fromSeconds(int s) =>
      DateTime.fromMillisecondsSinceEpoch(s * 1000);

  // ---------- أرقام عربية ----------

  /// تحويل 2026 → ٢٠٢٦
  static String toArabicDigits(String input) {
    const en = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const ar = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    for (var i = 0; i < en.length; i++) {
      input = input.replaceAll(en[i], ar[i]);
    }
    return input;
  }
}

// ============================================================
// Extensions
// ============================================================

extension DateTimeX on DateTime {
  String toDate() => DateFormatter.date(this);
  String toIso() => DateFormatter.iso(this);
  String toTime() => DateFormatter.time(this);
  String toTime24() => DateFormatter.time24(this);
  String toFullDate() => DateFormatter.fullDate(this);
  String toLongDate() => DateFormatter.longDate(this);
  String toDateTime() => DateFormatter.dateTime(this);
  String toHijri() => DateFormatter.hijri(this);
  String toHijriShort() => DateFormatter.hijriShort(this);
  String toTimeAgo() => DateFormatter.timeAgo(this);
  String toSmart() => DateFormatter.smart(this);
  String toApi() => DateFormatter.apiDateTime(this);
  String formatAs(String pattern) => DateFormatter.format(this, pattern);

  bool get isToday => DateFormatter.isToday(this);
  bool get isYesterday => DateFormatter.isYesterday(this);
  bool get isTomorrow => DateFormatter.isTomorrow(this);
}

extension NullableDateTimeX on DateTime? {
  /// إذا كان التاريخ null يعيد «—»
  String orDash(String Function(DateTime) formatter) =>
      this == null ? '—' : formatter(this!);
}

extension StringDateX on String {
  DateTime? toDateOrNull() => DateFormatter.tryParse(this);
}
