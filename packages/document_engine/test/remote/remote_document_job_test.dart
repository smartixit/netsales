import 'dart:typed_data';

import 'package:document_engine/document_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'remote job request freezes nested JSON and omits tenant credentials',
    () {
      final filters = <String, Object?>{'status': 'ACTIVE'};
      final request = RemoteDocumentJobRequest(
        reportId: ReportId('reports.sales'),
        reportSchemaVersion: 2,
        idempotencyKey: 'idempotency-123',
        correlationId: 'correlation-123',
        payload: {
          'criteria': {'filters': filters},
          'presentation': {'locale': 'ar'},
        },
      );
      filters['status'] = 'BANNED';

      final json = request.toJson();
      final criteria = json['payload'] as Map<String, Object?>;
      final nested = criteria['criteria'] as Map<String, Object?>;
      final frozenFilters = (nested['filters'] as Map<String, Object?>);
      expect(frozenFilters['status'], 'ACTIVE');
      expect(json, isNot(contains('tenant_id')));
      expect(json, isNot(contains('access_token')));
    },
  );

  test('job status wire values are strict', () {
    expect(
      RemoteDocumentJobStatus.fromWire('SUCCEEDED'),
      RemoteDocumentJobStatus.succeeded,
    );
    expect(
      () => RemoteDocumentJobStatus.fromWire('DONE'),
      throwsFormatException,
    );
  });

  test('succeeded job requires artifact metadata', () {
    expect(
      () => RemoteDocumentJobSnapshot(
        jobId: RemoteDocumentJobId('job-123'),
        status: RemoteDocumentJobStatus.succeeded,
        updatedAt: DateTime.utc(2026),
      ),
      throwsArgumentError,
    );
  });

  test('hydration verifies exact byte length and digest', () {
    final bytes = Uint8List.fromList([37, 80, 68, 70]);
    final artifact = DocumentArtifact(
      documentId: DocumentId('doc-1'),
      templateId: TemplateId('invoice.standard'),
      templateVersion: TemplateVersion(major: 1, minor: 0, patch: 0),
      schemaVersion: 1,
      rendererId: 'laravel-document-service',
      rendererVersion: '1',
      generatedAt: DateTime.utc(2026),
      bytes: bytes,
    );
    final metadata = RemoteDocumentArtifactMetadata(
      artifactId: 'artifact-123',
      documentId: DocumentId('doc-1'),
      documentType: 'invoice',
      revision: 1,
      schemaVersion: 3,
      officialDocumentId: 'INV-2026-001',
      templateId: TemplateId('invoice.standard'),
      templateVersion: TemplateVersion(major: 1, minor: 0, patch: 0),
      rendererId: 'laravel-document-service',
      rendererVersion: '1',
      generatedAt: DateTime.utc(2026),
      sha256: artifact.sha256,
      byteLength: bytes.length,
      fileName: 'invoice.pdf',
    );

    final hydrated = hydrateRemoteDocumentArtifact(
      metadata: metadata,
      bytes: bytes,
    );
    expect(hydrated.sha256, metadata.sha256);
    expect(
      () => hydrateRemoteDocumentArtifact(
        metadata: metadata,
        bytes: Uint8List.fromList([1, 2, 3]),
      ),
      throwsFormatException,
    );
  });
}
