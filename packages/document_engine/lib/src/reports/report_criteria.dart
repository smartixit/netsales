import 'report_definition.dart';
import 'report_filter_value.dart';

final class ReportCriteriaValidationIssue {
  const ReportCriteriaValidationIssue({
    required this.code,
    required this.fieldId,
  });

  final String code;
  final String fieldId;

  @override
  bool operator ==(Object other) =>
      other is ReportCriteriaValidationIssue &&
      other.code == code &&
      other.fieldId == fieldId;

  @override
  int get hashCode => Object.hash(code, fieldId);
}

/// Only user-selected filter values. Result rows are never part of criteria.
final class ReportCriteria {
  ReportCriteria({Map<String, ReportFilterValue> filters = const {}})
    : filters = Map<String, ReportFilterValue>.unmodifiable(filters) {
    for (final id in this.filters.keys) {
      if (id.isEmpty || id != id.trim()) {
        throw ArgumentError.value(
          id,
          'filters',
          'Filter identifiers must be trimmed.',
        );
      }
    }
  }

  final Map<String, ReportFilterValue> filters;

  Map<String, Object?> toJson() => <String, Object?>{
    'filters': filters.map((key, value) => MapEntry(key, value.toJson())),
  };

  factory ReportCriteria.fromJson(Map<String, Object?> json) {
    if (!_hasOnlyKeys(json, const {'filters'}) ||
        json['filters'] is! Map<String, Object?>) {
      throw const FormatException('Malformed report criteria object.');
    }
    final rawFilters = json['filters'] as Map<String, Object?>;
    final parsed = <String, ReportFilterValue>{};
    for (final entry in rawFilters.entries) {
      parsed[entry.key] = ReportFilterValue.fromJson(entry.value);
    }
    return ReportCriteria(filters: parsed);
  }

  List<ReportCriteriaValidationIssue> validateAgainst(
    ReportDefinition definition,
  ) {
    final issues = <ReportCriteriaValidationIssue>[];
    for (final entry in filters.entries) {
      final definitionFilter = definition.filter(entry.key);
      if (definitionFilter == null) {
        issues.add(
          ReportCriteriaValidationIssue(
            code: 'unknown_filter',
            fieldId: entry.key,
          ),
        );
        continue;
      }

      final value = entry.value;
      if (!_matchesKind(definitionFilter.kind, value)) {
        issues.add(
          ReportCriteriaValidationIssue(
            code: 'filter_type_mismatch',
            fieldId: entry.key,
          ),
        );
        continue;
      }

      if (value is ReportTextFilterValue) {
        if (definitionFilter.minLength != null &&
            value.value.length < definitionFilter.minLength!) {
          issues.add(
            ReportCriteriaValidationIssue(
              code: 'text_too_short',
              fieldId: entry.key,
            ),
          );
        }
        if (definitionFilter.maxLength != null &&
            value.value.length > definitionFilter.maxLength!) {
          issues.add(
            ReportCriteriaValidationIssue(
              code: 'text_too_long',
              fieldId: entry.key,
            ),
          );
        }
      }

      if (value is ReportChoiceFilterValue &&
          !definitionFilter.choices.any(
            (option) => option.value == value.value,
          )) {
        issues.add(
          ReportCriteriaValidationIssue(
            code: 'choice_not_allowed',
            fieldId: entry.key,
          ),
        );
      }
      if (value is ReportChoicesFilterValue &&
          value.values.any(
            (selected) => !definitionFilter.choices.any(
              (option) => option.value == selected,
            ),
          )) {
        issues.add(
          ReportCriteriaValidationIssue(
            code: 'choice_not_allowed',
            fieldId: entry.key,
          ),
        );
      }
    }

    for (final filter in definition.filters) {
      if (filter.required && !filters.containsKey(filter.id)) {
        issues.add(
          ReportCriteriaValidationIssue(
            code: 'required_filter_missing',
            fieldId: filter.id,
          ),
        );
      }
    }

    // Keep deterministic issue ordering for stable form rendering and tests.
    issues.sort((a, b) {
      final fieldOrder = a.fieldId.compareTo(b.fieldId);
      return fieldOrder != 0 ? fieldOrder : a.code.compareTo(b.code);
    });
    return List<ReportCriteriaValidationIssue>.unmodifiable(issues);
  }
}

bool _matchesKind(ReportFilterKind kind, ReportFilterValue value) =>
    switch (kind) {
      ReportFilterKind.text => value is ReportTextFilterValue,
      ReportFilterKind.integer => value is ReportIntegerFilterValue,
      ReportFilterKind.decimal => value is ReportDecimalFilterValue,
      ReportFilterKind.date => value is ReportDateFilterValue,
      ReportFilterKind.dateRange => value is ReportDateRangeFilterValue,
      ReportFilterKind.boolean => value is ReportBooleanFilterValue,
      ReportFilterKind.singleChoice => value is ReportChoiceFilterValue,
      ReportFilterKind.multiChoice => value is ReportChoicesFilterValue,
    };

bool _hasOnlyKeys(Map<String, Object?> value, Set<String> allowed) =>
    value.keys.every(allowed.contains);
