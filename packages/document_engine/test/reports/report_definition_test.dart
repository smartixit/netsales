import 'package:document_engine/document_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ReportDefinition definition({int schemaVersion = 1}) => ReportDefinition(
    id: ReportId('sales.operations'),
    schemaVersion: schemaVersion,
    titleKey: 'reports.sales.title',
    supportedLocaleTags: const ['ar', 'en'],
    filters: [
      ReportFilterDefinition(
        id: 'status',
        labelKey: 'filters.status',
        kind: ReportFilterKind.singleChoice,
        required: true,
        choices: [
          ReportChoiceOption(value: 'ACTIVE', labelKey: 'status.active'),
          ReportChoiceOption(value: 'INACTIVE', labelKey: 'status.inactive'),
        ],
      ),
      ReportFilterDefinition(
        id: 'search',
        labelKey: 'filters.search',
        kind: ReportFilterKind.text,
        maxLength: 40,
      ),
      ReportFilterDefinition(
        id: 'period',
        labelKey: 'filters.period',
        kind: ReportFilterKind.dateRange,
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
        groupable: true,
      ),
      ReportColumnDefinition(
        id: 'server_total',
        labelKey: 'columns.server_total',
        dataType: ReportDataType.decimal,
      ),
    ],
    metricSlots: [
      ReportMetricSlotDefinition(
        id: 'server_count',
        labelKey: 'metrics.server_count',
        dataType: ReportDataType.integer,
      ),
    ],
    templates: [
      ReportTemplateReference(
        id: TemplateId('reports.standard'),
        version: TemplateVersion(major: 1, minor: 0, patch: 0),
      ),
    ],
    pageProfileIds: const ['a4-portrait', 'a4-landscape'],
    executionPolicy: ReportExecutionPolicy.either,
    clientRowLimit: 250,
    chartsAvailable: true,
  );

  test('rejects duplicate identifiers and invalid client execution limits', () {
    expect(
      () => ReportDefinition(
        id: ReportId('sales.duplicate'),
        schemaVersion: 1,
        titleKey: 'title',
        supportedLocaleTags: const ['en'],
        filters: const [],
        columns: [
          ReportColumnDefinition(
            id: 'reference',
            labelKey: 'a',
            dataType: ReportDataType.text,
          ),
          ReportColumnDefinition(
            id: 'reference',
            labelKey: 'b',
            dataType: ReportDataType.text,
          ),
        ],
      ),
      throwsArgumentError,
    );

    expect(
      () => ReportDefinition(
        id: ReportId('sales.client'),
        schemaVersion: 1,
        titleKey: 'title',
        supportedLocaleTags: const ['en'],
        filters: const [],
        columns: [
          ReportColumnDefinition(
            id: 'reference',
            labelKey: 'a',
            dataType: ReportDataType.text,
          ),
        ],
        executionPolicy: ReportExecutionPolicy.client,
      ),
      throwsArgumentError,
    );
  });

  test('validates required filters, filter types, and choice allowlists', () {
    final schema = definition();
    final valid = ReportCriteria(
      filters: {
        'status': ReportChoiceFilterValue('ACTIVE'),
        'search': ReportTextFilterValue('North region'),
      },
    );
    expect(valid.validateAgainst(schema), isEmpty);

    final invalid = ReportCriteria(
      filters: {
        'status': ReportTextFilterValue('ACTIVE'),
        'search': ReportTextFilterValue('x' * 41),
        'unknown': ReportBooleanFilterValue(true),
      },
    );
    final issues = invalid.validateAgainst(schema);
    expect(issues.map((issue) => issue.code), contains('filter_type_mismatch'));
    expect(issues.map((issue) => issue.code), contains('text_too_long'));
    expect(issues.map((issue) => issue.code), contains('unknown_filter'));
    final missingRequired = ReportCriteria(
      filters: {'search': ReportTextFilterValue('North region')},
    );
    expect(
      missingRequired.validateAgainst(schema).map((issue) => issue.code),
      contains('required_filter_missing'),
    );

    final invalidChoice = ReportCriteria(
      filters: {'status': ReportChoiceFilterValue('DELETED')},
    );
    expect(
      invalidChoice.validateAgainst(schema).map((issue) => issue.code),
      contains('choice_not_allowed'),
    );
  });

  test('date range rejects an end before its start', () {
    expect(
      () => ReportDateRangeFilterValue(
        start: DateTime.utc(2026, 12, 1),
        end: DateTime.utc(2026, 11, 1),
      ),
      throwsArgumentError,
    );
  });

  test('presentation selections are constrained by the definition', () {
    final schema = definition();
    final valid = ReportPresentationOptions(
      visibleColumnIds: const ['reference', 'created_at'],
      sorts: const [
        ReportSortOption(
          fieldId: 'created_at',
          direction: ReportSortDirection.descending,
        ),
      ],
      groupByFieldId: 'created_at',
      template: ReportTemplateSelection(
        id: TemplateId('reports.standard'),
        version: TemplateVersion(major: 1, minor: 0, patch: 0),
      ),
      languageTag: 'ar-YE',
      pageProfileId: 'a4-landscape',
      includeMetrics: true,
      includeCharts: true,
    );
    expect(valid.validateAgainst(schema), isEmpty);

    final invalid = ReportPresentationOptions(
      visibleColumnIds: const ['created_at'],
      sorts: const [
        ReportSortOption(
          fieldId: 'server_total',
          direction: ReportSortDirection.ascending,
        ),
      ],
      groupByFieldId: 'reference',
      languageTag: 'fr',
      pageProfileId: 'letter',
      includeCharts: true,
    );
    final codes = invalid.validateAgainst(schema).map((issue) => issue.code);
    expect(codes, contains('required_column_hidden'));
    expect(codes, contains('sorting_not_allowed'));
    expect(codes, contains('grouping_not_allowed'));
    expect(codes, contains('locale_not_allowed'));
    expect(codes, contains('page_profile_not_allowed'));
  });

  test(
    'does not allow metric or chart toggles absent from the report schema',
    () {
      final base = definition();
      final noVisuals = ReportDefinition(
        id: ReportId('sales.simple'),
        schemaVersion: 1,
        titleKey: 'reports.simple.title',
        supportedLocaleTags: const ['en'],
        filters: const [],
        columns: [
          ReportColumnDefinition(
            id: 'reference',
            labelKey: 'columns.reference',
            dataType: ReportDataType.text,
          ),
        ],
      );
      expect(
        ReportPresentationOptions(includeMetrics: true)
            .validateAgainst(noVisuals)
            .map((issue) => issue.code),
        contains('metrics_not_available'),
      );
      expect(
        ReportPresentationOptions(includeCharts: true)
            .validateAgainst(noVisuals)
            .map((issue) => issue.code),
        contains('charts_not_available'),
      );
      expect(base.id, ReportId('sales.operations'));
    },
  );
  test('report registry resolves exact schema versions only', () {
    final registry = ReportDefinitionRegistry();
    final v1 = definition(schemaVersion: 1);
    final v2 = definition(schemaVersion: 2);
    registry
      ..register(v2)
      ..register(v1);

    expect(registry.require(id: v1.id, schemaVersion: 1), same(v1));
    expect(registry.versionsOf(v1.id), [v1, v2]);
    expect(registry.find(id: v1.id, schemaVersion: 3), isNull);
    expect(
      () => registry.require(id: v1.id, schemaVersion: 3),
      throwsStateError,
    );
    expect(
      () => registry.register(definition(schemaVersion: 2)),
      throwsStateError,
    );
  });
}
