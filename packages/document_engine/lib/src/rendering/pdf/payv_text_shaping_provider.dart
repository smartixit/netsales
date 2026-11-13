import 'dart:typed_data';

import 'package:payv/payv.dart' as payv;

import '../../document/document_locale.dart';
import 'document_font_weight.dart';

/// The selected OpenType shaping and Unicode bidirectional provider for PDFs.
///
/// One provider instance is created per supplied font family and reused for all text
/// runs in a document. The provider shapes one logical line at a time; line
/// breaking remains a layout responsibility so the paragraph base direction
/// can be preserved across wrapped lines.
final class PayvTextShapingProvider {
  factory PayvTextShapingProvider(
    Uint8List fontBytes, {
    String languageTag = 'ar',
    Uint8List? thinFontBytes,
    Uint8List? extraLightFontBytes,
    Uint8List? lightFontBytes,
    Uint8List? mediumFontBytes,
    Uint8List? semiBoldFontBytes,
    Uint8List? boldFontBytes,
  }) {
    final regularFace = _loadFace(fontBytes, weight: DocumentFontWeight.regular);
    final thinSource = thinFontBytes ?? extraLightFontBytes ?? lightFontBytes;
    final extraLightSource = extraLightFontBytes ?? lightFontBytes;
    final lightSource = lightFontBytes ?? extraLightFontBytes;
    final thinFace = thinSource == null
        ? regularFace
        : _loadFace(thinSource, weight: DocumentFontWeight.thin);
    final extraLightFace = extraLightSource == null
        ? regularFace
        : _loadFace(extraLightSource, weight: DocumentFontWeight.extraLight);
    final lightFace = lightSource == null
        ? regularFace
        : _loadFace(lightSource, weight: DocumentFontWeight.light);
    final mediumSource = mediumFontBytes ?? semiBoldFontBytes;
    final mediumFace = mediumSource == null
        ? regularFace
        : _loadFace(mediumSource, weight: DocumentFontWeight.medium);
    final semiBoldSource = semiBoldFontBytes ?? boldFontBytes ?? mediumFontBytes;
    final semiBoldFace = semiBoldSource == null
        ? regularFace
        : _loadFace(semiBoldSource, weight: DocumentFontWeight.semiBold);
    final boldSource = boldFontBytes ?? semiBoldFontBytes ?? mediumFontBytes;
    final boldFace = boldSource == null
        ? regularFace
        : _loadFace(boldSource, weight: DocumentFontWeight.bold);

    return PayvTextShapingProvider._(
      faces: {
        DocumentFontWeight.thin: thinFace,
        DocumentFontWeight.extraLight: extraLightFace,
        DocumentFontWeight.light: lightFace,
        DocumentFontWeight.regular: regularFace,
        DocumentFontWeight.medium: mediumFace,
        DocumentFontWeight.semiBold: semiBoldFace,
        DocumentFontWeight.bold: boldFace,
      },
      language: _openTypeLanguageTag(languageTag),
    );
  }

  PayvTextShapingProvider._({
    required Map<DocumentFontWeight, _PayvFontFace> faces,
    required int language,
  }) : _faces = Map<DocumentFontWeight, _PayvFontFace>.unmodifiable(faces),
       _language = language;

  final Map<DocumentFontWeight, _PayvFontFace> _faces;
  final int _language;

  /// Backwards-compatible regular face accessors.
  payv.PayvFont get font => fontFor(DocumentFontWeight.regular);
  Uint8List get fontBytes => fontBytesFor(DocumentFontWeight.regular);

  /// Returns the validated OpenType face selected for a semantic weight.
  payv.PayvFont fontFor(DocumentFontWeight weight) => _faces[weight]!.font;

  /// Returns a defensive copy of the selected face for PDF embedding.
  Uint8List fontBytesFor(DocumentFontWeight weight) =>
      Uint8List.fromList(_faces[weight]!.fontBytes);

