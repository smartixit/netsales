import 'package:flutter/services.dart';

/// منسق إدخال لحصر الكمية المدخلة ضمن الحد الأقصى المسموح
class ProcurementMaxQuantityFormatter extends TextInputFormatter {
  const ProcurementMaxQuantityFormatter(this.maximum);

  final int maximum;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final value = int.tryParse(newValue.text);
    if (value == null || value <= maximum) return newValue;
    return oldValue;
  }
}
