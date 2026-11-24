import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/utils/package_spec_formatter.dart';

void main() {
  group('PackageSpecFormatter.formatDataParts', () {
    test('returns formatted value and unit separately for gigabytes', () {
      final parts = PackageSpecFormatter.formatDataParts(
        1.5 * DataSizeUnit.gigabytes.byteFactor,
      );

      expect(parts.value, '1.5');
      expect(parts.unit, 'جيجابايت');
      expect(parts.displayText, '1.5 جيجابايت');
      expect(
        PackageSpecFormatter.formatData(
          1.5 * DataSizeUnit.gigabytes.byteFactor,
        ),
        parts.displayText,
      );
    });

    test('preserves the existing kilobyte formatting', () {
      final parts = PackageSpecFormatter.formatDataParts(1536);

      expect(parts.value, '1.5');
      expect(parts.unit, 'كيلوبايت');
      expect(parts.displayText, '1.5 كيلوبايت');
    });

    test('keeps byte values as a numeric value and Arabic unit', () {
      final parts = PackageSpecFormatter.formatDataParts(256);

      expect(parts.value, '256');
      expect(parts.unit, 'بايت');
      expect(parts.displayText, '256 بايت');
    });

    test('returns fallback text without a separate unit', () {
      final parts = PackageSpecFormatter.formatDataParts(null);

      expect(parts.value, 'بلا رصيد محدد');
      expect(parts.unit, isEmpty);
      expect(parts.displayText, 'بلا رصيد محدد');
      expect(PackageSpecFormatter.formatData(0), 'بلا رصيد محدد');
    });
  });
}
