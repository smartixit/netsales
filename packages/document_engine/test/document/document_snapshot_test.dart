import 'package:document_engine/document_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  DocumentSnapshot createSnapshot({Iterable<DocumentSection>? sections}) {
    return DocumentSnapshot(
      metadata: DocumentMetadata(
        id: DocumentId('doc-001'),
        documentTypeId: DocumentTypeId('report.summary'),
        title: 'Quarterly report',
        locale: DocumentLocale(
          languageTag: 'ar-YE',
          direction: DocumentTextDirection.rightToLeft,
        ),
        createdAt: DateTime.utc(2026, 11, 9),
      ),
      sections:
          sections ??
          [
            DocumentSection(
              id: 'overview',
              nodes: [
                DocumentHeading(text: 'الملخص', level: 1),
                const DocumentParagraph(text: 'Quarterly summary'),
                DocumentMetric(
                  label: 'Total',
                  value: DocumentDecimalValue('100.00'),
                ),
              ],
            ),
          ],
    );
  }

  test('captures locale and supplied content without deriving values', () {
    final snapshot = createSnapshot();
    expect(snapshot.metadata.locale.languageTag, 'ar-YE');
    expect(
      snapshot.metadata.locale.direction,
      DocumentTextDirection.rightToLeft,
    );
    expect(snapshot.sections.single.nodes, hasLength(3));
  });

  test('defensively copies sections and nested table collections', () {
    final sections = <DocumentSection>[
      DocumentSection(
        id: 'one',
        nodes: const [DocumentParagraph(text: 'A')],
      ),
    ];
    final snapshot = createSnapshot(sections: sections);
    sections.clear();

    expect(snapshot.sections, hasLength(1));
    expect(() => snapshot.sections.clear(), throwsUnsupportedError);
  });

  test('rejects duplicate section identifiers', () {
    expect(
      () => createSnapshot(
        sections: [
          DocumentSection(id: 'duplicate', nodes: const []),
          DocumentSection(id: 'duplicate', nodes: const []),
        ],
      ),
      throwsArgumentError,
    );
  });

  test('rejects invalid heading levels and schema versions', () {
    expect(
      () => DocumentHeading(text: 'Invalid', level: 7),
      throwsArgumentError,
    );
    expect(createSnapshot().schemaVersion, 1);
    expect(
      () => DocumentSnapshot(
        metadata: createSnapshot().metadata,
        sections: const [],
        schemaVersion: 0,
      ),
      throwsArgumentError,
    );
  });

  test('validates structured table shape and unique row identifiers', () {
    final columns = [
      DocumentTableColumn(id: 'name', label: 'Name'),
      DocumentTableColumn(
        id: 'amount',
        label: 'Amount',
        alignment: DocumentCellAlignment.trailing,
      ),
    ];
    final row = DocumentTableRow(
      id: 'row-1',
      cells: [
        const DocumentTableCell(value: DocumentTextValue('Service')),
        DocumentTableCell(value: DocumentDecimalValue('12.50')),
      ],
    );

    final table = DocumentTable(columns: columns, rows: [row]);
    expect(table.columns, hasLength(2));
    expect(table.rows, hasLength(1));

    expect(
      () => DocumentTable(
        columns: columns,
        rows: [
          DocumentTableRow(
            id: 'bad',
            cells: const [
              DocumentTableCell(value: DocumentTextValue('only one')),
            ],
          ),
        ],
      ),
      throwsArgumentError,
    );
    expect(
      () => DocumentTable(columns: columns, rows: [row, row]),
      throwsArgumentError,
    );
  });
}