  static _PayvFontFace _loadFace(
    Uint8List bytes, {
    required DocumentFontWeight weight,
  }) {
    if (bytes.isEmpty) {
      throw ArgumentError.value(bytes, 'fontBytes', 'Font bytes are empty.');
    }
    final copy = Uint8List.fromList(bytes);
    final font = payv.PayvFont.load(copy);
    if (!font.canEmbedInPdf || !font.canSubset) {
      throw DocumentFontEmbeddingException(weight: weight);
    }
    return _PayvFontFace(
      font: font,
      fontBytes: copy,
      shaper: payv.Shaper(font.raw),
    );
  }

  /// Resolves the paragraph's base direction once, before line wrapping.
  ///
  /// UAX #9 determines the base direction from the first strong character.
  /// Passing this resolved value to every wrapped line prevents a continuation
  /// beginning with an invoice code or Latin word from flipping an RTL block.
  DocumentTextDirection resolveDirection(
    String text, {
    DocumentTextDirection requested = DocumentTextDirection.auto,
  }) {
    if (requested != DocumentTextDirection.auto) return requested;
    final result = payv.Bidi.resolve(text.runes.toList(growable: false));
    return result.paragraphLevel.isOdd
        ? DocumentTextDirection.rightToLeft
        : DocumentTextDirection.leftToRight;
  }

  /// Shapes one logical line into visual-order bidi and script runs.
  ///
  /// The input must not contain paragraph separators. A caller splits
  /// paragraphs first, resolves their paragraph direction once, and passes
  /// that explicit direction to every wrapped line. This prevents a wrapped
  /// line beginning with Latin text from changing an RTL paragraph's base
  /// direction.
  ShapedDocumentLine shapeLine(
    String text, {
    DocumentTextDirection direction = DocumentTextDirection.auto,
    DocumentFontWeight fontWeight = DocumentFontWeight.regular,
  }) {
    final face = _faces[fontWeight]!;
    if (text.contains('\n') || text.contains('\r') ||
        text.contains('\u2028') || text.contains('\u2029')) {
      throw ArgumentError.value(
        text,
        'text',
        'shapeLine accepts one line without paragraph separators.',
      );
    }

    if (text.isEmpty) {
      return const ShapedDocumentLine(
        paragraphLevel: 0,
        visualRuns: <ShapedDocumentRun>[],
        advance: 0,
      );
    }

    final scalars = text.runes.toList(growable: false);
    final explicitLevel = switch (direction) {
      DocumentTextDirection.leftToRight => 0,
      DocumentTextDirection.rightToLeft => 1,
      DocumentTextDirection.auto => null,
    };

    // Payv implements UAX #9. It resolves isolates, paired brackets, Arabic
    // and European numbers, neutral punctuation, and visual run order.
    final bidi = payv.Bidi.resolve(
      scalars,
      paragraphLevel: explicitLevel,
    );
    final scriptRuns = payv.ScriptItemizer.itemize(scalars);
    final visualRuns = <ShapedDocumentRun>[];
    var totalAdvance = 0.0;

    for (final bidiRun in bidi.visualRuns) {
      final slices = _intersectScriptRuns(bidiRun, scriptRuns);
      final visualSlices = bidiRun.direction == payv.TextDirection.rtl
          ? slices.reversed.toList(growable: false)
          : slices;

      for (final slice in visualSlices) {
        final runScalars = scalars.sublist(slice.$1, slice.$2);
        final shaped = face.shaper.shapeScalars(
          runScalars,
          script: slice.$3,
          language: _language,
          direction: bidiRun.direction,
          clusterBase: slice.$1,
        );

        final clusterSources = _clusterSources(
          shaped,
          scalars: scalars,
          sliceEnd: slice.$2,
          direction: bidiRun.direction,
        );
        final glyphs = <ShapedDocumentGlyph>[];

        for (var index = 0; index < shaped.length; index++) {
          final info = shaped.infos[index];
          final position = shaped.positions[index];

          if (info.glyphId == 0 && !_isDefaultIgnorable(info.codepoint)) {
            throw DocumentTextGlyphMissingException(info.codepoint);
          }

          final outline = face.font.raw.outline(info.glyphId);
          if (outline == null) {
            throw const UnsupportedDocumentFontException(
              'Only TrueType glyf outlines are supported by the selected '
              'Payv renderer integration. CFF/CFF2 fonts are not accepted.',
            );
          }

          glyphs.add(
            ShapedDocumentGlyph(
              glyphId: info.glyphId,
              sourceCodepoint: info.codepoint,
              cluster: info.cluster,
              sourceCodepoints: clusterSources[index],
              xAdvance: position.xAdvance,
              yAdvance: position.yAdvance,
              xOffset: position.xOffset,
              yOffset: position.yOffset,
              outline: outline,
            ),
          );
          totalAdvance += position.xAdvance;
        }

        visualRuns.add(
          ShapedDocumentRun(
            scriptTag: slice.$3,
            direction: bidiRun.direction,
            glyphs: glyphs,
          ),
        );
      }
    }

    return ShapedDocumentLine(
      paragraphLevel: bidi.paragraphLevel,
      visualRuns: visualRuns,
      advance: totalAdvance,
    );
  }

