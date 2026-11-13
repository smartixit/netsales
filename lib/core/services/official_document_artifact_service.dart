import 'dart:typed_data';

import 'package:netsales/core/constants/api_constants.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/services/api_service.dart';

/// Persists the authoritative server snapshot and returns its canonical PDF bytes.
class OfficialDocumentArtifactService {
  OfficialDocumentArtifactService._();

  static final OfficialDocumentArtifactService instance =
      OfficialDocumentArtifactService._();

  Future<Uint8List> issueAndUpload({
    required String documentType,
    required int documentId,
    required int networkId,
    int? posId,
    required String templateId,
    required String templateVersion,
    required Uint8List pdfBytes,
    required String fileName,
  }) async {
    if (pdfBytes.isEmpty) {
      throw const AppException(
        'ملف PDF فارغ ولا يمكن تثبيته كنسخة رسمية.',
        code: 'OFFICIAL_DOCUMENT_PDF_EMPTY',
      );
    }

    final snapshotResponse =
        await ApiService.instance.post<Map<String, dynamic>>(
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

    if (snapshot['artifact_ready'] == true) {
      final canonicalBytes = await ApiService.instance.downloadBytes(
        ApiConstants.operationalDocumentSnapshotDownload(snapshotUuid),
      );
      if (canonicalBytes == null || canonicalBytes.isEmpty) {
        throw const AppException(
          'تعذر استرجاع ملف PDF المثبت للنسخة الرسمية.',
          code: 'OFFICIAL_DOCUMENT_CANONICAL_DOWNLOAD_FAILED',
        );
      }
      return canonicalBytes;
    }

    final artifactResponse =
        await ApiService.instance.uploadBytes<Map<String, dynamic>>(
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

    if (artifactResponse.data!['artifact_ready'] != true) {
      throw const AppException(
        'لم يؤكد الخادم تثبيت ملف PDF للنسخة الرسمية.',
        code: 'OFFICIAL_DOCUMENT_ARTIFACT_NOT_READY',
      );
    }

    return Uint8List.fromList(pdfBytes);
  }
}
