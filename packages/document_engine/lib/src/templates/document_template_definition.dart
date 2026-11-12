import '../core/document_type_id.dart';
import '../core/template_id.dart';
import '../core/template_version.dart';
import 'template_capabilities.dart';

/// PDF composition strategy selected by a concrete template.
enum DocumentTemplateLayout { standard, executive, compact, receipt }

/// Immutable metadata describing one exact template version.
final class DocumentTemplateDefinition {
  DocumentTemplateDefinition({
    required this.id,
    required this.version,
    required this.documentTypeId,
    required String displayName,
    required Iterable<String> supportedLocaleTags,
    required this.capabilities,
    this.description,
    this.isDefault = false,
    this.layout = DocumentTemplateLayout.standard,
  }) : displayName = _requireText(displayName, 'displayName'),
       supportedLocaleTags = _normalizeLocaleTags(supportedLocaleTags);

  final TemplateId id;
  final TemplateVersion version;
  final DocumentTypeId documentTypeId;
  final String displayName;
  final String? description;
  final Set<String> supportedLocaleTags;
  final TemplateCapabilities capabilities;
  final bool isDefault;

  /// Controls real renderer composition, not merely template metadata.
  final DocumentTemplateLayout layout;

  String get versionedKey => '${id.value}@$version';

  bool supportsLocale(String languageTag) {
    if (supportedLocaleTags.isEmpty) return true;
    final normalized = languageTag.toLowerCase();
    return supportedLocaleTags.any((supported) {
      final candidate = supported.toLowerCase();
      return normalized == candidate || normalized.startsWith('$candidate-');
    });
  }

  static String _requireText(String value, String name) {
    if (value.trim().isEmpty) {
      throw ArgumentError.value(value, name, 'Must not be empty.');
    }
    return value;
  }

  static Set<String> _normalizeLocaleTags(Iterable<String> values) {
    final normalized = <String>{};
    for (final value in values) {
      final tag = value.trim();
      if (!RegExp(r'^[A-Za-z]{2,8}(?:-[A-Za-z0-9]{1,8})*$').hasMatch(tag)) {
        throw ArgumentError.value(
          value,
          'supportedLocaleTags',
          'Contains an invalid language tag.',
        );
      }
      normalized.add(tag);
    }
    return Set<String>.unmodifiable(normalized);
  }
}
