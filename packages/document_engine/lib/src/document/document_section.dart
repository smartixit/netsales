import '../core/stable_identifier.dart';
import 'document_node.dart';

/// Ordered semantic group of nodes inside a document snapshot.
final class DocumentSection {
  DocumentSection({
    required String id,
    this.title,
    required Iterable<DocumentNode> nodes,
  }) : id = validateStableIdentifier(id, parameterName: 'sectionId'),
       nodes = List<DocumentNode>.unmodifiable(nodes);

  final String id;
  final String? title;
  final List<DocumentNode> nodes;
}
