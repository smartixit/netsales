import 'document_metadata.dart';
import 'document_section.dart';

/// Immutable, application-neutral input for a single document rendering.
final class DocumentSnapshot {
  DocumentSnapshot({
    required this.metadata,
    required Iterable<DocumentSection> sections,
    this.schemaVersion = 1,
  }) : sections = List<DocumentSection>.unmodifiable(sections) {
    if (schemaVersion < 1) {
      throw ArgumentError.value(
        schemaVersion,
        'schemaVersion',
        'Must be a positive integer.',
      );
    }

    final sectionIds = this.sections.map((section) => section.id).toSet();
    if (sectionIds.length != this.sections.length) {
      throw ArgumentError('Document section identifiers must be unique.');
    }
  }

  final DocumentMetadata metadata;
  final List<DocumentSection> sections;
  final int schemaVersion;
}
