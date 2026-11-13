import '../core/stable_identifier.dart';
import '../core/template_id.dart';
import '../core/template_version.dart';
import 'report_id.dart';

enum ReportFilterKind {
  text,
  integer,
  decimal,
  date,
  dateRange,
  boolean,
  singleChoice,
  multiChoice,
}

enum ReportDataType { text, integer, decimal, date, dateTime, boolean }

enum ReportExecutionPolicy { client, server, either }

final class ReportChoiceOption {
  ReportChoiceOption({required this.value, required this.labelKey}) {
    if (value.isEmpty || value != value.trim() || value.length > 128) {
      throw ArgumentError.value(
        value,
        'value',
        'Must be 1-128 trimmed characters.',
      );
    }
    _requireKey(labelKey, 'labelKey');
  }

  final String value;
  final String labelKey;
}

final class ReportFilterDefinition {
  ReportFilterDefinition({
    required this.id,
    required this.labelKey,
    required this.kind,
    this.required = false,
    this.minLength,
    this.maxLength,
    Iterable<ReportChoiceOption> choices = const [],
  }) : choices = List<ReportChoiceOption>.unmodifiable(choices) {
    _validateStableField(id, 'filterId');
    _requireKey(labelKey, 'labelKey');
    if (minLength != null && minLength! < 0) {
      throw ArgumentError.value(
        minLength,
        'minLength',
        'Must not be negative.',
      );
    }
    if (maxLength != null && maxLength! < 1) {
      throw ArgumentError.value(maxLength, 'maxLength', 'Must be positive.');
    }
    if (minLength != null && maxLength != null && minLength! > maxLength!) {
      throw ArgumentError('minLength cannot exceed maxLength.');
    }
    if (kind != ReportFilterKind.text &&
        (minLength != null || maxLength != null)) {
      throw ArgumentError('Length constraints apply only to text filters.');
    }
    final choiceValues = this.choices.map((item) => item.value).toSet();
    if (choiceValues.length != this.choices.length) {
      throw ArgumentError('Choice values must be unique within a filter.');
    }
    final isChoice =
        kind == ReportFilterKind.singleChoice ||
        kind == ReportFilterKind.multiChoice;
    if (isChoice != this.choices.isNotEmpty) {
      throw ArgumentError(
        'Choice filters require options; other filters must not declare them.',
      );
    }
  }

  final String id;
  final String labelKey;
  final ReportFilterKind kind;
  final bool required;
  final int? minLength;
  final int? maxLength;
  final List<ReportChoiceOption> choices;
}

final class ReportColumnDefinition {
  ReportColumnDefinition({
    required this.id,
    required this.labelKey,
    required this.dataType,
    this.visibleByDefault = true,
    this.hideable = true,
    this.sortable = false,
    this.groupable = false,
  }) {
    _validateStableField(id, 'columnId');
    _requireKey(labelKey, 'labelKey');
    if (!hideable && !visibleByDefault) {
      throw ArgumentError('A non-hideable column must be visible by default.');
    }
  }

  final String id;
  final String labelKey;
  final ReportDataType dataType;
  final bool visibleByDefault;
  final bool hideable;
  final bool sortable;
  final bool groupable;
}

final class ReportMetricSlotDefinition {
  ReportMetricSlotDefinition({
    required this.id,
    required this.labelKey,
    required this.dataType,
    this.unitLabelKey,
  }) {
    _validateStableField(id, 'metricSlotId');
    _requireKey(labelKey, 'labelKey');
    if (unitLabelKey != null) _requireKey(unitLabelKey!, 'unitLabelKey');
  }

  final String id;
  final String labelKey;
  final ReportDataType dataType;
  final String? unitLabelKey;
}

final class ReportTemplateReference {
  const ReportTemplateReference({required this.id, required this.version});
  final TemplateId id;
  final TemplateVersion version;

  String get key => '${id.value}@$version';

  @override
  bool operator ==(Object other) =>
      other is ReportTemplateReference &&
      other.id == id &&
      other.version == version;

  @override
  int get hashCode => Object.hash(id, version);
}

