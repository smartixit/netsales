import 'dart:typed_data';

import 'package:document_engine/document_engine.dart';
import 'package:document_engine/document_engine_flutter.dart';

/// Shared host-owned IBM Plex Sans Arabic font faces and Payv shaping provider.
///
/// The service loads the four licensed app asset faces once, keeps an immutable
/// defensive copy, and reuses the parsed Payv provider across all document
/// features (invoices, chart exports, and operational reports).
class DocumentEngineFontService {
  DocumentEngineFontService._();

  static final DocumentEngineFontService instance =
      DocumentEngineFontService._();

  Future<Map<DocumentFontWeight, Uint8List>>? _facesFuture;
  PayvTextShapingProvider? _arabicProvider;

  Future<Map<DocumentFontWeight, Uint8List>> loadArabicFontFaces() async {
    final future = _facesFuture ??= loadDocumentEngineFontFaces(
      regularAssetPath: 'assets/fonts/IBM-Regular.ttf',
      mediumAssetPath: 'assets/fonts/IBM-Medium.ttf',
      semiBoldAssetPath: 'assets/fonts/IBM-SemiBold.ttf',
      boldAssetPath: 'assets/fonts/IBM-Bold.ttf',
    );
    final faces = await future;
    return Map<DocumentFontWeight, Uint8List>.unmodifiable({
      for (final entry in faces.entries)
        entry.key: Uint8List.fromList(entry.value),
    });
  }

  Future<PayvTextShapingProvider> arabicTextShapingProvider() async {
    final existing = _arabicProvider;
    if (existing != null) return existing;

    final faces = await loadArabicFontFaces();
    return _arabicProvider ??= PayvTextShapingProvider(
      faces[DocumentFontWeight.regular]!,
      languageTag: 'ar-YE',
      mediumFontBytes: faces[DocumentFontWeight.medium],
      semiBoldFontBytes: faces[DocumentFontWeight.semiBold],
      boldFontBytes: faces[DocumentFontWeight.bold],
    );
  }

  Future<Map<DocumentFontRole, Uint8List>> loadArabicBrandingFonts() async {
    final faces = await loadArabicFontFaces();
    return Map<DocumentFontRole, Uint8List>.unmodifiable({
      DocumentFontRole.body: faces[DocumentFontWeight.regular]!,
      DocumentFontRole.medium: faces[DocumentFontWeight.medium]!,
      DocumentFontRole.semiBold: faces[DocumentFontWeight.semiBold]!,
      DocumentFontRole.bold: faces[DocumentFontWeight.bold]!,
      DocumentFontRole.heading: faces[DocumentFontWeight.bold]!,
      DocumentFontRole.display: faces[DocumentFontWeight.bold]!,
      DocumentFontRole.numeric: faces[DocumentFontWeight.regular]!,
    });
  }
}
