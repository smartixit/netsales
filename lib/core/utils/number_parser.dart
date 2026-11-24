
import 'package:netsales/core/utils/amount_formatter.dart';

class NumberParser {
  const NumberParser._();

  static int? toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();

    final normalized = _normalize(value.toString());
    if (normalized.isEmpty) return null;

    return int.tryParse(normalized) ?? double.tryParse(normalized)?.toInt();
  }

  static int toIntOrZero(dynamic value) {
    return toInt(value) ?? 0;
  }

  static int toIntOrDefault(dynamic value, int defaultValue) {
    return toInt(value) ?? defaultValue;
  }

  static double? toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();

    final normalized = _normalize(value.toString());
    if (normalized.isEmpty) return null;

    return double.tryParse(normalized);
  }

  static double toDoubleOrZero(dynamic value) {
    return toDouble(value) ?? 0;
  }

  static double toDoubleOrDefault(dynamic value, double defaultValue) {
    return toDouble(value) ?? defaultValue;
  }

  static num? toNum(dynamic value) {
    if (value == null) return null;
    if (value is num) return value;

    final normalized = _normalize(value.toString());
    if (normalized.isEmpty) return null;

    return num.tryParse(normalized);
  }

  static String formatPrice(double price) {
    if (price == price.roundToDouble()) return price.toInt().toString();
    return AmountFormatter.formatValue(price);
  }

  static String cleanValue(String? value, {required String fallback}) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty || trimmed == '0') return fallback;
    return trimmed;
  }

  static String _normalize(String value) {
    return value
        .trim()
        .replaceAll(',', '')
        .replaceAll('٠', '0')
        .replaceAll('١', '1')
        .replaceAll('٢', '2')
        .replaceAll('٣', '3')
        .replaceAll('٤', '4')
        .replaceAll('٥', '5')
        .replaceAll('٦', '6')
        .replaceAll('٧', '7')
        .replaceAll('٨', '8')
        .replaceAll('٩', '9')
        .replaceAll('۰', '0')
        .replaceAll('۱', '1')
        .replaceAll('۲', '2')
        .replaceAll('۳', '3')
        .replaceAll('۴', '4')
        .replaceAll('۵', '5')
        .replaceAll('۶', '6')
        .replaceAll('۷', '7')
        .replaceAll('۸', '8')
        .replaceAll('۹', '9');
  }
}
