import 'package:document_engine/document_engine.dart';
import 'package:netsales/features/reports/domain/entities/operational_report_catalog.dart';
import 'package:netsales/features/reports/domain/entities/operational_report_type.dart';

class OperationalReportCatalogModel extends OperationalReportCatalog {
  OperationalReportCatalogModel({
    required super.schemaVersion,
    required super.entries,
  });

  factory OperationalReportCatalogModel.fromJson(dynamic json) {
    if (json is! Map) {
      throw const FormatException('تنسيق كتالوج التقارير غير صالح.');
    }
    final rawReports = json['reports'];
    if (rawReports is! List) {
      throw const FormatException('قائمة تعريفات التقارير غير صالحة.');
    }

    final entries = <OperationalReportCatalogEntry>[];
    for (final raw in rawReports) {
      if (raw is! Map) {
        throw const FormatException('يوجد تعريف تقرير غير صالح.');
      }
      final rawDefinition = Map<String, dynamic>.from(raw);
      final type = _reportType(rawDefinition['id']?.toString() ?? '');
      if (type == null) {
        throw FormatException('نوع تقرير غير معروف في كتالوج الخادم: ${rawDefinition['id']}');
      }
      entries.add(_parseEntry(type, rawDefinition));
    }

    final ids = entries.map((entry) => entry.definition.id.value).toSet();
    if (ids.length != entries.length) {
      throw const FormatException('يحتوي كتالوج التقارير على معرفات مكررة.');
    }

    return OperationalReportCatalogModel(
      schemaVersion: (json['schema_version'] as num?)?.toInt() ?? 1,
      entries: List<OperationalReportCatalogEntry>.unmodifiable(entries),
    );
  }

  static OperationalReportCatalogEntry _parseEntry(
    OperationalReportType type,
    Map<String, dynamic> raw,
  ) {
    final id = _requiredText(raw['id'], 'id');
    final schemaVersion = _positiveInt(raw['schema_version'], 'schema_version');
    final titleKey = _requiredText(raw['title_key'], 'title_key');

    final rawFilters = _requiredList(raw['filters'], 'filters');
    final filterDefinitions = <ReportFilterDefinition>[];
    final filterLabels = <String, String>{};
    for (final rawFilter in rawFilters) {
      if (rawFilter is! Map) {
        throw const FormatException('تعريف مرشح التقرير غير صالح.');
      }
      final filter = Map<String, dynamic>.from(rawFilter);
      final filterId = _requiredText(filter['id'], 'filter.id');
      final kind = _filterKind(_requiredText(filter['kind'], 'filter.kind'));
      final choices = _stringList(filter['choices'], 'filter.choices');
      filterDefinitions.add(
        ReportFilterDefinition(
          id: filterId,
          labelKey: filterId,
          kind: kind,
          required: filter['required'] == true,
          maxLength: (filter['max_length'] as num?)?.toInt(),
          choices: choices.map(
            (value) => ReportChoiceOption(
              value: value,
              labelKey: '$filterId.$value',
            ),
          ),
        ),
      );
      filterLabels[filterId] = _requiredText(
        filter['label'],
        'filter.label',
      );
    }

    final rawColumns = _requiredList(raw['columns'], 'columns');
    final columnDefinitions = <ReportColumnDefinition>[];
    final columnLabels = <String, String>{};
    for (final rawColumn in rawColumns) {
      if (rawColumn is! Map) {
        throw const FormatException('تعريف عمود التقرير غير صالح.');
      }
      final column = Map<String, dynamic>.from(rawColumn);
      final columnId = _requiredText(column['id'], 'column.id');
      columnDefinitions.add(
        ReportColumnDefinition(
          id: columnId,
          labelKey: columnId,
          dataType: _dataType(
            _requiredText(column['data_type'], 'column.data_type'),
          ),
          visibleByDefault: column['visible_by_default'] != false,
          hideable: column['hideable'] != false,
          sortable: column['sortable'] == true,
          groupable: column['groupable'] == true,
        ),
      );
      columnLabels[columnId] = _requiredText(
        column['label'],
        'column.label',
      );
    }

    final rawMetrics = _requiredList(raw['metric_slots'], 'metric_slots');
    final metricDefinitions = <ReportMetricSlotDefinition>[];
    final metricLabels = <String, String>{};
    for (final rawMetric in rawMetrics) {
      if (rawMetric is! Map) {
        throw const FormatException('تعريف مؤشر التقرير غير صالح.');
      }
      final metric = Map<String, dynamic>.from(rawMetric);
      final metricId = _requiredText(metric['id'], 'metric.id');
      metricDefinitions.add(
        ReportMetricSlotDefinition(
          id: metricId,
          labelKey: metricId,
          dataType: _dataType(
            _requiredText(metric['data_type'], 'metric.data_type'),
          ),
        ),
      );
      metricLabels[metricId] = _requiredText(
        metric['label'],
        'metric.label',
      );
    }

    final rawTemplates = _requiredList(raw['templates'], 'templates');
    final templates = <ReportTemplateReference>[];
    for (final rawTemplate in rawTemplates) {
      if (rawTemplate is! Map) {
        throw const FormatException('مرجع قالب التقرير غير صالح.');
      }
      final template = Map<String, dynamic>.from(rawTemplate);
      templates.add(
        ReportTemplateReference(
          id: TemplateId(_requiredText(template['id'], 'template.id')),
          version: _templateVersion(
            _requiredText(template['version'], 'template.version'),
          ),
        ),
      );
    }

    final permissions = raw['permissions'];
    if (permissions is! Map) {
      throw const FormatException('صلاحيات التقرير غير صالحة.');
    }
    final scopes = _stringList(raw['supported_scopes'], 'supported_scopes');
    final rawCharts = raw['chart_slots'];
    final charts = <OperationalReportChartSlot>[];
    if (rawCharts is List) {
      for (final rawChart in rawCharts) {
        if (rawChart is! Map) {
          throw const FormatException('تعريف مخطط التقرير غير صالح.');
        }
        final chart = Map<String, dynamic>.from(rawChart);
        charts.add(
          OperationalReportChartSlot(
            id: _requiredText(chart['id'], 'chart.id'),
            label: _requiredText(chart['label'], 'chart.label'),
            chartType: _requiredText(chart['chart_type'], 'chart.chart_type'),
            valueKey: _requiredText(chart['value_key'], 'chart.value_key'),
            labelKey: _requiredText(chart['label_key'], 'chart.label_key'),
          ),
        );
      }
    }

    final definition = ReportDefinition(
      id: ReportId(id),
      schemaVersion: schemaVersion,
      titleKey: titleKey,
      descriptionKey: '$id.description',
      supportedLocaleTags: const ['ar'],
      filters: filterDefinitions,
      columns: columnDefinitions,
      metricSlots: metricDefinitions,
      templates: templates,
      pageProfileIds: _stringList(
        raw['page_profile_ids'],
        'page_profile_ids',
      ),
      executionPolicy: _executionPolicy(
        _requiredText(raw['execution_policy'], 'execution_policy'),
      ),
      clientRowLimit: (raw['client_row_limit'] as num?)?.toInt(),
      chartsAvailable: raw['charts_available'] == true,
    );

    final access = OperationalReportAccess(
      available: raw['available'] == true,
      viewPermission: _requiredText(permissions['view'], 'permissions.view'),
      exportPermission: _requiredText(
        permissions['export'],
        'permissions.export',
      ),
      supportedScopes: scopes,
      posSelection: _requiredText(raw['pos_selection'], 'pos_selection'),
      unavailableReason: raw['unavailable_reason']?.toString(),
    );

    return OperationalReportCatalogEntry(
      type: type,
      label: _requiredText(raw['label'], 'label'),
      description: _requiredText(raw['description'], 'description'),
      definition: definition,
      access: access,
      chartSlots: List<OperationalReportChartSlot>.unmodifiable(charts),
      filterLabels: Map<String, String>.unmodifiable(filterLabels),
      columnLabels: Map<String, String>.unmodifiable(columnLabels),
      metricLabels: Map<String, String>.unmodifiable(metricLabels),
    );
  }

