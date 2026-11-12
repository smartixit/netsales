import '../core/stable_identifier.dart';
import 'bounded_document_input.dart';
import 'document_node.dart';

/// Ordered semantic group of nodes inside a document snapshot.
final class DocumentSection {
  DocumentSection({
    required String id,
    this.title,
    required Iterable<DocumentNode> nodes,
  }) : id = validateStableIdentifier(id, parameterName: 'sectionId'),
       nodes = copyBoundedDocumentList(
         nodes,
         maxLength: 20000,
         fieldName: 'nodes',
       ) {
    if (title != null && (title!.trim().isEmpty || title!.length > 300)) {
      throw ArgumentError.value(
        title,
        'title',
        'Must contain 1-300 characters.',
      );
    }
  }

  final String id;
  final String? title;
  final List<DocumentNode> nodes;
}
