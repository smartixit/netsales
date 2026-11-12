import 'bounded_document_input.dart';
import 'document_metadata.dart';
import 'document_node.dart';
import 'document_value.dart';
import 'document_section.dart';

/// Immutable, application-neutral input for a single document rendering.
final class DocumentSnapshot {
  DocumentSnapshot({
    required this.metadata,
    required Iterable<DocumentSection> sections,
    this.schemaVersion = 1,
  }) : sections = copyBoundedDocumentList(
         sections,
         maxLength: 250,
         fieldName: 'sections',
       ) {
    if (schemaVersion < 1) {
      throw ArgumentError.value(
        schemaVersion,
        'schemaVersion',
        'Must be a positive integer.',
      );
    }

    final nodeCount = this.sections.fold<int>(
      0,
      (count, section) => count + section.nodes.length,
    );
    if (nodeCount > 20000) {
      throw ArgumentError.value(
        nodeCount,
        'sections',
        'A document may contain at most 20000 nodes.',
      );
    }
    _validateDocumentTextBudget(metadata: metadata, sections: this.sections);

    final sectionIds = this.sections.map((section) => section.id).toSet();
    if (sectionIds.length != this.sections.length) {
      throw ArgumentError('Document section identifiers must be unique.');
    }
  }

  final DocumentMetadata metadata;
  final List<DocumentSection> sections;
  final int schemaVersion;
}


void _validateDocumentTextBudget({
  required DocumentMetadata metadata,
  required List<DocumentSection> sections,
}) {
  const maxFieldCharacters = 100000;
  const maxTotalCharacters = 2000000;
  var totalCharacters = 0;
  void add(String? value) {
    if (value == null) return;
    if (value.length > maxFieldCharacters) {
      throw ArgumentError.value(value.length, 'documentText', 'A document text field may contain at most $maxFieldCharacters characters.');
    }
    totalCharacters += value.length;
    if (totalCharacters > maxTotalCharacters) {
      throw ArgumentError.value(totalCharacters, 'documentText', 'A document may contain at most $maxTotalCharacters text characters.');
    }
  }
  void addValue(DocumentValue value) {
    if (value is DocumentTextValue) add(value.value);
    if (value is DocumentDecimalValue) add(value.value);
  }
  add(metadata.title);
  add(metadata.subtitle);
  add(metadata.reference);
  add(metadata.timeZoneId);
  add(metadata.sourceRevision);
  for (final section in sections) {
    add(section.title);
    for (final node in section.nodes) {
      if (node is DocumentParagraph) {
        add(node.text);
      } else if (node is DocumentHeading) {
        add(node.text);
      } else if (node is DocumentMetric) {
        add(node.label); add(node.caption); addValue(node.value);
      } else if (node is DocumentMetricGrid) {
        for (final metric in node.metrics) { add(metric.label); add(metric.caption); addValue(metric.value); }
      } else if (node is DocumentTable) {
        for (final column in node.columns) { add(column.label); }
        for (final row in node.rows) { for (final cell in row.cells) { addValue(cell.value); } }
      } else if (node is DocumentChart) {
        add(node.title); add(node.subtitle);
        for (final series in node.series) { add(series.label); for (final point in series.points) { add(point.label); add(point.displayValue); } }
      } else if (node is DocumentImage) {
        add(node.caption);
      } else if (node is DocumentQrCode) {
        add(node.payload); add(node.caption);
      } else if (node is DocumentSignatureArea) {
        add(node.label); add(node.signerName); add(node.roleLabel); add(node.approvalReference);
      } else if (node is DocumentInfoGrid) {
        for (final item in node.items) { add(item.label); addValue(item.value); }
      } else if (node is DocumentStatusBanner) {
        add(node.label); add(node.detail);
      } else if (node is DocumentFinancialSummary) {
        add(node.title); for (final line in node.lines) { add(line.label); add(line.note); addValue(line.value); }
      } else if (node is DocumentCallout) {
        add(node.title); add(node.body);
      }
    }
  }
}
