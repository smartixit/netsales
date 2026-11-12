import 'dart:typed_data';

import 'package:document_engine/document_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Stable identifiers', () {
    test('accept valid identifiers and preserve value equality', () {
      expect(DocumentId('doc:2026-001'), DocumentId('doc:2026-001'));
      expect(
        TemplateId('sales.invoice.standard').value,
        'sales.invoice.standard',
      );
    });

    test('rejects empty, padded, oversized, and unsupported characters', () {
      for (final value in ['', ' padded', 'bad value', 'a/b', 'a' * 129]) {
        expect(() => DocumentTypeId(value), throwsArgumentError);
      }
    });
  });

  group('TemplateVersion', () {
    test('compares major, minor, and patch numerically', () {
      final versions = [
        TemplateVersion(major: 1, minor: 10, patch: 0),
        TemplateVersion(major: 1, minor: 2, patch: 10),
        TemplateVersion(major: 1, minor: 2, patch: 2),
        TemplateVersion(major: 2, minor: 0, patch: 0),
      ]..sort();

      expect(versions.map((version) => version.toString()), [
        '1.2.2',
        '1.2.10',
        '1.10.0',
        '2.0.0',
      ]);
    });

    test('rejects negative components', () {
      expect(
        () => TemplateVersion(major: -1, minor: 0, patch: 0),
        throwsArgumentError,
      );
    });
  });

  group('DocumentBranding', () {
    test('defensively copies injected logo and font assets', () {
      final logo = Uint8List.fromList([
        0x89,
        0x50,
        0x4E,
        0x47,
        0x0D,
        0x0A,
        0x1A,
        0x0A,
      ]);
      final font = Uint8List.fromList([0x00, 0x01, 0x00, 0x00, 0x01]);
      final branding = DocumentBranding(
        organizationName: 'NetSales',
        tagline: 'Business network',
        primaryColor: '123456',
        logoBytes: logo,
        fonts: {DocumentFontRole.body: font},
      );

      logo[0] = 0;
      font[1] = 0;
      expect(branding.logoBytes!.first, 0x89);
      expect(branding.fontBytes(DocumentFontRole.body)![1], 0x01);
      final exposedLogo = branding.logoBytes!;
      exposedLogo[0] = 0;
      expect(branding.logoBytes!.first, 0x89);
      expect(branding.fontRoles, {DocumentFontRole.body});
    });

    test('rejects invalid brand colors and unsupported asset signatures', () {
      expect(
        () => DocumentBranding(
          organizationName: 'NetSales',
          primaryColor: '#123456',
        ),
        throwsArgumentError,
      );
      expect(
        () => DocumentBranding(
          organizationName: 'NetSales',
          logoBytes: Uint8List.fromList([1, 2, 3]),
        ),
        throwsArgumentError,
      );
    });
  });

  group('DocumentImage', () {
    test('bounds and defensively copies image bytes', () {
      final bytes = Uint8List.fromList([
        0x89,
        0x50,
        0x4E,
        0x47,
        0x0D,
        0x0A,
        0x1A,
        0x0A,
      ]);
      final image = DocumentImage(
        bytes: bytes,
        caption: 'Company logo',
        widthPoints: 120,
        heightPoints: 48,
      );
      bytes[0] = 0;
      expect(image.bytes.first, 0x89);
      final exposed = image.bytes;
      exposed[0] = 0;
      expect(image.bytes.first, 0x89);
      expect(
        () => DocumentImage(bytes: Uint8List(4 * 1024 * 1024 + 1)),
        throwsArgumentError,
      );
    });
  });

  group('DocumentDecimalValue', () {
    test('preserves canonical decimal strings without floating conversion', () {
      final value = DocumentDecimalValue('12345678901234567890.123400');
      expect(value.value, '12345678901234567890.123400');
    });

    test('rejects exponent, grouping, leading zero and malformed values', () {
      for (final value in ['1e3', '1,000.00', '01.20', '.5', '1.', '--2']) {
        expect(() => DocumentDecimalValue(value), throwsArgumentError);
      }
    });
  });
}
