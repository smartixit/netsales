import 'dart:typed_data';

import 'package:document_engine/document_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final documentType = DocumentTypeId('report.summary');
  final template = DocumentTemplateDefinition(
    id: TemplateId('report.summary.standard'),
    version: TemplateVersion(major: 1, minor: 0, patch: 0),
    documentTypeId: documentType,
    displayName: 'Standard summary',
    supportedLocaleTags: const ['en'],
    capabilities: TemplateCapabilities({
      TemplateCapability.tables,
      TemplateCapability.metrics,
      TemplateCapability.charts,
      TemplateCapability.coverPage,
      TemplateCapability.pageNumbering,
      TemplateCapability.repeatingHeader,
      TemplateCapability.repeatingFooter,
      TemplateCapability.portraitPage,
      TemplateCapability.landscapePage,
    }),
  );

  DocumentSnapshot snapshot({
    String title = 'Quarterly summary',
    String languageTag = 'en-US',
    List<DocumentNode>? nodes,
  }) {
    return DocumentSnapshot(
      metadata: DocumentMetadata(
        id: DocumentId('report-001'),
        documentTypeId: documentType,
        title: title,
        locale: DocumentLocale(
          languageTag: languageTag,
          direction: DocumentTextDirection.leftToRight,
        ),
        createdAt: DateTime.utc(2026, 11, 9),
      ),
      sections: [
        DocumentSection(
          id: 'summary',
          title: 'Overview',
          nodes:
              nodes ??
              [
                const DocumentParagraph(text: 'This is a generated report.'),
                DocumentMetric(
                  label: 'Gross sales',
                  value: DocumentDecimalValue('1250.50'),
                  caption: 'Supplied by the host application',
                ),
                DocumentTable(
                  columns: [
                    DocumentTableColumn(id: 'item', label: 'Item'),
                    DocumentTableColumn(
                      id: 'amount',
                      label: 'Amount',
                      alignment: DocumentCellAlignment.trailing,
                    ),
                  ],
                  rows: [
                    DocumentTableRow(
                      id: 'row-1',
                      cells: [
                        const DocumentTableCell(
                          value: DocumentTextValue('Service'),
                        ),
                        DocumentTableCell(
                          value: DocumentDecimalValue('1250.50'),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
        ),
      ],
    );
  }

  DocumentRenderOptions options({
    DocumentPageProfile? pageProfile,
    bool showPageNumbers = true,
    String? headerText,
    String? footerText,
  }) {
    return DocumentRenderOptions(
      pageProfile: pageProfile ?? DocumentPageProfile.a4Portrait(),
      generatedAt: DateTime.utc(2026, 11, 9, 10),
      showPageNumbers: showPageNumbers,
      headerText: headerText,
      footerText: footerText,
    );
  }

  test(
    'renders a PDF with metadata, digest, and defensive byte copies',
    () async {
      const renderer = PdfDocumentRenderer();
      final result = await renderer.render(
        snapshot: snapshot(),
        template: template,
        options: options(
          headerText: 'NetSales Reports',
          footerText: 'Confidential',
        ),
      );

      expect(result, isA<DocumentRenderSuccess>());
      final artifact = (result as DocumentRenderSuccess).artifact;
      expect(artifact.bytes.take(5), [37, 80, 68, 70, 45]);
      expect(artifact.byteLength, greaterThan(100));
      expect(artifact.sha256, matches(RegExp(r'^[a-f0-9]{64}$')));
      expect(artifact.documentId, DocumentId('report-001'));
      expect(artifact.templateVersion.toString(), '1.0.0');
      expect(artifact.rendererId, 'document-engine.pdf');
      expect(artifact.generatedAt, DateTime.utc(2026, 11, 9, 10));

      final firstCopy = artifact.bytes;
      firstCopy[0] = 0;
      expect(artifact.bytes.first, 37);
    },
  );

  test(
    'template layout strategies produce distinct PDF compositions',
    () async {
      const renderer = PdfDocumentRenderer();
      final executive = DocumentTemplateDefinition(
        id: TemplateId('report.summary.executive'),
        version: TemplateVersion(major: 1, minor: 0, patch: 0),
        documentTypeId: documentType,
        displayName: 'Executive summary',
        supportedLocaleTags: const ['en'],
        capabilities: template.capabilities,
        layout: DocumentTemplateLayout.executive,
      );
      final compact = DocumentTemplateDefinition(
        id: TemplateId('report.summary.compact'),
        version: TemplateVersion(major: 1, minor: 0, patch: 0),
        documentTypeId: documentType,
        displayName: 'Compact summary',
        supportedLocaleTags: const ['en'],
        capabilities: template.capabilities,
        layout: DocumentTemplateLayout.compact,
      );

      final executiveResult = await renderer.render(
        snapshot: snapshot(),
        template: executive,
        options: options(),
      );
      final compactResult = await renderer.render(
        snapshot: snapshot(),
        template: compact,
        options: options(),
      );

      expect(executiveResult, isA<DocumentRenderSuccess>());
      expect(compactResult, isA<DocumentRenderSuccess>());
      expect(
        (executiveResult as DocumentRenderSuccess).artifact.sha256,
        isNot((compactResult as DocumentRenderSuccess).artifact.sha256),
      );
    },
  );

  test(
    'rejects image nodes when the selected template lacks image capability',
    () async {
      const renderer = PdfDocumentRenderer();
      final result = await renderer.render(
        snapshot: snapshot(
          nodes: [
            DocumentImage(
              bytes: Uint8List.fromList([
                0x89,
                0x50,
                0x4E,
                0x47,
                0x0D,
                0x0A,
                0x1A,
                0x0A,
              ]),
            ),
          ],
        ),
        template: template,
        options: options(),
      );

      expect(result, isA<DocumentRenderFailure>());
      expect(
        (result as DocumentRenderFailure).code,
        DocumentRenderFailureCode.unsupportedCapability,
      );
    },
  );

  test('renders bounded image nodes and a branded logo asset', () async {
    const renderer = PdfDocumentRenderer();
    final png = Uint8List.fromList([
      137,
      80,
      78,
      71,
      13,
      10,
      26,
      10,
      0,
      0,
      0,
      13,
      73,
      72,
      68,
      82,
      0,
      0,
      0,
      1,
      0,
      0,
      0,
      1,
      8,
      6,
      0,
      0,
      0,
      31,
      21,
      196,
      137,
      0,
      0,
      0,
      13,
      73,
      68,
      65,
      84,
      120,
      156,
      99,
      248,
      207,
      192,
      240,
      31,
      0,
      5,
      0,
      1,
      255,
      137,
      153,
      61,
      29,
      0,
      0,
      0,
      0,
      73,
      69,
      78,
      68,
      174,
      66,
      96,
      130,
    ]);
    final imageTemplate = DocumentTemplateDefinition(
      id: TemplateId('report.summary.with_images'),
      version: TemplateVersion(major: 1, minor: 0, patch: 0),
      documentTypeId: documentType,
      displayName: 'Image report',
      supportedLocaleTags: const ['en'],
      capabilities: TemplateCapabilities([
        ...template.capabilities.values,
        TemplateCapability.images,
      ]),
    );
    final result = await renderer.render(
      snapshot: snapshot(
        nodes: [
          DocumentImage(
            bytes: png,
            caption: 'Organization mark',
            widthPoints: 48,
            heightPoints: 48,
          ),
        ],
      ),
      template: imageTemplate,
      options: DocumentRenderOptions(
        pageProfile: DocumentPageProfile.a4Portrait(),
        generatedAt: DateTime.utc(2026, 11, 9, 10),
        branding: DocumentBranding(
          organizationName: 'Northstar Labs',
          logoBytes: png,
          primaryColor: '123456',
        ),
      ),
    );

    expect(result, isA<DocumentRenderSuccess>());
    expect(
      (result as DocumentRenderSuccess).artifact.byteLength,
      greaterThan(100),
    );
  });

  test('applies host branding to the rendered document contract', () async {
    const renderer = PdfDocumentRenderer();
    final result = await renderer.render(
      snapshot: snapshot(),
      template: template,
      options: DocumentRenderOptions(
        pageProfile: DocumentPageProfile.a4Portrait(),
        generatedAt: DateTime.utc(2026, 11, 9, 10),
        branding: DocumentBranding(
          organizationName: 'Northstar Labs',
          tagline: 'Business intelligence',
          primaryColor: '123456',
          textColor: '101820',
        ),
      ),
    );

    expect(result, isA<DocumentRenderSuccess>());
    expect(
      (result as DocumentRenderSuccess).artifact.sha256,
      matches(RegExp(r'^[a-f0-9]{64}$')),
    );
  });

  test(
    'rejects complex RTL text until a shaping provider is approved',
    () async {
      const renderer = PdfDocumentRenderer();
      final result = await renderer.render(
        snapshot: snapshot(
          languageTag: 'en-US',
          nodes: const [DocumentParagraph(text: 'تقرير المبيعات')],
        ),
        template: template,
        options: options(),
      );

      expect(result, isA<DocumentRenderFailure>());
      expect(
        (result as DocumentRenderFailure).code,
        DocumentRenderFailureCode.unsupportedTextShaping,
      );
    },
  );

  test(
    'rejects RTL in host-supplied headers, cover metadata, and branding',
    () async {
      const renderer = PdfDocumentRenderer();
      final invalidOptions = <DocumentRenderOptions>[
        options(headerText: 'تقرير المبيعات'),
        DocumentRenderOptions(
          pageProfile: DocumentPageProfile.a4Portrait(),
          generatedAt: DateTime.utc(2026, 11, 9, 10),
          firstPageFooterText: 'نسخة داخلية',
        ),
        DocumentRenderOptions(
          pageProfile: DocumentPageProfile.a4Portrait(),
          generatedAt: DateTime.utc(2026, 11, 9, 10),
          coverPage: true,
          coverTitle: 'Quarterly report',
          coverMetadata: const {'الجهة': 'شركة النور'},
        ),
        DocumentRenderOptions(
          pageProfile: DocumentPageProfile.a4Portrait(),
          generatedAt: DateTime.utc(2026, 11, 9, 10),
          branding: DocumentBranding(
            organizationName: 'شركة النور',
            tagline: 'Business services',
          ),
        ),
      ];

      for (final invalidOption in invalidOptions) {
        final result = await renderer.render(
          snapshot: snapshot(),
          template: template,
          options: invalidOption,
        );
        expect(result, isA<DocumentRenderFailure>());
        expect(
          (result as DocumentRenderFailure).code,
          DocumentRenderFailureCode.unsupportedTextShaping,
        );
      }
    },
  );

  test('rejects a template registered for another document type', () async {
    const renderer = PdfDocumentRenderer();
    final otherTemplate = DocumentTemplateDefinition(
      id: TemplateId('invoice.standard'),
      version: TemplateVersion(major: 1, minor: 0, patch: 0),
      documentTypeId: DocumentTypeId('sales.invoice'),
      displayName: 'Invoice',
      supportedLocaleTags: const ['en'],
      capabilities: template.capabilities,
    );

    final result = await renderer.render(
      snapshot: snapshot(),
      template: otherTemplate,
      options: options(),
    );

    expect(result, isA<DocumentRenderFailure>());
    expect(
      (result as DocumentRenderFailure).code,
      DocumentRenderFailureCode.templateMismatch,
    );
  });

  test(
    'requires the template to declare the requested page orientation',
    () async {
      const renderer = PdfDocumentRenderer();
      final portraitOnly = DocumentTemplateDefinition(
        id: TemplateId('report.portrait'),
        version: TemplateVersion(major: 1, minor: 0, patch: 0),
        documentTypeId: documentType,
        displayName: 'Portrait report',
        supportedLocaleTags: const ['en'],
        capabilities: TemplateCapabilities({
          TemplateCapability.pageNumbering,
          TemplateCapability.portraitPage,
        }),
      );

      final result = await renderer.render(
        snapshot: snapshot(
          nodes: const [DocumentParagraph(text: 'Short report')],
        ),
        template: portraitOnly,
        options: options(pageProfile: DocumentPageProfile.a4Landscape()),
      );

      expect(result, isA<DocumentRenderFailure>());
      expect(
        (result as DocumentRenderFailure).code,
        DocumentRenderFailureCode.unsupportedCapability,
      );
    },
  );

  test('validates printable area and page limits', () {
    expect(
      () => DocumentPageProfile(
        widthPoints: 100,
        heightPoints: 100,
        marginLeft: 50,
        marginRight: 50,
      ),
      throwsArgumentError,
    );
    expect(
      () => DocumentRenderOptions(
        pageProfile: DocumentPageProfile.a4Portrait(),
        generatedAt: DateTime.utc(2026),
        maxPages: 0,
      ),
      throwsArgumentError,
    );
  });

  test(
    'renders charts, metric grids, styled tables, and a cover page',
    () async {
      const renderer = PdfDocumentRenderer();
      final chart = DocumentChart(
        title: 'Monthly performance',
        subtitle: 'Server-provided series',
        type: DocumentChartType.bar,
        series: [
          DocumentChartSeries(
            id: 'actual',
            label: 'Actual',
            color: '0D7A5F',
            points: [
              DocumentChartPoint(
                label: 'Jan',
                value: 12,
                displayValue: '12.00',
              ),
              DocumentChartPoint(
                label: 'Feb',
                value: 18,
                displayValue: '18.00',
              ),
              DocumentChartPoint(
                label: 'Mar',
                value: 15,
                displayValue: '15.00',
              ),
            ],
          ),
          DocumentChartSeries(
            id: 'target',
            label: 'Target',
            color: '2563EB',
            points: [
              DocumentChartPoint(label: 'Jan', value: 10),
              DocumentChartPoint(label: 'Feb', value: 16),
              DocumentChartPoint(label: 'Mar', value: 16),
            ],
          ),
        ],
      );
      final table = DocumentTable(
        columns: [
          DocumentTableColumn(id: 'period', label: 'Period'),
          DocumentTableColumn(
            id: 'value',
            label: 'Value',
            alignment: DocumentCellAlignment.decimal,
          ),
        ],
        rows: [
          DocumentTableRow(
            id: 'jan',
            cells: [
              const DocumentTableCell(value: DocumentTextValue('January')),
              DocumentTableCell(value: DocumentDecimalValue('1250.50')),
            ],
          ),
          DocumentTableRow(
            id: 'feb',
            cells: [
              const DocumentTableCell(value: DocumentTextValue('February')),
              DocumentTableCell(value: DocumentDecimalValue('1500.75')),
            ],
          ),
        ],
        style: DocumentTableStyle(
          stripedRows: true,
          compact: true,
          headerColor: 'E2E8F0',
          alternateRowColor: 'F8FAFC',
          columnWeights: [2, 1],
        ),
      );

      final result = await renderer.render(
        snapshot: snapshot(
          nodes: [
            DocumentMetricGrid(
              columns: 2,
              metrics: [
                DocumentMetric(
                  label: 'Gross sales',
                  value: DocumentDecimalValue('1250.50'),
                  caption: 'Supplied total',
                ),
                DocumentMetric(
                  label: 'Orders',
                  value: DocumentIntegerValue(42),
                ),
                DocumentMetric(
                  label: 'Average',
                  value: DocumentDecimalValue('29.77'),
                ),
              ],
            ),
            table,
            chart,
          ],
        ),
        template: template,
        options: DocumentRenderOptions(
          pageProfile: DocumentPageProfile.a4Portrait(),
          generatedAt: DateTime.utc(2026, 11, 9, 10),
          coverPage: true,
          coverTitle: 'Quarterly report',
          coverSubtitle: 'Executive summary',
          coverMetadata: const {'Period': 'Q3 2026', 'Prepared by': 'NetSales'},
          firstPageHeaderText: 'Quarterly report',
          headerText: 'NetSales | Confidential',
          footerText: 'Internal use',
        ),
      );

      expect(result, isA<DocumentRenderSuccess>());
      final artifact = (result as DocumentRenderSuccess).artifact;
      expect(artifact.bytes.take(5), [37, 80, 68, 70, 45]);
      expect(artifact.byteLength, greaterThan(500));
      expect(artifact.rendererVersion, '1.2.0');
    },
  );

  test(
    'validates chart categories, pie values, and metric grid constraints',
    () {
      expect(
        () => DocumentChart(
          title: 'Misaligned series',
          type: DocumentChartType.line,
          series: [
            DocumentChartSeries(
              id: 'one',
              label: 'One',
              points: [
                DocumentChartPoint(label: 'Jan', value: 1),
                DocumentChartPoint(label: 'Feb', value: 2),
              ],
            ),
            DocumentChartSeries(
              id: 'two',
              label: 'Two',
              points: [
                DocumentChartPoint(label: 'Feb', value: 1),
                DocumentChartPoint(label: 'Mar', value: 2),
              ],
            ),
          ],
        ),
        throwsArgumentError,
      );

      expect(
        () => DocumentChart(
          title: 'Invalid pie',
          type: DocumentChartType.pie,
          series: [
            DocumentChartSeries(
              id: 'slices',
              label: 'Slices',
              points: [
                DocumentChartPoint(label: 'A', value: -1),
                DocumentChartPoint(label: 'B', value: 2),
              ],
            ),
          ],
        ),
        throwsArgumentError,
      );

      expect(
        () => DocumentMetricGrid(
          columns: 5,
          metrics: [
            DocumentMetric(label: 'Count', value: DocumentIntegerValue(1)),
          ],
        ),
        throwsArgumentError,
      );
    },
  );

  test('includes the cover page in the configured maximum page count', () {
    expect(
      () => DocumentRenderOptions(
        pageProfile: DocumentPageProfile.a4Portrait(),
        generatedAt: DateTime.utc(2026),
        coverPage: true,
        coverTitle: 'Cover',
        maxPages: 1,
      ),
      throwsArgumentError,
    );
  });

  test('renders line, pie, and donut vector charts', () async {
    const renderer = PdfDocumentRenderer();
    for (final type in [
      DocumentChartType.line,
      DocumentChartType.pie,
      DocumentChartType.donut,
    ]) {
      final result = await renderer.render(
        snapshot: snapshot(
          nodes: [
            DocumentChart(
              title: 'Regional performance',
              type: type,
              series: [
                DocumentChartSeries(
                  id: 'regions',
                  label: 'Regions',
                  points: [
                    DocumentChartPoint(
                      label: 'North',
                      value: 10,
                      displayValue: '10.00',
                    ),
                    DocumentChartPoint(
                      label: 'South',
                      value: 20,
                      displayValue: '20.00',
                    ),
                    DocumentChartPoint(
                      label: 'West',
                      value: 15,
                      displayValue: '15.00',
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        template: template,
        options: options(),
      );

      expect(result, isA<DocumentRenderSuccess>(), reason: type.name);
    }
  });
}
