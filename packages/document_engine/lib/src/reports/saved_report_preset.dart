import '../core/stable_identifier.dart';
import 'report_criteria.dart';
import 'report_definition.dart';
import 'report_id.dart';
import 'report_presentation_options.dart';

enum ReportPresetCompatibilityStatus {
  current,
  reviewRequired,
  differentReport,
}

/// Result of comparing a saved preset with the current app-supplied schema.
///
/// A changed schema or removed option is surfaced for review. No fields are
/// silently dropped and this type does not attempt to migrate the preset.
final class ReportPresetCompatibility {
  const ReportPresetCompatibility({
    required this.status,
    this.criteriaIssues = const [],
    this.presentationIssues = const [],
  });

  final ReportPresetCompatibilityStatus status;
  final List<ReportCriteriaValidationIssue> criteriaIssues;
  final List<ReportPresentationValidationIssue> presentationIssues;

  bool get requiresReview => status != ReportPresetCompatibilityStatus.current;
}

/// User-owned report configuration only; it never stores report data rows,
/// authorization grants, tenant identity, tokens, signed URLs, or API payloads.
final class SavedReportPreset {
  SavedReportPreset({
    required String id,
    required String name,
    required this.reportId,
    required this.reportSchemaVersion,
    required this.criteria,
    required this.presentation,
    this.presetSchemaVersion = currentSchemaVersion,
  }) : id = validateStableIdentifier(id, parameterName: 'presetId'),
       name = _validateName(name) {
    if (presetSchemaVersion != currentSchemaVersion) {
      throw ArgumentError.value(
        presetSchemaVersion,
        'presetSchemaVersion',
        'Only schema version $currentSchemaVersion can be created.',
      );
    }
    if (reportSchemaVersion < 1) {
      throw ArgumentError.value(
        reportSchemaVersion,
        'reportSchemaVersion',
        'Must be positive.',
      );
    }
  }

  static const int currentSchemaVersion = 1;

  final String id;
  final String name;
  final ReportId reportId;
  final int presetSchemaVersion;
  final int reportSchemaVersion;
  final ReportCriteria criteria;
  final ReportPresentationOptions presentation;

  Map<String, Object?> toJson() => <String, Object?>{
    'preset_schema_version': presetSchemaVersion,
    'id': id,
    'name': name,
    'report_id': reportId.value,
    'report_schema_version': reportSchemaVersion,
    'criteria': criteria.toJson(),
    'presentation': presentation.toJson(),
  };

  factory SavedReportPreset.fromJson(Map<String, Object?> json) {
    const allowed = {
      'preset_schema_version',
      'id',
      'name',
      'report_id',
      'report_schema_version',
      'criteria',
      'presentation',
    };
    if (!_hasOnlyKeys(json, allowed) ||
        !json.keys.toSet().containsAll(allowed) ||
        json['preset_schema_version'] is! int ||
        json['id'] is! String ||
        json['name'] is! String ||
        json['report_id'] is! String ||
        json['report_schema_version'] is! int ||
        json['criteria'] is! Map<String, Object?> ||
        json['presentation'] is! Map<String, Object?>) {
      throw const FormatException(
        'Malformed or unsupported saved report preset.',
      );
    }

    final version = json['preset_schema_version'] as int;
    if (version != currentSchemaVersion) {
      throw FormatException(
        'Preset schema version $version requires an explicit migration/review.',
      );
    }

    return SavedReportPreset(
      id: json['id'] as String,
      name: json['name'] as String,
      reportId: ReportId(json['report_id'] as String),
      reportSchemaVersion: json['report_schema_version'] as int,
      presetSchemaVersion: version,
      criteria: ReportCriteria.fromJson(
        json['criteria'] as Map<String, Object?>,
      ),
      presentation: ReportPresentationOptions.fromJson(
        json['presentation'] as Map<String, Object?>,
      ),
    );
  }

  ReportPresetCompatibility assessAgainst(ReportDefinition definition) {
    if (reportId != definition.id) {
      return const ReportPresetCompatibility(
        status: ReportPresetCompatibilityStatus.differentReport,
      );
    }

    final criteriaIssues = criteria.validateAgainst(definition);
    final presentationIssues = presentation.validateAgainst(definition);
    final schemaChanged = reportSchemaVersion != definition.schemaVersion;
    final isCompatible =
        !schemaChanged && criteriaIssues.isEmpty && presentationIssues.isEmpty;

    return ReportPresetCompatibility(
      status: isCompatible
          ? ReportPresetCompatibilityStatus.current
          : ReportPresetCompatibilityStatus.reviewRequired,
      criteriaIssues: criteriaIssues,
      presentationIssues: presentationIssues,
    );
  }

  static String _validateName(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty || normalized.length > 120) {
      throw ArgumentError.value(
        value,
        'name',
        'Must contain 1-120 characters.',
      );
    }
    return normalized;
  }
}

bool _hasOnlyKeys(Map<String, Object?> value, Set<String> allowed) =>
    value.keys.every(allowed.contains);
