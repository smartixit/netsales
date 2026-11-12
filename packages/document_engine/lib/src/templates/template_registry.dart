import '../core/document_type_id.dart';
import '../core/template_id.dart';
import '../core/template_version.dart';
import 'document_template_definition.dart';

/// In-memory registry of exact immutable template definitions.
final class TemplateRegistry {
  final Map<TemplateId, Map<TemplateVersion, DocumentTemplateDefinition>>
  _definitions = {};

  void register(DocumentTemplateDefinition definition) {
    final versions = _definitions.putIfAbsent(
      definition.id,
      () => <TemplateVersion, DocumentTemplateDefinition>{},
    );

    if (versions.containsKey(definition.version)) {
      throw StateError(
        'Template ${definition.versionedKey} is already registered.',
      );
    }

    if (definition.isDefault &&
        _definitions.values
            .expand((items) => items.values)
            .any(
              (existing) =>
                  existing.documentTypeId == definition.documentTypeId &&
                  existing.isDefault,
            )) {
      throw StateError(
        'A default template is already registered for '
        '${definition.documentTypeId}.',
      );
    }

    versions[definition.version] = definition;
  }

  DocumentTemplateDefinition? find({
    required TemplateId id,
    required TemplateVersion version,
  }) => _definitions[id]?[version];

  DocumentTemplateDefinition require({
    required TemplateId id,
    required TemplateVersion version,
  }) {
    final definition = find(id: id, version: version);
    if (definition == null) {
      throw StateError('Template $id@$version is not registered.');
    }
    return definition;
  }

  DocumentTemplateDefinition? findDefault({
    required DocumentTypeId documentTypeId,
  }) {
    for (final versions in _definitions.values) {
      for (final definition in versions.values) {
        if (definition.documentTypeId == documentTypeId &&
            definition.isDefault) {
          return definition;
        }
      }
    }
    return null;
  }

  List<DocumentTemplateDefinition> versionsOf(TemplateId id) {
    final versions = _definitions[id];
    if (versions == null) return const [];
    final result = versions.values.toList()
      ..sort((a, b) => a.version.compareTo(b.version));
    return List<DocumentTemplateDefinition>.unmodifiable(result);
  }

  List<DocumentTemplateDefinition> forDocumentType(
    DocumentTypeId documentTypeId,
  ) {
    final result = <DocumentTemplateDefinition>[];
    for (final versions in _definitions.values) {
      for (final definition in versions.values) {
        if (definition.documentTypeId == documentTypeId) result.add(definition);
      }
    }
    result.sort((a, b) {
      final idOrder = a.id.compareTo(b.id);
      return idOrder != 0 ? idOrder : a.version.compareTo(b.version);
    });
    return List<DocumentTemplateDefinition>.unmodifiable(result);
  }
}