  static List<(int, int, int)> _intersectScriptRuns(
    payv.BidiRun bidiRun,
    List<payv.ScriptRun> scriptRuns,
  ) {
    final result = <(int, int, int)>[];
    for (final scriptRun in scriptRuns) {
      final start = bidiRun.start > scriptRun.start
          ? bidiRun.start
          : scriptRun.start;
      final end = bidiRun.end < scriptRun.end ? bidiRun.end : scriptRun.end;
      if (start < end) {
        result.add((start, end, scriptRun.scriptTag));
      }
    }
    return result;
  }

  /// Maps the original logical text cluster to one glyph only.
  ///
  /// RTL shaped runs are already in visual order. The last visual glyph is the
  /// logically first glyph in an RTL cluster, so it carries the source text.
  /// This is the same cluster-carrier rule used by Payv's PDF text engine and
  /// prevents ligature text from being repeated during extraction.
  static List<List<int>> _clusterSources(
    payv.ShapedRun run, {
    required List<int> scalars,
    required int sliceEnd,
    required payv.TextDirection direction,
  }) {
    final carrier = <int, int>{};
    for (var index = 0; index < run.length; index++) {
      final cluster = run.infos[index].cluster;
      if (direction == payv.TextDirection.rtl || !carrier.containsKey(cluster)) {
        carrier[cluster] = index;
      }
    }

    final clusters = carrier.keys.toList()..sort();
    final sources = List<List<int>>.filled(
      run.length,
      const <int>[],
      growable: false,
    );

    for (var index = 0; index < clusters.length; index++) {
      final cluster = clusters[index];
      final end = index + 1 < clusters.length
          ? clusters[index + 1]
          : sliceEnd;
      final source = scalars
          .sublist(cluster, end)
          .where((codepoint) => !_isDefaultIgnorable(codepoint))
          .toList(growable: false);
      final glyphIndex = carrier[cluster]!;
      sources[glyphIndex] = List<int>.unmodifiable(source);
    }

    return sources;
  }

  static bool _isDefaultIgnorable(int codepoint) {
    return codepoint == 0x00AD ||
        codepoint == 0x034F ||
        codepoint == 0x061C ||
        codepoint == 0x115F ||
        codepoint == 0x1160 ||
        (codepoint >= 0x17B4 && codepoint <= 0x17B5) ||
        (codepoint >= 0x180B && codepoint <= 0x180F) ||
        (codepoint >= 0x200B && codepoint <= 0x200F) ||
        (codepoint >= 0x202A && codepoint <= 0x202E) ||
        (codepoint >= 0x2060 && codepoint <= 0x206F) ||
        codepoint == 0x3164 ||
        (codepoint >= 0xFE00 && codepoint <= 0xFE0F) ||
        codepoint == 0xFEFF ||
        codepoint == 0xFFA0 ||
        (codepoint >= 0xFFF0 && codepoint <= 0xFFF8) ||
        (codepoint >= 0x1BCA0 && codepoint <= 0x1BCA3) ||
        (codepoint >= 0x1D173 && codepoint <= 0x1D17A) ||
        (codepoint >= 0xE0000 && codepoint <= 0xE0FFF);
  }

