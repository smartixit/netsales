import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// ============================================================
/// AmountFormatter
/// أدوات تنسيق المبالغ المالية بفاصل الآلاف (,) والفاصلة العشرية (.)
/// مبني على مكتبة intl — مكتمل وقابل لإعادة الاستخدام في أي مشروع.
///
///   AmountFormatter.format('1234567.5');        // -> '1,234,567.5'
///   AmountFormatter.format('١٢٣٤٥٦٧.٥٠');       // -> '1,234,567.50'
///   AmountFormatter.clean('1,500.75');          // -> '1500.75'
/// ============================================================
class AmountFormatter {
  const AmountFormatter._();

  static const String defaultThousandsSeparator = ',';
  static const String defaultDecimalSeparator = '.';

  static final NumberFormat _groupFormat = NumberFormat('#,##0', 'en');

  /// ينظّف النص الخام: يحوّل الأرقام العربية/الفارسية إلى إنجليزية،
  /// ويزيل كل ما ليس رقماً أو فاصلة عشرية واحدة، مع الحفاظ على الإشارة السالبة.
  static String clean(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return '';
    final isNegative = trimmed.startsWith('-');
    final buffer = StringBuffer();
    var decimalSeen = false;
    for (final char in trimmed.split('')) {
      final normalized = _toDigit(char);
      if (normalized == null) continue;
      if (normalized == defaultDecimalSeparator) {
        if (decimalSeen) continue;
        decimalSeen = true;
        if (buffer.isEmpty) buffer.write('0');
      }
      buffer.write(normalized);
    }
    final cleaned = buffer.toString();
    if (cleaned.isEmpty) return '';
    return isNegative ? '-$cleaned' : cleaned;
  }

  /// ينسّق نص المبلغ: يجمّع الجزء الصحيح بفاصل الآلاف ويقصر الخانات
  /// العشرية على [decimalPlaces] كحد أقصى مع الحفاظ على الإشارة السالبة. الدالة idempotent.
  static String format(
    String raw, {
    int decimalPlaces = 2,
    String thousandsSeparator = defaultThousandsSeparator,
  }) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return '';
    final isNegative = trimmed.startsWith('-');
    final absRaw = isNegative ? trimmed.substring(1) : trimmed;
    final cleaned = clean(absRaw);
    if (cleaned.isEmpty) return '';

    final parts = cleaned.split(defaultDecimalSeparator);
    final groupedInt = _groupDigits(parts.first, thousandsSeparator);
    if (decimalPlaces <= 0 || parts.length == 1) {
      return isNegative ? '-$groupedInt' : groupedInt;
    }

    final fraction = parts[1].length > decimalPlaces
        ? parts[1].substring(0, decimalPlaces)
        : parts[1];
    if (fraction.isEmpty) {
      final res = '$groupedInt$defaultDecimalSeparator';
      return isNegative ? '-$res' : res;
    }

