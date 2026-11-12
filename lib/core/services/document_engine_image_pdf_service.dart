import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:document_engine/document_engine.dart';

import 'document_engine_font_service.dart';

/// Shared bounded image-to-PDF adapter for transient image print/export flows.
///
/// Official business documents should use their own typed snapshots and
/// registered templates. This adapter is intentionally limited to one image
/// per page and delegates all PDF generation to document_engine.
class DocumentEngineImagePdfService {
  DocumentEngineImagePdfService._();

  static final DocumentEngineImagePdfService instance =
      DocumentEngineImagePdfService._();

  static const int _maxImageBytes = 4 * 1024 * 1024;

  Future<Uint8List> renderA4Image({
    required Uint8List imageBytes,
    required String title,
    DocumentPageOrientation orientation = DocumentPageOrientation.portrait,
  }) async {
    if (imageBytes.isEmpty) {
      throw ArgumentError.value(imageBytes, 'imageBytes', 'Image is empty.');
    }

    final profile = orientation == DocumentPageOrientation.landscape
        ? DocumentPageProfile.a4Landscape(
            marginTop: 28,
            marginRight: 28,
            marginBottom: 28,
            marginLeft: 28,
          )
        : DocumentPageProfile.a4Portrait(
            marginTop: 28,
            marginRight: 28,
            marginBottom: 28,
            marginLeft: 28,
          );

    final normalizedBytes = await _normalizeImage(imageBytes);
    final generatedAt = DateTime.now();
    final documentTitle = _normalizeTitle(title);
    final documentType = DocumentTypeId('netsales.image-export');

    final snapshot = DocumentSnapshot(
      metadata: DocumentMetadata(
        id: DocumentId(
          'netsales-image-${generatedAt.microsecondsSinceEpoch}',
        ),
        documentTypeId: documentType,
        title: documentTitle,
        locale: DocumentLocale(
          languageTag: 'ar-YE',
          direction: DocumentTextDirection.auto,
        ),
        createdAt: generatedAt,
      ),
      sections: [
        DocumentSection(
          id: 'image-page',
          nodes: [
            DocumentImage(
              bytes: normalizedBytes,
              widthPoints:
                  profile.widthPoints - profile.marginLeft - profile.marginRight,
              heightPoints:
                  profile.heightPoints - profile.marginTop - profile.marginBottom,
              fit: DocumentImageFit.contain,
              alignment: DocumentImageAlignment.center,
            ),
          ],
        ),
      ],
    );

    final template = DocumentTemplateDefinition(
      id: TemplateId('netsales.image-export.a4'),
      version: TemplateVersion(major: 1, minor: 0, patch: 0),
      documentTypeId: documentType,
      displayName: 'NetSales Single Image PDF',
      supportedLocaleTags: const ['ar', 'en'],
      capabilities: TemplateCapabilities([
        TemplateCapability.images,
        orientation == DocumentPageOrientation.landscape
            ? TemplateCapability.landscapePage
            : TemplateCapability.portraitPage,
      ]),
      isDefault: true,
      layout: DocumentTemplateLayout.standard,
    );

    final renderer = PdfDocumentRenderer(
      textShapingProvider:
          await DocumentEngineFontService.instance.arabicTextShapingProvider(),
    );
    final result = await renderer.render(
      snapshot: snapshot,
      template: template,
      options: DocumentRenderOptions(
        pageProfile: profile,
        generatedAt: generatedAt,
        showPageNumbers: false,
        maxPages: 1,
      ),
    );

    if (result is DocumentRenderSuccess) return result.artifact.bytes;
    if (result is DocumentRenderFailure) throw StateError(result.message);
    throw StateError('تعذر تحويل الصورة إلى ملف PDF.');
  }

  Future<Uint8List> _normalizeImage(Uint8List sourceBytes) async {
    final sourceCodec = await ui.instantiateImageCodec(sourceBytes);
    late final int sourceWidth;
    late final int sourceHeight;

    try {
      final frame = await sourceCodec.getNextFrame();
      sourceWidth = frame.image.width;
      sourceHeight = frame.image.height;
      frame.image.dispose();
    } finally {
      sourceCodec.dispose();
    }

    for (final maximumDimension in [1600, 1400, 1200, 1000, 800]) {
      final scale = math.min(
        1.0,
        maximumDimension /
            math.max(sourceWidth, sourceHeight).toDouble(),
      );
      final targetWidth = (sourceWidth * scale)
          .round()
          .clamp(1, maximumDimension)
          .toInt();
      final targetHeight = (sourceHeight * scale)
          .round()
          .clamp(1, maximumDimension)
          .toInt();

      if (scale == 1.0 &&
          sourceBytes.length <= _maxImageBytes &&
          _isPngOrJpeg(sourceBytes)) {
        return Uint8List.fromList(sourceBytes);
      }

      final codec = await ui.instantiateImageCodec(
        sourceBytes,
        targetWidth: targetWidth,
        targetHeight: targetHeight,
      );
      try {
        final frame = await codec.getNextFrame();
        try {
          final data = await frame.image.toByteData(
            format: ui.ImageByteFormat.png,
          );
          if (data == null) continue;

          final encoded = data.buffer.asUint8List(
            data.offsetInBytes,
            data.lengthInBytes,
          );
          if (encoded.length <= _maxImageBytes) {
            return Uint8List.fromList(encoded);
          }
        } finally {
          frame.image.dispose();
        }
      } finally {
        codec.dispose();
      }
    }

    throw StateError(
      'تعذر ضغط الصورة إلى الحد الأقصى المسموح به لمستند PDF.',
    );
  }

  static bool _isPngOrJpeg(List<int> bytes) {
    final isPng = bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47 &&
        bytes[4] == 0x0D &&
        bytes[5] == 0x0A &&
        bytes[6] == 0x1A &&
        bytes[7] == 0x0A;
    final isJpeg = bytes.length >= 3 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF;
    return isPng || isJpeg;
  }

  static String _normalizeTitle(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) return 'صورة';
    if (normalized.length <= 120) return normalized;
    return normalized.substring(0, 120);
  }
}
