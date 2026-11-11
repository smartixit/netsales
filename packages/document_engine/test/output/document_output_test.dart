import 'dart:typed_data';

import 'package:document_engine/document_engine.dart';
import 'package:flutter_test/flutter_test.dart';

final class _RecordingSavePort implements DocumentSavePort {
  DocumentOutputRequest? request;
  @override
  Future<DocumentOutputResult> save(DocumentOutputRequest value) async {
    request = value;
    return const DocumentOutputSuccess(location: 'memory://saved');
  }
}

final class _RecordingSharePort implements DocumentSharePort {
  DocumentOutputRequest? request;
  @override
  Future<DocumentOutputResult> share(DocumentOutputRequest value) async {
    request = value;
    return const DocumentOutputSuccess();
  }
}

final class _RecordingPrintPort implements DocumentPrintPort {
  DocumentOutputRequest? request;
  @override
  Future<DocumentOutputResult> print(DocumentOutputRequest value) async {
    request = value;
    return const DocumentOutputSuccess(location: 'printer-1');
  }
}

DocumentArtifact _artifact({List<int> bytes = const [37, 80, 68, 70]}) =>
    DocumentArtifact(
      documentId: DocumentId('doc-1'),
      templateId: TemplateId('invoice.standard'),
      templateVersion: TemplateVersion(major: 1, minor: 0, patch: 0),
      schemaVersion: 1,
      rendererId: 'test',
      rendererVersion: '1',
      generatedAt: DateTime.utc(2026),
      bytes: Uint8List.fromList(bytes),
      pageCount: 1,
    );

void main() {
  group('normalizePdfFileName', () {
    test('preserves Arabic and appends a single PDF extension', () {
      expect(normalizePdfFileName('فاتورة ١٢.pdf'), 'فاتورة ١٢.pdf');
    });

    test('removes invalid path characters and bounds the name', () {
      final result = normalizePdfFileName(r'../../Invoice:2026?.pdf')!;
      expect(result, isNot(contains('/')));
      expect(result, isNot(contains(':')));
      expect(result, endsWith('.pdf'));
      expect(result.length, lessThanOrEqualTo(120));
    });

    test('rejects empty names and protects Windows device names', () {
      expect(normalizePdfFileName('  '), isNull);
      expect(normalizePdfFileName('...'), isNull);
      expect(normalizePdfFileName('CON'), '_CON.pdf');
    });
  });

  test('all output ports receive the same artifact digest and bytes', () async {
    final save = _RecordingSavePort();
    final share = _RecordingSharePort();
    final print = _RecordingPrintPort();
    final coordinator = DocumentOutputCoordinator(
      savePort: save,
      sharePort: share,
      printPort: print,
    );
    final artifact = _artifact();

    expect(
      await coordinator.save(artifact: artifact, fileName: 'Invoice'),
      isA<DocumentOutputSuccess>(),
    );
    expect(
      await coordinator.share(artifact: artifact, fileName: 'Invoice'),
      isA<DocumentOutputSuccess>(),
    );
    expect(
      await coordinator.print(artifact: artifact, fileName: 'Invoice'),
      isA<DocumentOutputSuccess>(),
    );

    for (final request in [save.request!, share.request!, print.request!]) {
      expect(request.artifact.sha256, artifact.sha256);
      expect(request.artifact.bytes, artifact.bytes);
      expect(request.fileName, 'Invoice.pdf');
    }
  });

  test('unsupported host operation is explicit', () async {
    final result = await DocumentOutputCoordinator().save(
      artifact: _artifact(),
      fileName: 'Invoice',
    );
    expect(result, isA<DocumentOutputFailure>());
    expect(
      (result as DocumentOutputFailure).code,
      DocumentOutputFailureCode.unsupported,
    );
  });

  test('empty artifacts are rejected before adapter invocation', () async {
    final save = _RecordingSavePort();
    final result = await DocumentOutputCoordinator(savePort: save).save(
      artifact: _artifact(bytes: []),
      fileName: 'Invoice',
    );
    expect(result, isA<DocumentOutputFailure>());
    expect(save.request, isNull);
  });
}
