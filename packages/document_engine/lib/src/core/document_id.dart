import 'stable_identifier.dart';

/// Stable identity of one document snapshot.
final class DocumentId implements Comparable<DocumentId> {
  DocumentId(String value)
    : value = validateStableIdentifier(value, parameterName: 'documentId');

  final String value;

  @override
  int compareTo(DocumentId other) => value.compareTo(other.value);

  @override
  bool operator ==(Object other) => other is DocumentId && other.value == value;

  @override
  int get hashCode => Object.hash(DocumentId, value);

  @override
  String toString() => value;
}