    final res = '$groupedInt$defaultDecimalSeparator$fraction';
    return isNegative ? '-$res' : res;
  }

  /// هل النص منسّق بالفعل بنفس مخرجات [format]؟
  static bool isFormatted(
    String raw, {
    int decimalPlaces = 2,
    String thousandsSeparator = defaultThousandsSeparator,
  }) {
    return format(
          raw,
          decimalPlaces: decimalPlaces,
          thousandsSeparator: thousandsSeparator,
        ) ==
        raw;
  }

  /// ينسّق قيمة رقمية للعرض مع فاصل الآلاف وعدد ثابت من الخانات
  /// العشرية، مع المحافظة على الإشارة السالبة.
  ///
  ///   AmountFormatter.formatValue(1234567.5);   // -> '1,234,567.50'
  ///   AmountFormatter.formatValue(-1234, decimalPlaces: 0); // -> '-1,234'
  static String formatValue(
    num value, {
    int decimalPlaces = 2,
    String thousandsSeparator = defaultThousandsSeparator,
  }) {
    final fixed = value.toStringAsFixed(decimalPlaces);
    final isNegative = fixed.startsWith('-');
    final abs = isNegative ? fixed.substring(1) : fixed;
    final formatted = format(
      abs,
      decimalPlaces: decimalPlaces,
      thousandsSeparator: thousandsSeparator,
    );
    return isNegative ? '-$formatted' : formatted;
  }

  static String _groupDigits(String digits, String separator) {
    if (digits.isEmpty) return digits;

    final parsed = int.tryParse(digits);
    if (parsed != null) return _groupFormat.format(parsed);

    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(separator);
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  static String? _toDigit(String char) {
    switch (char) {
      case '0':
      case '٠':
      case '۰':
        return '0';
      case '1':
      case '١':
      case '۱':
        return '1';
      case '2':
      case '٢':
      case '۲':
        return '2';
      case '3':
      case '٣':
      case '۳':
        return '3';
      case '4':
      case '٤':
      case '۴':
        return '4';
      case '5':
      case '٥':
      case '۵':
        return '5';
      case '6':
      case '٦':
      case '۶':
        return '6';
      case '7':
      case '٧':
      case '۷':
        return '7';
      case '8':
      case '٨':
      case '۸':
        return '8';
      case '9':
      case '٩':
      case '۹':
        return '9';
      case defaultDecimalSeparator:
        return defaultDecimalSeparator;
      default:
        return null;
    }
  }
}

/// TextInputFormatter يضيف فاصل الآلاف تلقائياً أثناء الكتابة في حقول
/// المبالغ مع الحفاظ على موضع المؤشر.
class AmountTextInputFormatter extends TextInputFormatter {
  const AmountTextInputFormatter({
    this.decimalPlaces = 2,
    this.thousandsSeparator = AmountFormatter.defaultThousandsSeparator,
  });

  final int decimalPlaces;

  final String thousandsSeparator;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final valueCharsBeforeCursor = _valueCharCount(
      newValue.text,
      newValue.selection.start,
    );
    final formatted = AmountFormatter.format(
      newValue.text,
      decimalPlaces: decimalPlaces,
      thousandsSeparator: thousandsSeparator,
    );
    return TextEditingValue(
      text: formatted,
      selection: _selectionForValueCharCount(formatted, valueCharsBeforeCursor),
    );
  }

  /// عدد "محارف القيمة" قبل موضع [offset] — الأرقام (إنجليزية/عربية/فارسية)
  /// والنقطة العشرية. فاصل الآلاف غير محسوب لأنه يُضاف/يُحذف تلقائياً.
  static int _valueCharCount(String text, int offset) {
    final end = offset.clamp(0, text.length);
    var count = 0;
    for (var i = 0; i < end; i++) {
      if (_isValueChar(text.codeUnitAt(i))) count++;
    }
    return count;
  }

  /// موضع المؤشر بعد عدد "محارف القيمة" المطلوب في النص المنسّق.
  static TextSelection _selectionForValueCharCount(String text, int count) {
    var seen = 0;
    for (var i = 0; i < text.length; i++) {
      if (_isValueChar(text.codeUnitAt(i))) seen++;
      if (seen >= count) return TextSelection.collapsed(offset: i + 1);
    }
    return TextSelection.collapsed(offset: text.length);
  }

  /// حرف قيمة: رقم أو النقطة العشرية.
  static bool _isValueChar(int codeUnit) =>
      _isAsciiDigit(codeUnit) ||
      (codeUnit >= 0x0660 && codeUnit <= 0x0669) || // ٠-٩ Arabic-Indic
      (codeUnit >= 0x06F0 && codeUnit <= 0x06F9) || // ۰-۹ Extended Arabic-Indic
      codeUnit == 0x2E; // '.'

  static bool _isAsciiDigit(int codeUnit) =>
      codeUnit >= 0x30 && codeUnit <= 0x39;
}
