import '../document/document_branding.dart';
import 'document_page_profile.dart';

/// A visible presentation watermark; it does not alter document status.
final class DocumentWatermark {
  DocumentWatermark({
    required this.text,
    this.color = '64748B',
    this.opacity = 0.12,
    this.angleRadians = -0.7853981633974483,
  }) {
    if (text.trim().isEmpty || text.length > 80) {
      throw ArgumentError.value(text, 'text', 'Must contain 1-80 chars.');
    }
    if (!RegExp(r'^[0-9A-Fa-f]{6}$').hasMatch(color)) {
      throw ArgumentError.value(color, 'color', 'Use six-digit RGB hex.');
    }
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
  }

  final String text;
  final String color;
  final double opacity;
  final double angleRadians;
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
