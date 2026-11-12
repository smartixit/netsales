import 'dart:typed_data';

import 'package:netsales/core/constants/api_constants.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/services/api_service.dart';

/// Persists the authoritative server snapshot and binds its immutable PDF artifact.
class OfficialDocumentArtifactService {
  OfficialDocumentArtifactService._();

  static final OfficialDocumentArtifactService instance =
      OfficialDocumentArtifactService._();

  Future<String> issueAndUpload({
    required String documentType,
    required int documentId,
    required int networkId,
    int? posId,
    required String templateId,
    required String templateVersion,
    required Uint8List pdfBytes,
    required String fileName,
  }) async {
    final snapshotResponse = await ApiService.instance.post<Map<String, dynamic>>(
      ApiConstants.operationalDocumentSnapshots,
      data: {
        'document_type': documentType,
        'document_id': documentId,
        'network_id': networkId,
        if (posId != null) 'pos_id': posId,
        'template_id': templateId,
        'template_version': templateVersion,
      },
      fromJson: (json) {
        if (json is! Map) {
          throw const FormatException('استجابة النسخة الرسمية غير صالحة.');
        }
        return Map<String, dynamic>.from(json);
      },
    );

    if (!snapshotResponse.success || snapshotResponse.data == null) {
      throw AppException(
        snapshotResponse.message.isNotEmpty
            ? snapshotResponse.message
            : 'تعذر تثبيت النسخة الرسمية للمستند.',
        code: 'OFFICIAL_DOCUMENT_SNAPSHOT_FAILED',
        details: snapshotResponse.errors,
      );
    }

    final snapshot = snapshotResponse.data!;
    final snapshotUuid = snapshot['snapshot_uuid']?.toString();
    if (snapshotUuid == null || snapshotUuid.isEmpty) {
      throw const AppException(
        'لم يُرجع الخادم معرف النسخة الرسمية.',
        code: 'OFFICIAL_DOCUMENT_SNAPSHOT_INVALID',
      );
    }

    if (snapshot['artifact_ready'] == true) return snapshotUuid;

    final artifactResponse = await ApiService.instance.uploadBytes<Map<String, dynamic>>(
      ApiConstants.operationalDocumentSnapshotArtifact(snapshotUuid),
      bytes: pdfBytes,
      fileName: fileName.endsWith('.pdf') ? fileName : '$fileName.pdf',
      fileField: 'artifact',
      idempotencyKey: 'document-artifact-$snapshotUuid',
      fromJson: (json) {
        if (json is! Map) {
          throw const FormatException('استجابة ملف المستند غير صالحة.');
        }
        return Map<String, dynamic>.from(json);
      },
    );

    if (!artifactResponse.success || artifactResponse.data == null) {
      throw AppException(
        artifactResponse.message.isNotEmpty
            ? artifactResponse.message
            : 'تعذر تثبيت ملف PDF الرسمي.',
        code: 'OFFICIAL_DOCUMENT_ARTIFACT_FAILED',
        details: artifactResponse.errors,
      );
    }

    return snapshotUuid;
  }
}
