import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/utils/package_spec_formatter.dart';

void main() {
  group('DataSizeUnit.resolveBestUnit', () {
    test('selects bytes for balances below one kilobyte', () {
      expect(DataSizeUnit.resolveBestUnit(512), DataSizeUnit.bytes);
      expect(DataSizeUnit.resolveBestUnit(0), DataSizeUnit.bytes);
    });

    test('selects the largest useful unit even for fractional terabytes', () {
      expect(
        DataSizeUnit.resolveBestUnit(
          DataSizeUnit.terabytes.byteFactor +
              512 * DataSizeUnit.megabytes.byteFactor,
        ),
        DataSizeUnit.terabytes,
      );
      expect(
        DataSizeUnit.resolveBestUnit(DataSizeUnit.kilobytes.byteFactor),
        DataSizeUnit.kilobytes,
      );
    });
  });

  group('TimeDurationUnit.resolveBestUnit', () {
    test('preserves exact fractional values in the largest useful unit', () {
      expect(
        TimeDurationUnit.resolveBestUnit(2160),
        TimeDurationUnit.days,
      );
      expect(
        TimeDurationUnit.resolveBestUnit(90),
        TimeDurationUnit.hours,
      );
      expect(
        TimeDurationUnit.resolveBestUnit(10080),
        TimeDurationUnit.weeks,
      );
    });

    test('falls back to minutes when a larger unit loses precision', () {
      expect(
        TimeDurationUnit.resolveBestUnit(61),
        TimeDurationUnit.minutes,
      );
    });
  });

  group('PackageSpecFormatter.formatDataParts', () {
    test('returns formatted value and unit separately for gigabytes', () {
      final parts = PackageSpecFormatter.formatDataParts(
        1.5 * DataSizeUnit.gigabytes.byteFactor,
      );

      expect(parts.value, '1.5');
      expect(parts.unit, 'جيجابايت');
      expect(parts.displayText, '1.5 جيجابايت');
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
    });
  });
}
