import '../core/template_id.dart';
import '../core/template_version.dart';
import 'report_definition.dart';

enum ReportSortDirection { ascending, descending }

final class ReportSortOption {
  const ReportSortOption({required this.fieldId, required this.direction});

  final String fieldId;
  final ReportSortDirection direction;

  Map<String, Object?> toJson() => <String, Object?>{
    'field_id': fieldId,
    'direction': direction.name,
  };

  factory ReportSortOption.fromJson(Map<String, Object?> json) {
    if (!_hasOnlyKeys(json, const {'field_id', 'direction'}) ||
        json['field_id'] is! String ||
        json['direction'] is! String) {
      throw const FormatException('Malformed report sort option.');
    }
    return ReportSortOption(
      fieldId: json['field_id'] as String,
      direction: ReportSortDirection.values.byName(json['direction'] as String),
    );
  }
}

final class ReportTemplateSelection {
  const ReportTemplateSelection({required this.id, required this.version});

  final TemplateId id;
  final TemplateVersion version;

  ReportTemplateReference get reference =>
      ReportTemplateReference(id: id, version: version);

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id.value,
    'version': <String, int>{
      'major': version.major,
      'minor': version.minor,
      'patch': version.patch,
    },
  };

  factory ReportTemplateSelection.fromJson(Map<String, Object?> json) {
    if (!_hasOnlyKeys(json, const {'id', 'version'}) ||
        json['id'] is! String ||
        json['version'] is! Map<String, Object?>) {
      throw const FormatException('Malformed report template selection.');
    }
    final version = json['version'] as Map<String, Object?>;
    if (!_hasOnlyKeys(version, const {'major', 'minor', 'patch'}) ||
        version['major'] is! int ||
        version['minor'] is! int ||
        version['patch'] is! int) {
      throw const FormatException('Malformed report template version.');
    }
    return ReportTemplateSelection(
      id: TemplateId(json['id'] as String),
      version: TemplateVersion(
        major: version['major'] as int,
        minor: version['minor'] as int,
        patch: version['patch'] as int,
      ),
    );
  }
}

final class ReportPresentationValidationIssue {
  const ReportPresentationValidationIssue({
    required this.code,
    required this.fieldId,
  });

  final String code;
  final String fieldId;
}

/// Presentation choices only. This object must never be treated as permission
/// to request fields, group data, or access any report endpoint.
final class ReportPresentationOptions {
  ReportPresentationOptions({
    Iterable<String> visibleColumnIds = const [],
    Iterable<ReportSortOption> sorts = const [],
    this.groupByFieldId,
    this.template,
    this.languageTag,
    this.pageProfileId,
    this.includeMetrics = false,
    this.includeCharts = false,
  }) : visibleColumnIds = List<String>.unmodifiable(visibleColumnIds),
       sorts = List<ReportSortOption>.unmodifiable(sorts) {
    if (this.visibleColumnIds.toSet().length != this.visibleColumnIds.length) {
      throw ArgumentError('Visible column IDs cannot contain duplicates.');
    }
    if (this.sorts.map((sort) => sort.fieldId).toSet().length !=
        this.sorts.length) {
      throw ArgumentError('A column may occur only once in the sort order.');
    }
  }

  final List<String> visibleColumnIds;
  final List<ReportSortOption> sorts;
  final String? groupByFieldId;
  final ReportTemplateSelection? template;
  final String? languageTag;
  final String? pageProfileId;
  final bool includeMetrics;
  final bool includeCharts;

  Map<String, Object?> toJson() => <String, Object?>{
    'visible_column_ids': visibleColumnIds,
    'sorts': sorts.map((sort) => sort.toJson()).toList(growable: false),
    'group_by_field_id': groupByFieldId,
    'template': template?.toJson(),
    'language_tag': languageTag,
    'page_profile_id': pageProfileId,
    'include_metrics': includeMetrics,
    'include_charts': includeCharts,
  };

