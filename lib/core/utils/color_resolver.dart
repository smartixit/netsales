import 'package:flutter/material.dart';

/// محلل الألوان لهوية كروت وباقات الإنترنت (Package Color Resolver)
class ColorResolver {
  const ColorResolver._();

  /// تحليل اللون من كود الـ Hex النصي بأمان مع توفير لون احتياطي
  static Color resolve(String? hexCode, Color fallback) {
    if (hexCode != null && hexCode.trim().isNotEmpty) {
      try {
        final clean = hexCode.replaceAll('#', '').trim();
        final val = int.parse(
          clean.length == 6 ? 'FF$clean' : clean,
          radix: 16,
        );
        return Color(val);
      } catch (_) {}
    }
    return fallback;
  }
}
