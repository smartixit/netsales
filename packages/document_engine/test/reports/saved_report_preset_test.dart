import 'package:document_engine/document_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ReportDefinition definition({int version = 1}) => ReportDefinition(
    id: ReportId('sales.operations'),
    schemaVersion: version,
    titleKey: 'reports.sales.title',
    supportedLocaleTags: const ['ar', 'en'],
    filters: [
      ReportFilterDefinition(
        id: 'status',
        labelKey: 'filters.status',
        kind: ReportFilterKind.singleChoice,
        choices: [
          ReportChoiceOption(value: 'ACTIVE', labelKey: 'status.active'),
          ReportChoiceOption(value: 'INACTIVE', labelKey: 'status.inactive'),
        ],
      ),
      ReportFilterDefinition(
        id: 'period',
        labelKey: 'filters.period',
        kind: ReportFilterKind.dateRange,
      ),
      ReportFilterDefinition(
        id: 'amount',
        labelKey: 'filters.amount',
        kind: ReportFilterKind.decimal,
      ),
    ],
    columns: [
      ReportColumnDefinition(
        id: 'reference',
        labelKey: 'columns.reference',
        dataType: ReportDataType.text,
        hideable: false,
        sortable: true,
      ),
      ReportColumnDefinition(
        id: 'created_at',
        labelKey: 'columns.created_at',
        dataType: ReportDataType.date,
        sortable: true,
      ),
    ],
    templates: [
      ReportTemplateReference(
        id: TemplateId('reports.standard'),
        version: TemplateVersion(major: 1, minor: 0, patch: 0),
      ),
    ],
    pageProfileIds: const ['a4-portrait'],
  );

  SavedReportPreset preset() => SavedReportPreset(
    id: 'preset.monthly-sales',
    name: '  Monthly sales  ',
    reportId: ReportId('sales.operations'),
    reportSchemaVersion: 1,
    criteria: ReportCriteria(
      filters: {
        'status': ReportChoiceFilterValue('ACTIVE'),
        'period': ReportDateRangeFilterValue(
          start: DateTime.utc(2026, 1, 1),
          end: DateTime.utc(2026, 1, 31),
        ),
        'amount': ReportDecimalFilterValue('12345678901234567890.1200'),
      },
    ),
    presentation: ReportPresentationOptions(
      visibleColumnIds: const ['reference', 'created_at'],
      sorts: const [
        ReportSortOption(
          fieldId: 'created_at',
          direction: ReportSortDirection.descending,
        ),
      ],
      template: ReportTemplateSelection(
        id: TemplateId('reports.standard'),
        version: TemplateVersion(major: 1, minor: 0, patch: 0),
      ),
      languageTag: 'ar',
      pageProfileId: 'a4-portrait',
    ),
  );

  test(
    'round-trips versioned criteria and presentation without losing decimals',
    () {
      final original = preset();
      final decoded = SavedReportPreset.fromJson(original.toJson());
      expect(decoded.id, original.id);
      expect(decoded.name, 'Monthly sales');
      expect(decoded.reportId, original.reportId);
      expect(decoded.reportSchemaVersion, 1);
      expect(
        (decoded.criteria.filters['amount']! as ReportDecimalFilterValue).value,
        '12345678901234567890.1200',
      );
      expect(
        decoded.criteria.filters['period'],
        isA<ReportDateRangeFilterValue>(),
      );
      expect(decoded.presentation.visibleColumnIds, [
        'reference',
        'created_at',
      ]);
      expect(decoded.presentation.sorts.single.fieldId, 'created_at');
    },
  );

  test('rejects unsupported preset schema versions for explicit migration', () {
    final json = preset().toJson()..['preset_schema_version'] = 2;
    expect(
      () => SavedReportPreset.fromJson(json),
      throwsA(isA<FormatException>()),
    );
  });

  test('rejects unknown persisted keys such as tenant or record payloads', () {
    final json = preset().toJson()
      ..['records'] = [
        {'id': 1},
      ];
    expect(
      () => SavedReportPreset.fromJson(json),
      throwsA(isA<FormatException>()),
    );
    final tenantJson = preset().toJson()..['tenant_id'] = 42;
    expect(
      () => SavedReportPreset.fromJson(tenantJson),
      throwsA(isA<FormatException>()),
    );
  });

  test('schema changes and removed fields require explicit review', () {
    final saved = preset();
    final unchanged = saved.assessAgainst(definition());
    expect(unchanged.status, ReportPresetCompatibilityStatus.current);
    expect(unchanged.requiresReview, isFalse);

    final changed = saved.assessAgainst(definition(version: 2));
    expect(changed.status, ReportPresetCompatibilityStatus.reviewRequired);
    expect(changed.requiresReview, isTrue);

    final different = saved.assessAgainst(
      ReportDefinition(
        id: ReportId('sales.other'),
        schemaVersion: 1,
        titleKey: 'reports.other.title',
        supportedLocaleTags: const ['en'],
        filters: const [],
        columns: [
          ReportColumnDefinition(
            id: 'reference',
            labelKey: 'columns.reference',
            dataType: ReportDataType.text,
          ),
        ],
      ),
    );
    expect(different.status, ReportPresetCompatibilityStatus.differentReport);
  });

  test('preset identity and names are validated', () {
    expect(
      () => SavedReportPreset(
        id: 'bad/id',
        name: 'Test',
        reportId: ReportId('sales.operations'),
        reportSchemaVersion: 1,
        criteria: ReportCriteria(),
        presentation: ReportPresentationOptions(),
      ),
      throwsArgumentError,
    );
    expect(
      () => SavedReportPreset(
        id: 'preset.valid',
        name: '   ',
        reportId: ReportId('sales.operations'),
        reportSchemaVersion: 1,
        criteria: ReportCriteria(),
        presentation: ReportPresentationOptions(),
      ),
      throwsArgumentError,
    );
  });
  test('round-trips an open-ended date range boundary', () {
    final startOnly = ReportDateRangeFilterValue(
      start: DateTime.utc(2026, 1, 1),
      end: null,
    );
    final decoded = ReportFilterValue.fromJson(
      startOnly.toJson(),
    ) as ReportDateRangeFilterValue;
    expect(decoded.start, DateTime.utc(2026, 1, 1));
    expect(decoded.end, isNull);

    final endOnly = ReportDateRangeFilterValue(
      start: null,
      end: DateTime.utc(2026, 1, 31),
    );
    final decodedEndOnly = ReportFilterValue.fromJson(
      endOnly.toJson(),
    ) as ReportDateRangeFilterValue;
    expect(decodedEndOnly.start, isNull);
    expect(decodedEndOnly.end, DateTime.utc(2026, 1, 31));
    expect(
      () => ReportDateRangeFilterValue(start: null, end: null),
      throwsArgumentError,
    );
  });
}
