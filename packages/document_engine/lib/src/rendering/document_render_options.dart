import 'dart:typed_data';

import '../document/document_branding.dart';
import 'document_page_profile.dart';

/// Image watermark supplied by the host application.
///
/// The engine never chooses a tenant logo or loads application assets. The
/// host resolves the Network/POS logo and supplies the selected PNG/JPEG bytes.
final class DocumentWatermark {
  DocumentWatermark({
    required Uint8List imageBytes,
    this.opacity = 0.12,
    this.angleRadians = -0.7853981633974483,
    this.widthFactor = 0.72,
    this.heightFactor = 0.62,
  }) : _imageBytes = _copyImage(imageBytes) {
    if (!opacity.isFinite || opacity < 0.04 || opacity > 0.35) {
      throw ArgumentError.value(
        opacity,
        'opacity',
        'Must be between 0.04 and 0.35.',
      );
    }
    if (!angleRadians.isFinite || angleRadians.abs() > 6.283185307179586) {
      throw ArgumentError.value(
        angleRadians,
        'angleRadians',
        'Must be within ±2π.',
      );
    }
    if (!widthFactor.isFinite || widthFactor < 0.1 || widthFactor > 0.95) {
      throw ArgumentError.value(
        widthFactor,
        'widthFactor',
        'Must be between 0.1 and 0.95.',
      );
    }
    if (!heightFactor.isFinite || heightFactor < 0.1 || heightFactor > 0.95) {
      throw ArgumentError.value(
        heightFactor,
        'heightFactor',
        'Must be between 0.1 and 0.95.',
      );
    }
  }

  final Uint8List _imageBytes;
  final double opacity;
  final double angleRadians;
  final double widthFactor;
  final double heightFactor;

  /// Returns a defensive copy of the watermark image.
  Uint8List get imageBytes => Uint8List.fromList(_imageBytes);

  static Uint8List _copyImage(Uint8List bytes) {
    if (bytes.isEmpty || bytes.length > 2 * 1024 * 1024) {
      throw ArgumentError('Watermark image must be 1 byte to 2 MiB.');
    }
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
    if (!isPng && !isJpeg) {
      throw ArgumentError('Watermark image must be PNG or JPEG.');
    }
    return Uint8List.fromList(bytes);
  }
}

/// Presentation-only options for one PDF rendering operation.
///
/// [generatedAt] must be supplied by the host. The engine never reads the
/// system clock or derives a document date.
final class DocumentRenderOptions {
  DocumentRenderOptions({
    required this.pageProfile,
    required this.generatedAt,
    this.showPageNumbers = true,
    this.headerText,
    this.footerText,
    this.firstPageHeaderText,
    this.firstPageFooterText,
    this.coverPage = false,
    this.watermark,
    this.branding,
    this.coverTitle,
    this.coverSubtitle,
    Map<String, String> coverMetadata = const {},
    this.maxPages = 100,
  }) : coverMetadata = Map<String, String>.unmodifiable(coverMetadata) {
    if (maxPages < 1 || maxPages > 1000) {
      throw ArgumentError.value(
        maxPages,
        'maxPages',
        'Must be between 1 and 1000.',
      );
    }
    if (coverPage && maxPages < 2) {
      throw ArgumentError(
        'A cover page and content require at least two pages.',
      );
    }
    if (coverPage && (coverTitle == null || coverTitle!.trim().isEmpty)) {
      throw ArgumentError('A cover page requires a non-empty coverTitle.');
    }
    if (!coverPage &&
        (coverTitle != null ||
            coverSubtitle != null ||
            coverMetadata.isNotEmpty)) {
      throw ArgumentError('Cover content requires coverPage to be enabled.');
    }
  }

  final DocumentPageProfile pageProfile;
  final DateTime generatedAt;
  final bool showPageNumbers;
  final String? headerText;
  final String? footerText;
  final String? firstPageHeaderText;
  final String? firstPageFooterText;
  final bool coverPage;
  final DocumentWatermark? watermark;

  /// Host-provided identity assets; never loaded from disk or network.
  final DocumentBranding? branding;
  final String? coverTitle;
  final String? coverSubtitle;
  final Map<String, String> coverMetadata;
  final int maxPages;
}