  static OperationalReportType? _reportType(String wireValue) {
    for (final type in OperationalReportType.values) {
      if (type.wireValue == wireValue) return type;
    }
    return null;
  }

  static ReportFilterKind _filterKind(String value) => switch (value) {
    'text' => ReportFilterKind.text,
    'integer' => ReportFilterKind.integer,
    'decimal' => ReportFilterKind.decimal,
    'date' => ReportFilterKind.date,
    'date_range' => ReportFilterKind.dateRange,
    'boolean' => ReportFilterKind.boolean,
    'single_choice' => ReportFilterKind.singleChoice,
    'multi_choice' => ReportFilterKind.multiChoice,
    _ => throw FormatException('نوع مرشح غير مدعوم: $value'),
  };

  static ReportDataType _dataType(String value) => switch (value) {
    'text' => ReportDataType.text,
    'integer' => ReportDataType.integer,
    'decimal' || 'currency' => ReportDataType.decimal,
    'date' || 'datetime' => ReportDataType.date,
    'boolean' => ReportDataType.boolean,
    _ => throw FormatException('نوع عمود غير مدعوم: $value'),
  };

  static ReportExecutionPolicy _executionPolicy(String value) => switch (
    value
  ) {
    'client' => ReportExecutionPolicy.client,
    'server' => ReportExecutionPolicy.server,
    'either' => ReportExecutionPolicy.either,
    _ => throw FormatException('سياسة تنفيذ التقرير غير مدعومة: $value'),
  };

  static TemplateVersion _templateVersion(String value) {
    final match = RegExp(r'^(\d+)\.(\d+)\.(\d+)$').firstMatch(value);
    if (match == null) {
      throw FormatException('إصدار قالب غير صالح: $value');
    }
    return TemplateVersion(
      major: int.parse(match.group(1)!),
      minor: int.parse(match.group(2)!),
      patch: int.parse(match.group(3)!),
    );
  }

  static List<dynamic> _requiredList(dynamic value, String field) {
    if (value is! List) {
      throw FormatException('قائمة $field غير صالحة.');
    }
    return value;
  }

  static List<String> _stringList(dynamic value, String field) {
    if (value == null) return const [];
    if (value is! List || value.any((item) => item is! String)) {
      throw FormatException('قائمة $field غير صالحة.');
    }
    return value.cast<String>();
  }

  static String _requiredText(dynamic value, String field) {
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('حقل $field مطلوب.');
    }
    return value.trim();
  }

  static int _positiveInt(dynamic value, String field) {
    if (value is! num || value < 1) {
      throw FormatException('حقل $field يجب أن يكون عدداً موجباً.');
    }
    return value.toInt();
  }
}