  static int _openTypeLanguageTag(String languageTag) {
    final language = languageTag.split('-').first.toLowerCase();
    return switch (language) {
      'ar' => payv.Tag.ara,
      'fa' => payv.Tag.fas,
      'ur' => payv.Tag.urd,
      'ku' => payv.Tag.kur,
      _ => payv.Tag.dflt,
    };
  }
}

final class _PayvFontFace {
  const _PayvFontFace({
    required this.font,
    required this.fontBytes,
    required this.shaper,
  });

  final payv.PayvFont font;
  final Uint8List fontBytes;
  final payv.Shaper shaper;
}

/// One glyph with shaped positioning and its original Unicode cluster.
final class ShapedDocumentGlyph {
  const ShapedDocumentGlyph({
    required this.glyphId,
    required this.sourceCodepoint,
    required this.cluster,
    required this.sourceCodepoints,
    required this.xAdvance,
    required this.yAdvance,
    required this.xOffset,
    required this.yOffset,
    required this.outline,
  });

  final int glyphId;
  final int sourceCodepoint;
  final int cluster;

  /// Original Unicode scalars carried by this glyph for text extraction.
  /// Empty for the other glyphs that belong to the same cluster.
  final List<int> sourceCodepoints;

  /// OpenType design-unit positions, not PDF points.
  final int xAdvance;
  final int yAdvance;
  final int xOffset;
  final int yOffset;

  final payv.GlyphPath outline;
}

/// A visually ordered run that has one bidi direction and OpenType script.
final class ShapedDocumentRun {
  ShapedDocumentRun({
    required this.scriptTag,
    required this.direction,
    required Iterable<ShapedDocumentGlyph> glyphs,
  }) : glyphs = List<ShapedDocumentGlyph>.unmodifiable(glyphs);

  final int scriptTag;
  final payv.TextDirection direction;
  final List<ShapedDocumentGlyph> glyphs;
}

/// The visual glyph program for one logical text line.
final class ShapedDocumentLine {
  ShapedDocumentLine({
    required this.paragraphLevel,
    required Iterable<ShapedDocumentRun> visualRuns,
    required this.advance,
  }) : visualRuns = List<ShapedDocumentRun>.unmodifiable(visualRuns);

  const ShapedDocumentLine.empty()
    : paragraphLevel = 0,
      visualRuns = const <ShapedDocumentRun>[],
      advance = 0;

  final int paragraphLevel;
  final List<ShapedDocumentRun> visualRuns;

  /// Total horizontal advance in the font's design units.
  final double advance;

  bool get isRightToLeft => paragraphLevel.isOdd;
}

/// The selected font does not permit PDF embedding or subsetting.
final class DocumentFontEmbeddingException implements Exception {
  const DocumentFontEmbeddingException({this.weight});

  final DocumentFontWeight? weight;

  @override
  String toString() => weight == null
      ? 'The supplied font licence flags do not permit PDF embedding/subsetting.'
      : 'The ${weight!.name} font licence flags do not permit PDF embedding/subsetting.';
}

/// The selected font has no glyph for a required source character.
final class DocumentTextGlyphMissingException implements Exception {
  const DocumentTextGlyphMissingException(this.codepoint);

  final int codepoint;

  @override
  String toString() =>
      'The supplied document font has no glyph for U+'
      '${codepoint.toRadixString(16).toUpperCase().padLeft(4, '0')}.';
}

/// The supplied font uses an outline format unsupported by Payv's PDF path.
final class UnsupportedDocumentFontException implements Exception {
  const UnsupportedDocumentFontException(this.message);

  final String message;

  @override
  String toString() => message;
}
