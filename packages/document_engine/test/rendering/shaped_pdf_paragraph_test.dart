import 'package:document_engine/document_engine.dart';
import 'package:document_engine/document_engine_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PayvTextShapingProvider provider;

  setUpAll(() async {
    provider = PayvTextShapingProvider(
      await loadDocumentEngineArabicFont(),
      languageTag: 'ar-YE',
    );
  });

  test('paragraph accepts mixed Arabic and Latin financial text', () {
    final paragraph = ShapedPdfParagraph(
      text: 'فاتورة مبيعات INV-2026/0017 تتضمن أصنافاً متعددة '
          'ومبالغ بعملات YER و USD.',
      provider: provider,
      width: 180,
      fontSize: 10,
      direction: DocumentTextDirection.rightToLeft,
    );

    expect(paragraph, isA<ShapedPdfParagraph>());
    expect(
      provider.shapeLine(
        'فاتورة INV-2026/0017 — YER 1,250.50',
        direction: DocumentTextDirection.rightToLeft,
      ).advance,
      greaterThan(0),
    );
  });

  test('paragraph rejects invalid geometry instead of clipping', () {
    expect(
      () => ShapedPdfParagraph(
        text: 'نص',
        provider: provider,
        width: 0,
        fontSize: 10,
      ),
      throwsArgumentError,
    );
  });
}