/// Application-supplied allowlist of report capabilities and selectable fields.
///
/// This schema describes what the UI may configure. It is not an API request,
/// permission grant, or query language; Laravel remains authoritative.
final class ReportDefinition {
  ReportDefinition({
    required this.id,
    required this.schemaVersion,
    required this.titleKey,
    required Iterable<String> supportedLocaleTags,
    required Iterable<ReportFilterDefinition> filters,
    required Iterable<ReportColumnDefinition> columns,
    Iterable<ReportMetricSlotDefinition> metricSlots = const [],
    Iterable<ReportTemplateReference> templates = const [],
    Iterable<String> pageProfileIds = const [],
    this.descriptionKey,
    this.executionPolicy = ReportExecutionPolicy.server,
    this.clientRowLimit,
    this.chartsAvailable = false,
  }) : supportedLocaleTags = _normalizeLocales(supportedLocaleTags),
       filters = List<ReportFilterDefinition>.unmodifiable(filters),
       columns = List<ReportColumnDefinition>.unmodifiable(columns),
       metricSlots = List<ReportMetricSlotDefinition>.unmodifiable(metricSlots),
       templates = List<ReportTemplateReference>.unmodifiable(templates),
       pageProfileIds = _normalizeIds(pageProfileIds, 'pageProfileIds') {
    if (schemaVersion < 1) {
      throw ArgumentError.value(
        schemaVersion,
        'schemaVersion',
        'Must be positive.',
      );
    }
    _requireKey(titleKey, 'titleKey');
    if (descriptionKey != null) _requireKey(descriptionKey!, 'descriptionKey');
    if (this.supportedLocaleTags.isEmpty) {
      throw ArgumentError('At least one supported locale is required.');
    }
    if (this.columns.isEmpty) {
      throw ArgumentError(
        'A report definition requires at least one output column.',
      );
    }
    _ensureUnique(this.filters.map((item) => item.id), 'filter IDs');
    _ensureUnique(this.columns.map((item) => item.id), 'column IDs');
    _ensureUnique(this.metricSlots.map((item) => item.id), 'metric slot IDs');
    _ensureUnique(
      this.templates.map((item) => item.key),
      'template references',
    );
    final hasClientPath =
        executionPolicy == ReportExecutionPolicy.client ||
        executionPolicy == ReportExecutionPolicy.either;
    if (clientRowLimit != null && clientRowLimit! < 1) {
      throw ArgumentError.value(
        clientRowLimit,
        'clientRowLimit',
        'Must be positive.',
      );
    }
    if (hasClientPath && clientRowLimit == null) {
      throw ArgumentError(
        'Client-capable reports require an explicit clientRowLimit.',
      );
    }
  }

  final ReportId id;
  final int schemaVersion;
  final String titleKey;
  final String? descriptionKey;
  final Set<String> supportedLocaleTags;
  final List<ReportFilterDefinition> filters;
  final List<ReportColumnDefinition> columns;
  final List<ReportMetricSlotDefinition> metricSlots;
  final List<ReportTemplateReference> templates;
  final List<String> pageProfileIds;
  final ReportExecutionPolicy executionPolicy;
  final int? clientRowLimit;
  final bool chartsAvailable;

  ReportFilterDefinition? filter(String id) {
    for (final value in filters) {
      if (value.id == id) return value;
    }
    return null;
  }

  ReportColumnDefinition? column(String id) {
    for (final value in columns) {
      if (value.id == id) return value;
    }
    return null;
  }

  bool supportsLocale(String languageTag) {
    final normalized = languageTag.toLowerCase();
    return supportedLocaleTags.any((tag) {
      final candidate = tag.toLowerCase();
      return normalized == candidate || normalized.startsWith('$candidate-');
    });
  }

  List<String> get sortableColumnIds => List<String>.unmodifiable(
    columns.where((column) => column.sortable).map((column) => column.id),
  );

  List<String> get groupableColumnIds => List<String>.unmodifiable(
    columns.where((column) => column.groupable).map((column) => column.id),
  );
}

void _validateStableField(String value, String name) =>
    validateStableIdentifier(value, parameterName: name);

void _requireKey(String value, String name) {
  if (value.trim().isEmpty || value != value.trim()) {
    throw ArgumentError.value(value, name, 'Must be non-empty and trimmed.');
  }
}

void _ensureUnique(Iterable<String> values, String name) {
  final list = values.toList(growable: false);
  if (list.toSet().length != list.length) {
    throw ArgumentError('Duplicate $name are not allowed.');
  }
}

Set<String> _normalizeLocales(Iterable<String> values) {
  final result = <String>{};
  for (final value in values) {
    final tag = value.trim();
    if (tag != value ||
        !RegExp(r'^[A-Za-z]{2,8}(?:-[A-Za-z0-9]{1,8})*$').hasMatch(tag)) {
      throw ArgumentError.value(
        value,
        'supportedLocaleTags',
        'Invalid language tag.',
      );
    }
    result.add(tag);
  }
  return Set<String>.unmodifiable(result);
}

List<String> _normalizeIds(Iterable<String> values, String name) {
  final result = values
      .map((value) {
        validateStableIdentifier(value, parameterName: name);
        return value;
      })
      .toList(growable: false);
  _ensureUnique(result, name);
  return List<String>.unmodifiable(result);
}