  factory ReportPresentationOptions.fromJson(Map<String, Object?> json) {
    const keys = {
      'visible_column_ids',
      'sorts',
      'group_by_field_id',
      'template',
      'language_tag',
      'page_profile_id',
      'include_metrics',
      'include_charts',
    };
    if (!_hasOnlyKeys(json, keys) ||
        json['visible_column_ids'] is! List<Object?> ||
        !(json['visible_column_ids'] as List<Object?>).every(
          (item) => item is String,
        ) ||
        json['sorts'] is! List<Object?> ||
        !(json['sorts'] as List<Object?>).every(
          (item) => item is Map<String, Object?>,
        ) ||
        (json['group_by_field_id'] != null &&
            json['group_by_field_id'] is! String) ||
        (json['template'] != null &&
            json['template'] is! Map<String, Object?>) ||
        (json['language_tag'] != null && json['language_tag'] is! String) ||
        (json['page_profile_id'] != null &&
            json['page_profile_id'] is! String) ||
        json['include_metrics'] is! bool ||
        json['include_charts'] is! bool) {
      throw const FormatException('Malformed report presentation options.');
    }

    return ReportPresentationOptions(
      visibleColumnIds: (json['visible_column_ids'] as List<Object?>)
          .cast<String>(),
      sorts: (json['sorts'] as List<Object?>).map(
        (item) => ReportSortOption.fromJson(item as Map<String, Object?>),
      ),
      groupByFieldId: json['group_by_field_id'] as String?,
      template: json['template'] == null
          ? null
          : ReportTemplateSelection.fromJson(
              json['template'] as Map<String, Object?>,
            ),
      languageTag: json['language_tag'] as String?,
      pageProfileId: json['page_profile_id'] as String?,
      includeMetrics: json['include_metrics'] as bool,
      includeCharts: json['include_charts'] as bool,
    );
  }

  List<ReportPresentationValidationIssue> validateAgainst(
    ReportDefinition definition,
  ) {
    final issues = <ReportPresentationValidationIssue>[];
    final columns = definition.columns;

    final effectiveVisibleIds = visibleColumnIds.isEmpty
        ? definition.columns
              .where((column) => column.visibleByDefault)
              .map((column) => column.id)
              .toSet()
        : visibleColumnIds.toSet();

    for (final id in visibleColumnIds) {
      if (definition.column(id) == null) {
        issues.add(
          ReportPresentationValidationIssue(
            code: 'unknown_column',
            fieldId: id,
          ),
        );
      }
    }

    for (final column in columns.where((item) => !item.hideable)) {
      if (!effectiveVisibleIds.contains(column.id)) {
        issues.add(
          ReportPresentationValidationIssue(
            code: 'required_column_hidden',
            fieldId: column.id,
          ),
        );
      }
    }

    for (final sort in sorts) {
      final column = definition.column(sort.fieldId);
      if (column == null) {
        issues.add(
          ReportPresentationValidationIssue(
            code: 'unknown_sort_column',
            fieldId: sort.fieldId,
          ),
        );
      } else if (!column.sortable) {
        issues.add(
          ReportPresentationValidationIssue(
            code: 'sorting_not_allowed',
            fieldId: sort.fieldId,
          ),
        );
      }
    }

    if (groupByFieldId != null) {
      final column = definition.column(groupByFieldId!);
      if (column == null) {
        issues.add(
          ReportPresentationValidationIssue(
            code: 'unknown_group_column',
            fieldId: groupByFieldId!,
          ),
        );
      } else if (!column.groupable) {
        issues.add(
          ReportPresentationValidationIssue(
            code: 'grouping_not_allowed',
            fieldId: groupByFieldId!,
          ),
        );
      }
    }

    if (template != null &&
        !definition.templates.contains(template!.reference)) {
      issues.add(
        ReportPresentationValidationIssue(
          code: 'template_not_allowed',
          fieldId: template!.reference.key,
        ),
      );
    }
    if (languageTag != null && !definition.supportsLocale(languageTag!)) {
      issues.add(
        ReportPresentationValidationIssue(
          code: 'locale_not_allowed',
          fieldId: languageTag!,
        ),
      );
    }
    if (pageProfileId != null &&
        !definition.pageProfileIds.contains(pageProfileId)) {
      issues.add(
        ReportPresentationValidationIssue(
          code: 'page_profile_not_allowed',
          fieldId: pageProfileId!,
        ),
      );
    }
    if (includeMetrics && definition.metricSlots.isEmpty) {
      issues.add(
        const ReportPresentationValidationIssue(
          code: 'metrics_not_available',
          fieldId: 'metrics',
        ),
      );
    }
    if (includeCharts && !definition.chartsAvailable) {
      issues.add(
        const ReportPresentationValidationIssue(
          code: 'charts_not_available',
          fieldId: 'charts',
        ),
      );
    }

    issues.sort((a, b) {
      final fieldOrder = a.fieldId.compareTo(b.fieldId);
      return fieldOrder != 0 ? fieldOrder : a.code.compareTo(b.code);
    });
    return List<ReportPresentationValidationIssue>.unmodifiable(issues);
  }
}

bool _hasOnlyKeys(Map<String, Object?> value, Set<String> allowed) =>
    value.keys.every(allowed.contains);
