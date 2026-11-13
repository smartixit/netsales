import 'dart:typed_data';

import 'package:document_engine/document_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('paragraphs and headings retain all seven semantic font weights', () {
    const weights = DocumentTextWeight.values;
    expect(weights, hasLength(7));
    for (final weight in weights) {
      final paragraph = DocumentParagraph(
        text: 'نص تجريبي',
        weight: weight,
      );
      final heading = DocumentHeading(
        text: 'عنوان تجريبي',
        weight: weight,
      );
      expect(paragraph.weight, weight);
      expect(heading.weight, weight);
    }

    expect(
      const DocumentParagraph(text: 'نص').weight,
      DocumentTextWeight.regular,
    );
    expect(
      DocumentHeading(text: 'عنوان').weight,
      DocumentTextWeight.semiBold,
    );
  });

  test('information grids defensively copy items and validate bounds', () {
    final source = <DocumentInfoItem>[
      DocumentInfoItem(
        label: 'Invoice',
        value: const DocumentTextValue('INV-001'),
      ),
    ];
    final grid = DocumentInfoGrid(items: source);
    source.clear();

    expect(grid.items, hasLength(1));
    expect(() => grid.items.clear(), throwsUnsupportedError);
    expect(
      () => DocumentInfoGrid(items: const <DocumentInfoItem>[]),
      throwsArgumentError,
    );
    expect(
      () => DocumentInfoGrid(
        columns: 4,
        items: [
          DocumentInfoItem(
            label: 'Invoice',
            value: const DocumentTextValue('INV-001'),
          ),
        ],
      ),
      throwsArgumentError,
    );
  });

  test('financial summaries preserve supplied values and immutable lines', () {
    final source = <DocumentFinancialLine>[
      DocumentFinancialLine(
        label: 'Total',
        value: DocumentDecimalValue('100.00'),
        emphasis: DocumentFinancialEmphasis.total,
      ),
    ];
    final summary = DocumentFinancialSummary(lines: source);
    source.clear();

    expect(summary.lines, hasLength(1));
    expect(
      (summary.lines.single.value as DocumentDecimalValue).value,
      '100.00',
    );
    expect(() => summary.lines.clear(), throwsUnsupportedError);
    expect(
      () => DocumentFinancialSummary(
        lines: [
          DocumentFinancialLine(
            label: 'Total A',
            value: DocumentDecimalValue('10.00'),
            emphasis: DocumentFinancialEmphasis.total,
          ),
          DocumentFinancialLine(
            label: 'Total B',
            value: DocumentDecimalValue('20.00'),
            emphasis: DocumentFinancialEmphasis.total,
          ),
        ],
      ),
      throwsArgumentError,
    );
    expect(
      () => DocumentFinancialSummary(lines: const <DocumentFinancialLine>[]),
      throwsArgumentError,
    );
  });

  test('status and callout text have bounded non-empty contracts', () {
    expect(
      () => DocumentStatusBanner(label: ' '),
      throwsArgumentError,
    );
    expect(
      () => DocumentCallout(title: 'Notice', body: ' '),
      throwsArgumentError,
    );
    expect(
      () => DocumentCallout(
        title: 'Notice',
        body: 'A' * 1201,
      ),
      throwsArgumentError,
    );
  });

  test('image and table collections enforce hard bounds', () {
    expect(
      () => DocumentImage(bytes: Uint8List(4 * 1024 * 1024 + 1)),
      throwsArgumentError,
    );
    expect(
      () => DocumentTable(
        columns: [
          for (var index = 0; index < 101; index++)
            DocumentTableColumn(
              id: 'column-$index',
              label: 'Column $index',
            ),
        ],
        rows: const [],
      ),
      throwsArgumentError,
    );
  });

  test('divider validates color, thickness, and spacing', () {
    expect(
      () => DocumentDivider(color: '#FFFFFF'),
      throwsArgumentError,
    );
    expect(
      () => DocumentDivider(thickness: 0),
      throwsArgumentError,
    );
    expect(
      () => DocumentDivider(spacing: 41),
      throwsArgumentError,
    );
  });
}
