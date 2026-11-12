import 'dart:typed_data';

import 'package:flutter/services.dart';

/// Loads the bundled IBM Plex Sans Arabic Regular font for document shaping.
///
/// The font is licensed under SIL OFL 1.1; its licence is included in the
/// document_engine package assets. Hosts may instead provide another licensed
/// TrueType font through DocumentBranding or PayvTextShapingProvider.
Future<Uint8List> loadDocumentEngineArabicFont() async {
  final data = await rootBundle.load(
    'packages/document_engine/assets/fonts/IBMPlexSansArabic-Regular.ttf',
  );
  return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
}
