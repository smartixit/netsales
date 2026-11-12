import 'dart:typed_data';

import 'package:flutter/services.dart';

import '../rendering/pdf/document_font_weight.dart';

/// Loads the package-bundled IBM Plex Sans Arabic Regular face.
///
/// Existing integrations can keep using this helper. Full weight families
/// should use [loadDocumentEngineFontFaces] with the host's licensed assets.
Future<Uint8List> loadDocumentEngineArabicFont() async {
  final data = await rootBundle.load(
    'packages/document_engine/assets/fonts/IBMPlexSansArabic-Regular.ttf',
  );
  return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
}

/// Loads actual OpenType font files for the requested weights from the host
/// asset bundle. Missing optional weights are intentionally omitted; the
/// shaping provider falls back to the nearest available supplied face.
///
/// This allows a host to reuse its existing IBM Plex Sans Arabic assets
/// without duplicating large font binaries inside this package.
Future<Map<DocumentFontWeight, Uint8List>> loadDocumentEngineFontFaces({
  required String regularAssetPath,
  String? mediumAssetPath,
  String? semiBoldAssetPath,
  String? boldAssetPath,
}) async {
  Future<Uint8List> load(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    return Uint8List.fromList(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
    );
  }

  final entries = <DocumentFontWeight, Uint8List>{
    DocumentFontWeight.regular: await load(regularAssetPath),
  };

  if (mediumAssetPath != null) {
    entries[DocumentFontWeight.medium] = await load(mediumAssetPath);
  }
  if (semiBoldAssetPath != null) {
    entries[DocumentFontWeight.semiBold] = await load(semiBoldAssetPath);
  }
  if (boldAssetPath != null) {
    entries[DocumentFontWeight.bold] = await load(boldAssetPath);
  }

  return Map<DocumentFontWeight, Uint8List>.unmodifiable(entries);
}
