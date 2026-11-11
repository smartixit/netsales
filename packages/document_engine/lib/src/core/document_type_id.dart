import 'stable_identifier.dart';

/// Stable application-defined document type, such as "sales.invoice".
final class DocumentTypeId implements Comparable<DocumentTypeId> {
  DocumentTypeId(String value)
    : value = validateStableIdentifier(value, parameterName: 'documentTypeId');

  final String value;

  @override
  int compareTo(DocumentTypeId other) => value.compareTo(other.value);

  @override
  bool operator ==(Object other) =>
      other is DocumentTypeId && other.value == value;

  @override
  int get hashCode => Object.hash(DocumentTypeId, value);

  @override
  String toString() => value;
}
