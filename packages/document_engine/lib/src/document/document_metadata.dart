import '../core/document_id.dart';
import '../core/document_type_id.dart';
import 'document_locale.dart';

/// Descriptive identity and locale context for a document snapshot.
///
/// Timestamps and references are supplied by the host. No current time,
/// document number, or business value is generated implicitly.
final class DocumentMetadata {
  DocumentMetadata({
    required this.id,
    required this.documentTypeId,
    required String title,
    required this.locale,
    this.subtitle,
    this.reference,
    this.createdAt,
    this.timeZoneId,
    this.sourceRevision,
  }) : title = _requireText(title, 'title');

  final DocumentId id;
  final DocumentTypeId documentTypeId;
  final String title;
  final String? subtitle;
  final String? reference;
  final DocumentLocale locale;
  final DateTime? createdAt;
  final String? timeZoneId;
  final String? sourceRevision;

  static String _requireText(String value, String name) {
    if (value.trim().isEmpty) {
      throw ArgumentError.value(value, name, 'Must not be empty.');
    }
    return value;
  }
}
