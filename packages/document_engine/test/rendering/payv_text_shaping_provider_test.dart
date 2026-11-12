import 'package:document_engine/document_engine.dart';
import 'package:document_engine/document_engine_flutter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:payv/payv.dart' as payv;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PayvTextShapingProvider provider;

  setUpAll(() async {
    final fontBytes = await loadDocumentEngineArabicFont();
    provider = PayvTextShapingProvider(fontBytes, languageTag: 'ar-YE');
  });

  test('resolves paragraph base direction before wrapping', () {
    expect(
      provider.resolveDirection('فاتورة INV-2026/0017'),
      DocumentTextDirection.rightToLeft,
    );
    expect(
      provider.resolveDirection('Invoice INV-2026/0017'),
      DocumentTextDirection.leftToRight,
    );
    expect(
      provider.resolveDirection(
        'INV-2026/0017 فاتورة',
      ),
      DocumentTextDirection.leftToRight,
    );
  });

  test('shapes connected Arabic letters into non-empty vector glyphs', () {
    final line = provider.shapeLine(
      'مرحبا بكم في نظام NetSales',
      direction: DocumentTextDirection.rightToLeft,
    );

    expect(line.isRightToLeft, isTrue);
    expect(line.visualRuns, isNotEmpty);
    expect(line.visualRuns.expand((run) => run.glyphs), isNotEmpty);
    expect(line.advance, greaterThan(0));
    expect(
      line.visualRuns.expand((run) => run.glyphs).every(
        (glyph) => glyph.outline.isNotEmpty,
      ),
      isTrue,
    );
  });

  test('resolves mixed Arabic, Latin identifiers and currency direction', () {
    final line = provider.shapeLine(
      'رقم الفاتورة INV-2026/0017 — الإجمالي: YER 1,250.50',
      direction: DocumentTextDirection.rightToLeft,
    );

    expect(line.isRightToLeft, isTrue);
    expect(line.visualRuns.map((run) => run.direction).toSet(), containsAll({
      // The paragraph is RTL while embedded Latin and numeric runs remain LTR.
      payv.TextDirection.rtl,
      payv.TextDirection.ltr,
    }));
  });

  test('resolves Unicode LTR isolates around phone and UUID values', () {
    final line = provider.shapeLine(
      'الهاتف: \u2066+967 777 123 456\u2069 — المعرف: '
      '\u2066550e8400-e29b-41d4-a716-446655440000\u2069',
      direction: DocumentTextDirection.rightToLeft,
    );

    expect(line.isRightToLeft, isTrue);
    expect(line.visualRuns, isNotEmpty);
  });

  test('keeps Arabic-Indic and Western digit glyphs in a mixed line', () {
    final line = provider.shapeLine(
      'الإجمالي: ١٬٢٥٠٫٥٠ YER / USD 1,250.50',
      direction: DocumentTextDirection.rightToLeft,
    );

    final glyphs = line.visualRuns.expand((run) => run.glyphs);
    expect(glyphs, isNotEmpty);
    expect(glyphs.every((glyph) => glyph.glyphId > 0), isTrue);
  });

  test('rejects paragraph separators in the single-line shaping contract', () {
    expect(
      () => provider.shapeLine('السطر الأول\nالسطر الثاني'),
      throwsArgumentError,
    );
  });
}
