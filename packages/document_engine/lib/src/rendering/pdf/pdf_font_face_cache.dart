import 'dart:typed_data';

import 'package:pdf/widgets.dart' as pw;

import 'document_font_weight.dart';
import 'payv_text_shaping_provider.dart';

/// Shares one embedded PDF font object per shaping provider and semantic face.
///
/// Both the visible vector-outline layer and the logical Unicode text layer
/// use this cache, preventing duplicate font subsets for the same face.
final Expando<Map<DocumentFontWeight, pw.Font>> _pdfFontFaces =
    Expando<Map<DocumentFontWeight, pw.Font>>('document-engine-pdf-font-faces');

pw.Font pdfFontFace(
  PayvTextShapingProvider provider,
  DocumentFontWeight weight,
) {
  final faces = _pdfFontFaces[provider] ??= <DocumentFontWeight, pw.Font>{};
  return faces.putIfAbsent(
    weight,
    () => pw.Font.ttf(
      ByteData.sublistView(provider.fontBytesFor(weight)),
    ),
  );
}
