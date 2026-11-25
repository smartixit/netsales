import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/utils/color_resolver.dart';

void main() {
  group('ColorResolver.resolve', () {
    const fallback = Color(0xFF607D8B);

    test('resolves the ARGB hex format emitted by CustomColorPicker', () {
      expect(
        ColorResolver.resolve('0xFF0D7A5F', fallback),
        const Color(0xFF0D7A5F),
      );
    });

    test('resolves six-digit and hash-prefixed hex values', () {
      expect(
        ColorResolver.resolve('0D7A5F', fallback),
        const Color(0xFF0D7A5F),
      );
      expect(
        ColorResolver.resolve('#1976D2', fallback),
        const Color(0xFF1976D2),
      );
    });

    test('keeps alpha from eight-digit values', () {
      expect(
        ColorResolver.resolve('#800D7A5F', fallback),
        const Color(0x800D7A5F),
      );
    });

    test('uses fallback for malformed values', () {
      expect(ColorResolver.resolve('not-a-color', fallback), fallback);
      expect(ColorResolver.resolve('0x12345', fallback), fallback);
      expect(ColorResolver.resolve(null, fallback), fallback);
    });
  });
}
