import 'package:characters/characters.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../document/document_locale.dart';
import 'document_font_weight.dart';
import 'payv_text_shaping_provider.dart';
import 'shaped_pdf_text_line.dart';

/// Paragraph flow for shaped text.
///
/// Each logical paragraph resolves its UAX #9 base direction once. Candidate
/// lines are measured after OpenType shaping, and wrapping preserves source
/// whitespace while never splitting a Unicode grapheme cluster.
final class ShapedPdfParagraph extends pw.StatelessWidget {
  ShapedPdfParagraph({
    required this.text,
    required this.provider,
    required this.width,
    required this.fontSize,
    this.color = PdfColors.black,
    this.fontWeight = DocumentFontWeight.regular,
    this.direction = DocumentTextDirection.auto,
    this.alignment = ShapedPdfTextAlignment.start,
    this.lineHeight = 1.65,
    this.paragraphSpacing = 0,
  }) {
    if (!width.isFinite || width <= 0 || width > 2000) {
      throw ArgumentError.value(width, 'width', 'Must be in (0, 2000].');
    }
    if (!fontSize.isFinite || fontSize <= 0 || fontSize > 144) {
      throw ArgumentError.value(fontSize, 'fontSize', 'Must be in (0, 144].');
    }
    if (!lineHeight.isFinite || lineHeight < 1 || lineHeight > 3) {
      throw ArgumentError.value(lineHeight, 'lineHeight', 'Must be in [1, 3].');
    }
    if (!paragraphSpacing.isFinite ||
        paragraphSpacing < 0 ||
        paragraphSpacing > 100) {
      throw ArgumentError.value(
        paragraphSpacing,
        'paragraphSpacing',
        'Must be in [0, 100].',
      );
    }
  }

  final String text;
  final PayvTextShapingProvider provider;
  final double width;
  final double fontSize;
  final PdfColor color;
  final DocumentFontWeight fontWeight;
  final DocumentTextDirection direction;
  final ShapedPdfTextAlignment alignment;
  final double lineHeight;
  final double paragraphSpacing;

  double _measure(String value, DocumentTextDirection resolvedDirection) {
    return provider.shapeLine(
          value,
          direction: resolvedDirection,
          fontWeight: fontWeight,
        ).advance *
        fontSize /
        provider.fontFor(fontWeight).unitsPerEm;
  }

  @override
  pw.Widget build(pw.Context context) {
    final widgets = <pw.Widget>[];
    final paragraphs = text
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .split(RegExp('[\u2028\u2029\n]'));

    for (var paragraphIndex = 0;
        paragraphIndex < paragraphs.length;
        paragraphIndex++) {
      final paragraph = paragraphs[paragraphIndex];
      if (paragraph.isEmpty) {
        widgets.add(pw.SizedBox(height: fontSize * lineHeight));
        continue;
      }

      // Resolve once for the whole paragraph. A wrapped line beginning with
      // an English invoice number must not flip an Arabic paragraph to LTR.
      final resolvedDirection = provider.resolveDirection(
        paragraph,
        requested: direction,
      );
      final tokens = RegExp(r'\s+|\S+')
          .allMatches(paragraph)
          .map((match) => match.group(0)!)
          .toList(growable: false);
      var current = '';

      void emit(String value) {
        if (value.isEmpty) return;
        widgets.add(
          ShapedPdfTextLine(
            text: value,
            provider: provider,
            width: width,
            fontSize: fontSize,
            height: fontSize * lineHeight,
            color: color,
            direction: resolvedDirection,
            fontWeight: fontWeight,
            alignment: alignment,
          ),
        );
      }

      for (final token in tokens) {
        final isWhitespace = token.trim().isEmpty;
        if (current.isEmpty && isWhitespace) continue;

        final candidate = '$current$token';
        if (_measure(candidate, resolvedDirection) <= width) {
          current = candidate;
          continue;
        }

        if (current.isNotEmpty) {
          emit(current.trimRight());
          current = '';
        }
        if (isWhitespace) continue;

        if (_measure(token, resolvedDirection) <= width) {
          current = token;
          continue;
        }

        // Long URLs and identifiers have no legal whitespace break. Use
        // Unicode grapheme clusters so combining marks and emoji sequences
        // remain indivisible. Arabic shaping is recalculated for each fragment.
        var fragment = '';
        for (final grapheme in token.characters) {
          final next = '$fragment$grapheme';
          if (fragment.isNotEmpty &&
              _measure(next, resolvedDirection) > width) {
            emit(fragment);
            fragment = grapheme;
            if (_measure(fragment, resolvedDirection) > width) {
              throw ArgumentError(
                'An unbreakable grapheme exceeds the allocated line width.',
              );
            }
          } else {
            fragment = next;
            if (_measure(fragment, resolvedDirection) > width) {
              throw ArgumentError(
                'An unbreakable grapheme exceeds the allocated line width.',
              );
            }
          }
        }
        current = fragment;
      }

      if (current.isNotEmpty) emit(current.trimRight());
      if (paragraphIndex < paragraphs.length - 1 &&
          paragraphSpacing > 0) {
        widgets.add(pw.SizedBox(height: paragraphSpacing));
      }
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: widgets,
    );
  }
}
