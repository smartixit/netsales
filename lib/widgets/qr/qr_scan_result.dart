import 'package:flutter/material.dart';

/// نتيجة فحص مسح رمز الاستجابة السريعة (Domain-Agnostic QR Scan Result)
///
/// كائن بيانات قياسي ومجرد تماماً من أي منطق أعمال أو سياق تجاري،
/// يمثل القراءة الرقمية الناتجة عن الكاميرا أو معرض الصور.
class QrScanResult {
  /// القيمة النصية الخام المقروءة من الرمز
  final String rawValue;

  /// صيغة الباركود الممسوح
  final String format;

  /// وقت إتمام المسح
  final DateTime scannedAt;

  /// إحداثيات زوايا الرمز في إطار الكاميرا إن وُجدت
  final List<Offset>? corners;

  const QrScanResult({
    required this.rawValue,
    required this.format,
    required this.scannedAt,
    this.corners,
  });

  /// التحقق من أن النتيجة فارغة
  bool get isEmpty => rawValue.trim().isEmpty;

  /// التحقق من أن النتيجة تحتوي على بيانات حقيقية
  bool get isNotEmpty => rawValue.trim().isNotEmpty;

  @override
  String toString() =>
      'QrScanResult(rawValue: $rawValue, format: $format, scannedAt: $scannedAt)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QrScanResult &&
          runtimeType == other.runtimeType &&
          rawValue == other.rawValue &&
          format == other.format &&
          scannedAt == other.scannedAt;

  @override
  int get hashCode => Object.hash(rawValue, format, scannedAt);
}
