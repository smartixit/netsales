import 'dart:typed_data';

import 'package:crypto/crypto.dart' as crypto;

import '../core/document_id.dart';
import '../core/template_id.dart';
import '../core/template_version.dart';

/// Stable categories for renderer failures; raw internal exceptions are not
/// exposed to consuming applications.
enum DocumentRenderFailureCode {
  templateMismatch,
  unsupportedLocale,
  unsupportedCapability,
  unsupportedTextShaping,
  pageLimitExceeded,
  layoutFailure,
  renderingFailure,
}

/// Result of a rendering operation.
sealed class DocumentRenderResult {
  const DocumentRenderResult();
}

final class DocumentRenderSuccess extends DocumentRenderResult {
  DocumentRenderSuccess(this.artifact);

  final DocumentArtifact artifact;
}

final class DocumentRenderFailure extends DocumentRenderResult {
  const DocumentRenderFailure({
    required this.code,
    required this.message,
    this.isRetryable = false,
  });

  final DocumentRenderFailureCode code;
  final String message;
  final bool isRetryable;
}

/// Immutable bytes and provenance metadata for one generated artifact.
final class DocumentArtifact {
  DocumentArtifact({
    required this.documentId,
    required this.templateId,
    required this.templateVersion,
    required this.schemaVersion,
    required this.rendererId,
    required this.rendererVersion,
    required this.generatedAt,
    required Uint8List bytes,
    this.pageCount,
  }) : _bytes = Uint8List.fromList(bytes),
       sha256 = crypto.sha256.convert(bytes).toString();

  final DocumentId documentId;
  final TemplateId templateId;
  final TemplateVersion templateVersion;
  final int schemaVersion;
  final String rendererId;
  final String rendererVersion;
  final DateTime generatedAt;
  final Uint8List _bytes;
  final String sha256;
  final int? pageCount;

  /// Returns a defensive copy so callers cannot mutate the stored artifact.
  Uint8List get bytes => Uint8List.fromList(_bytes);

  int get byteLength => _bytes.length;
}
