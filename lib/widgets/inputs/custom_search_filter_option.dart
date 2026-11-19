import 'package:flutter/material.dart';

/// خيار تصفية عام مستقل لاستخدامه في مكوّن البحث والفلترة الموحد.
class CustomSearchFilterOption<T> {
  const CustomSearchFilterOption({
    required this.label,
    required this.value,
    this.icon,
  });

  /// النص المعروض للخيار في شيت الفلترة
  final String label;

  /// القيمة البرمجية الممثلة للخيار (null يمثل عادة "الكل")
  final T? value;

  /// أيقونة اختيارية معبرة عن خيار الفلترة
  final IconData? icon;
}
