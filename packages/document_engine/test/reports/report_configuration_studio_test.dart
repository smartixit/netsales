import 'package:document_engine/document_engine.dart';
import 'package:document_engine/document_engine_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final definition = ReportDefinition(
    id: ReportId('sales.operations'),
    schemaVersion: 2,
    titleKey: 'reports.sales.title',
    descriptionKey: 'reports.sales.description',
    supportedLocaleTags: const ['ar', 'en'],
    filters: [
      ReportFilterDefinition(
        id: 'search',
        labelKey: 'filters.search',
        kind: ReportFilterKind.text,
      ),
      ReportFilterDefinition(
        id: 'period',
        labelKey: 'filters.period',
        kind: ReportFilterKind.dateRange,
      ),
      ReportFilterDefinition(
        id: 'status',
        labelKey: 'filters.status',
        kind: ReportFilterKind.singleChoice,
        choices: [
          ReportChoiceOption(value: 'ACTIVE', labelKey: 'status.active'),
          ReportChoiceOption(value: 'INACTIVE', labelKey: 'status.inactive'),
        ],
      ),
    ],
    columns: [
      ReportColumnDefinition(
        id: 'reference',
        labelKey: 'columns.reference',
        dataType: ReportDataType.text,
        hideable: false,
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

  Widget buildStudio({
    required ValueChanged<ReportCriteria> onCriteriaChanged,
    required ValueChanged<ReportPresentationOptions> onPresentationChanged,
    ReportStudioActionBuilder? actionBuilder,
    ReportStudioFilterSectionBuilder? filterSectionBuilder,
    ReportStudioPresentationSectionBuilder? presentationSectionBuilder,
  }) => MaterialApp(
    home: Scaffold(
      body: ReportConfigurationStudio(
        definition: definition,
        criteria: ReportCriteria(),
        presentation: ReportPresentationOptions(),
        resolveLabel: (_, key) => key,
        onCriteriaChanged: onCriteriaChanged,
        onPresentationChanged: onPresentationChanged,
        onPreview: () {},
        onSavePreset: () {},
        actionBuilder: actionBuilder,
        filterSectionBuilder: filterSectionBuilder,
        presentationSectionBuilder: presentationSectionBuilder,
      ),
    ),
  );

  testWidgets('renders only schema-declared filter and output controls', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      buildStudio(onCriteriaChanged: (_) {}, onPresentationChanged: (_) {}),
    );

    expect(find.text('reports.sales.title'), findsOneWidget);
    expect(find.text('filters.search'), findsOneWidget);
    expect(find.text('filters.status'), findsOneWidget);
    expect(find.text('columns.reference'), findsOneWidget);
    expect(find.text('columns.created_at'), findsOneWidget);
    expect(find.text('report_configuration.output_design'), findsOneWidget);
  });

  testWidgets('allows host design-system actions to replace package defaults', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildStudio(
        onCriteriaChanged: (_) {},
        onPresentationChanged: (_) {},
        actionBuilder:
            (
              context, {
              required label,
              required icon,
              required onPressed,
              required secondary,
            }) => OutlinedButton.icon(
              key: ValueKey('host-action-$label'),
              onPressed: onPressed,
              icon: Icon(icon),
              label: Text(label),
            ),
      ),
    );

    expect(
      find.byKey(const ValueKey('host-action-report_configuration.preview')),
      findsOneWidget,
    );
  });

  testWidgets(
    'allows the host to replace filter and presentation controls entirely',
    (tester) async {
      await tester.pumpWidget(
        buildStudio(
          onCriteriaChanged: (_) {},
          onPresentationChanged: (_) {},
          filterSectionBuilder:
              (
                context, {
                required definition,
                required criteria,
                required resolveLabel,
                required onChanged,
              }) => const SizedBox(
                key: ValueKey('host-filter-section'),
                child: Text('Host filter controls'),
              ),
          presentationSectionBuilder:
              (
                context, {
                required definition,
                required presentation,
                required resolveLabel,
                required onChanged,
              }) => const SizedBox(
                key: ValueKey('host-presentation-section'),
                child: Text('Host presentation controls'),
              ),
        ),
      );

      expect(find.byKey(const ValueKey('host-filter-section')), findsOneWidget);
      expect(
        find.byKey(const ValueKey('host-presentation-section')),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('report-filter-search')), findsNothing);
      expect(find.byType(DropdownButtonFormField<String>), findsNothing);
    },
  );

  testWidgets('reports controlled text-filter changes to the host', (
    tester,
  ) async {
    ReportCriteria? changed;
    await tester.pumpWidget(
      buildStudio(
        onCriteriaChanged: (value) => changed = value,
        onPresentationChanged: (_) {},
      ),
    );

    await tester.enterText(
      find.byKey(const ValueKey('report-filter-search')),
      'North region',
    );
    expect(
      (changed!.filters['search']! as ReportTextFilterValue).value,
      'North region',
    );
  });

  testWidgets(
    'exposes preview without owning navigation or request execution',
    (tester) async {
      var previewTapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReportConfigurationStudio(
              definition: definition,
              criteria: ReportCriteria(),
              presentation: ReportPresentationOptions(),
              resolveLabel: (_, key) => key,
              onCriteriaChanged: (_) {},
              onPresentationChanged: (_) {},
              onPreview: () => previewTapped = true,
            ),
          ),
        ),
      );
      final preview = find.text('report_configuration.preview');
      await tester.ensureVisible(preview);
      await tester.tap(preview);
      await tester.pump();
      expect(previewTapped, isTrue);
    },
  );
  testWidgets(
    'allows a date range start boundary to be selected before its end',
    (tester) async {
      ReportCriteria? changed;
      await tester.pumpWidget(
        buildStudio(
          onCriteriaChanged: (value) => changed = value,
          onPresentationChanged: (_) {},
        ),
      );

      await tester.enterText(
        find.byKey(const ValueKey('report-filter-period-start')),
        '2026-01-01',
      );

      final selected =
          changed!.filters['period']! as ReportDateRangeFilterValue;
      expect(selected.start, DateTime(2026, 1, 1));
      expect(selected.end, isNull);
    },
  );
}
