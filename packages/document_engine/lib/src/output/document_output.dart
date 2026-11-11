import '../rendering/document_render_result.dart';

enum DocumentOutputOperation { save, share, print }

enum DocumentOutputFailureCode {
  emptyArtifact,
  invalidFileName,
  unsupported,
  alreadyRunning,
  adapterFailure,
}

sealed class DocumentOutputResult {
  const DocumentOutputResult();
}

final class DocumentOutputSuccess extends DocumentOutputResult {
  const DocumentOutputSuccess({this.location});
  final String? location;
}

/// User cancellation (for example, closing a Save As dialog) is not an error.
final class DocumentOutputCancelled extends DocumentOutputResult {
  const DocumentOutputCancelled();
}

final class DocumentOutputFailure extends DocumentOutputResult {
  const DocumentOutputFailure({
    required this.code,
    required this.message,
    this.isRetryable = false,
  });

  final DocumentOutputFailureCode code;
  final String message;
  final bool isRetryable;
}

final class DocumentOutputRequest {
  const DocumentOutputRequest({required this.artifact, required this.fileName});

  final DocumentArtifact artifact;
  final String fileName;
}

/// Independent host-owned output ports. The engine never performs platform I/O.
abstract interface class DocumentSavePort {
  Future<DocumentOutputResult> save(DocumentOutputRequest request);
}

abstract interface class DocumentSharePort {
  Future<DocumentOutputResult> share(DocumentOutputRequest request);
}

abstract interface class DocumentPrintPort {
  Future<DocumentOutputResult> print(DocumentOutputRequest request);
}

/// Coordinates all output operations against the exact same immutable artifact.
final class DocumentOutputCoordinator {
  DocumentOutputCoordinator({this.savePort, this.sharePort, this.printPort});

  final DocumentSavePort? savePort;
  final DocumentSharePort? sharePort;
  final DocumentPrintPort? printPort;
  final Set<DocumentOutputOperation> _running = {};

  bool isRunning(DocumentOutputOperation operation) =>
      _running.contains(operation);

  Future<DocumentOutputResult> save({
    required DocumentArtifact artifact,
    required String fileName,
  }) => _run(DocumentOutputOperation.save, artifact, fileName, savePort?.save);

  Future<DocumentOutputResult> share({
    required DocumentArtifact artifact,
    required String fileName,
  }) =>
      _run(DocumentOutputOperation.share, artifact, fileName, sharePort?.share);

  Future<DocumentOutputResult> print({
    required DocumentArtifact artifact,
    required String fileName,
  }) =>
      _run(DocumentOutputOperation.print, artifact, fileName, printPort?.print);

  Future<DocumentOutputResult> _run(
    DocumentOutputOperation operation,
    DocumentArtifact artifact,
    String requestedName,
    Future<DocumentOutputResult> Function(DocumentOutputRequest request)?
    invoke,
  ) async {
    if (artifact.byteLength == 0) {
      return const DocumentOutputFailure(
        code: DocumentOutputFailureCode.emptyArtifact,
        message: 'The document artifact is empty.',
      );
    }
    final fileName = normalizePdfFileName(requestedName);
    if (fileName == null) {
      return const DocumentOutputFailure(
        code: DocumentOutputFailureCode.invalidFileName,
        message: 'A valid PDF file name is required.',
      );
    }
    if (invoke == null) {
      return const DocumentOutputFailure(
        code: DocumentOutputFailureCode.unsupported,
        message: 'This output operation is not supported by the host.',
      );
    }
    if (!_running.add(operation)) {
      return const DocumentOutputFailure(
        code: DocumentOutputFailureCode.alreadyRunning,
        message: 'This output operation is already running.',
        isRetryable: true,
      );
    }

    try {
      return await invoke(
        DocumentOutputRequest(artifact: artifact, fileName: fileName),
      );
    } catch (_) {
      return const DocumentOutputFailure(
        code: DocumentOutputFailureCode.adapterFailure,
        message: 'The document could not be sent to the selected output.',
        isRetryable: true,
      );
    } finally {
      _running.remove(operation);
    }
  }
}

/// Normalizes a PDF filename while preserving Arabic and other Unicode text.
String? normalizePdfFileName(String value) {
  var name = value.trim();
  if (name.isEmpty) return null;
  name = name.replaceAll(RegExp(r'(?:\.pdf)+$', caseSensitive: false), '');
  name = name.replaceAll(RegExp(r'[\\/:*?"<>|\x00-\x1F]'), '_');
  name = name.replaceAll(RegExp(r'\s+'), ' ').trim();
  name = name.replaceAll(RegExp(r'^[. ]+|[. ]+$'), '');
  if (name.isEmpty) return null;
  if (name.length > 116) name = name.substring(0, 116).trim();
  if (name.isEmpty) return null;
  const reserved = {
    'CON',
    'PRN',
    'AUX',
    'NUL',
    'COM1',
    'COM2',
    'COM3',
    'COM4',
    'COM5',
    'COM6',
    'COM7',
    'COM8',
    'COM9',
    'LPT1',
    'LPT2',
    'LPT3',
    'LPT4',
    'LPT5',
    'LPT6',
    'LPT7',
    'LPT8',
    'LPT9',
  };
  if (reserved.contains(name.toUpperCase())) name = '_$name';
  return '$name.pdf';
}
