import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import 'package:netsales/core/constants/api_constants.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/services/api_service.dart';

/// Coordinates immutable document snapshots and their canonical PDF artifacts.
class OfficialDocumentArtifactService {
  OfficialDocumentArtifactService._();

  static final OfficialDocumentArtifactService instance =
      OfficialDocumentArtifactService._();

  Future<Map<String, dynamic>> createSnapshot({
    required String documentType,
    required int documentId,
    required int networkId,
    int? posId,
    required String templateId,
    required String templateVersion,
  }) async {
    final response = await ApiService.instance.post<Map<String, dynamic>>(
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

    if (!response.success || response.data == null) {
      throw AppException(
        response.message.isNotEmpty
            ? response.message
            : 'تعذر تثبيت لقطة المستند الرسمية.',
        code: 'OFFICIAL_DOCUMENT_SNAPSHOT_FAILED',
        details: response.errors,
      );
    }

    final snapshot = response.data!;
    requireCurrencyCode(snapshot);
    final snapshotUuid = snapshot['snapshot_uuid']?.toString();
    final source = snapshot['source_snapshot'];
    if (snapshotUuid == null ||
        snapshotUuid.isEmpty ||
        source is! Map) {
      throw const AppException(
        'أعاد الخادم لقطة مستند غير مكتملة.',
        code: 'OFFICIAL_DOCUMENT_SNAPSHOT_INVALID',
      );
    }

    return snapshot;
  }

  /// Validates the ISO-4217 currency code supplied by the API snapshot.
  String requireCurrencyCode(Map<String, dynamic> snapshot) {
    final value = snapshot['currency_code'];
    if (value is! String ||
        !RegExp(r'^[A-Z]{3}$').hasMatch(value.trim())) {
      throw const AppException(
        'لقطة المستند لا تحتوي رمز عملة تشغيلية صالحاً.',
        code: 'OFFICIAL_DOCUMENT_CURRENCY_INVALID',
      );
    }
    return value.trim();
  }

  /// Downloads the canonical artifact only when the server marks it ready.
  Future<Uint8List?> downloadIfReady(
    Map<String, dynamic> snapshot,
  ) async {
    if (snapshot['artifact_ready'] != true) return null;

    final snapshotUuid = snapshot['snapshot_uuid']?.toString();
    if (snapshotUuid == null || snapshotUuid.isEmpty) {
      throw const AppException(
        'معرف النسخة الرسمية غير صالح.',
        code: 'OFFICIAL_DOCUMENT_SNAPSHOT_INVALID',
      );
    }

    return downloadCanonical(
      snapshotUuid,
      expectedSha256: snapshot['artifact_sha256']?.toString(),
    );
  }

  /// Persists PDF bytes once and always returns the server's canonical bytes.
  Future<Uint8List> uploadArtifact({
    required String snapshotUuid,
    required Uint8List pdfBytes,
    required String fileName,
  }) async {
    if (snapshotUuid.trim().isEmpty) {
      throw const AppException(
        'معرف النسخة الرسمية غير صالح.',
        code: 'OFFICIAL_DOCUMENT_SNAPSHOT_INVALID',
      );
    }
    if (pdfBytes.isEmpty) {
      throw const AppException(
        'ملف PDF فارغ ولا يمكن تثبيته كنسخة رسمية.',
        code: 'OFFICIAL_DOCUMENT_PDF_EMPTY',
      );
    }

    final response =
        await ApiService.instance.uploadBytes<Map<String, dynamic>>(
      ApiConstants.operationalDocumentSnapshotArtifact(snapshotUuid),
      bytes: pdfBytes,
      fileName: fileName.toLowerCase().endsWith('.pdf')
          ? fileName
          : '$fileName.pdf',
      fileField: 'artifact',
      idempotencyKey: 'document-artifact-$snapshotUuid',
      fromJson: (json) {
        if (json is! Map) {
          throw const FormatException('استجابة ملف المستند غير صالحة.');
        }
        return Map<String, dynamic>.from(json);
      },
    );

    if (!response.success ||
        response.data == null ||
        response.data!['artifact_ready'] != true) {
      throw AppException(
        response.message.isNotEmpty
            ? response.message
            : 'تعذر تثبيت ملف PDF الرسمي.',
        code: 'OFFICIAL_DOCUMENT_ARTIFACT_FAILED',
        details: response.errors,
      );
    }

    // Another request may win an immutable first-write race. Never return local
    // bytes as canonical; fetch and hash-check the server-stored artifact.
    return downloadCanonical(
      snapshotUuid,
      expectedSha256: response.data!['artifact_sha256']?.toString(),
    );
  }

  Future<Uint8List> downloadCanonical(
    String snapshotUuid, {
    String? expectedSha256,
  }) async {
    if (snapshotUuid.trim().isEmpty) {
      throw const AppException(
        'معرف النسخة الرسمية غير صالح.',
        code: 'OFFICIAL_DOCUMENT_SNAPSHOT_INVALID',
      );
    }

    final bytes = await ApiService.instance.downloadBytes(
      ApiConstants.operationalDocumentSnapshotDownload(snapshotUuid),
    );
    if (bytes == null || bytes.isEmpty) {
      throw const AppException(
        'تعذر استرجاع ملف PDF المثبت للنسخة الرسمية.',
        code: 'OFFICIAL_DOCUMENT_CANONICAL_DOWNLOAD_FAILED',
      );
    }

    final normalizedHash = expectedSha256?.trim().toLowerCase();
    if (normalizedHash != null && normalizedHash.isNotEmpty) {
      if (!RegExp(r'^[a-f0-9]{64}$').hasMatch(normalizedHash)) {
        throw const AppException(
          'بصمة ملف PDF الرسمية غير صالحة.',
          code: 'OFFICIAL_DOCUMENT_ARTIFACT_HASH_INVALID',
        );
      }
      final actualHash = sha256.convert(bytes).toString();
      if (actualHash != normalizedHash) {
        throw const AppException(
          'فشل التحقق من سلامة ملف PDF الرسمي بعد تنزيله.',
          code: 'OFFICIAL_DOCUMENT_ARTIFACT_HASH_MISMATCH',
        );
      }
    }

    return bytes;
  }
}
