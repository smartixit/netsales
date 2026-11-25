import 'package:flutter/material.dart';

/// محلل الألوان لهوية كروت وباقات الإنترنت (Package Color Resolver)
class ColorResolver {
  const ColorResolver._();

  /// تحليل اللون من كود الـ Hex النصي بأمان مع توفير لون احتياطي
  static Color resolve(String? hexCode, Color fallback) {
    if (hexCode == null || hexCode.trim().isEmpty) return fallback;

    var clean = hexCode.trim();
    if (clean.startsWith('#')) {
      clean = clean.substring(1);
    }
    if (clean.toLowerCase().startsWith('0x')) {
      clean = clean.substring(2);
    }

    if (clean.length == 6) {
      clean = 'FF$clean';
    } else if (clean.length != 8) {
      return fallback;
    }

    if (!RegExp(r'^[0-9a-fA-F]{8}$').hasMatch(clean)) {
      return fallback;
    }

    final value = int.tryParse(clean, radix: 16);
    return value == null ? fallback : Color(value);
  }
}
