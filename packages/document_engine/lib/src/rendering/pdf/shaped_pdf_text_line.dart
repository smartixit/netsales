import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../document/document_locale.dart';
import 'document_font_weight.dart';
import 'payv_text_shaping_provider.dart';
import 'pdf_font_face_cache.dart';

double _pathCoordinate(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }
  throw StateError('Payv outline coordinate is not numeric: $value');
}

/// A single-line, vector-outline PDF text widget.
///
/// Shaped glyph commands are emitted directly to PdfGraphics. Payv's
/// GlyphPath.toPdfPath() returns a PDF content-stream fragment, while
/// PdfGraphics.drawShape() accepts SVG path syntax; mixing those two formats
/// would produce invalid outlines. This adapter deliberately maps each
/// command to the corresponding PdfGraphics operation instead.
final class ShapedPdfTextLine extends pw.StatelessWidget {
  ShapedPdfTextLine({
    required this.text,
    required this.provider,
    required this.width,
    required this.fontSize,
    this.height,
    this.color = PdfColors.black,
    this.fontWeight = DocumentFontWeight.regular,
    this.direction = DocumentTextDirection.auto,
    this.alignment = ShapedPdfTextAlignment.start,
  }) {
    if (text.contains('\n') || text.contains('\r') ||
        text.contains('\u2028') || text.contains('\u2029')) {
      throw ArgumentError.value(text, 'text', 'Only one line is accepted.');
    }
    if (!width.isFinite || width <= 0 || width > 2000) {
      throw ArgumentError.value(width, 'width', 'Must be in (0, 2000].');
    }
    if (!fontSize.isFinite || fontSize <= 0 || fontSize > 144) {
      throw ArgumentError.value(fontSize, 'fontSize', 'Must be in (0, 144].');
    }
    if (height != null &&
        (!height!.isFinite || height! <= 0 || height! > 500)) {
      throw ArgumentError.value(height, 'height', 'Must be in (0, 500].');
    }
  }

  final String text;
  final PayvTextShapingProvider provider;
  final double width;
  final double fontSize;
  final double? height;
  final PdfColor color;
  final DocumentFontWeight fontWeight;
  final DocumentTextDirection direction;
  final ShapedPdfTextAlignment alignment;

  @override
  pw.Widget build(pw.Context context) {
    final shaped = provider.shapeLine(text, direction: direction, fontWeight: fontWeight);
    final scale = fontSize / provider.fontFor(fontWeight).unitsPerEm;
    final measuredWidth = shaped.advance * scale;
    final boxHeight = height ?? fontSize * 1.8;

    if (measuredWidth > width + 0.01) {
      throw ArgumentError(
        'The shaped line requires ${measuredWidth.toStringAsFixed(2)} pt '
        'but its allocated width is ${width.toStringAsFixed(2)} pt. '
        'Use the paragraph-flow adapter for wrapping.',
      );
    }

    final freeSpace = width - measuredWidth;
    final startX = switch (alignment) {
      ShapedPdfTextAlignment.start =>
        shaped.isRightToLeft ? freeSpace : 0.0,
      ShapedPdfTextAlignment.end =>
        shaped.isRightToLeft ? 0.0 : freeSpace,
      ShapedPdfTextAlignment.center => freeSpace / 2,
      ShapedPdfTextAlignment.left => 0.0,
      ShapedPdfTextAlignment.right => freeSpace,
    };

    final unicodeFont = pdfFontFace(provider, fontWeight);

    return pw.Stack(
      children: [
        pw.CustomPaint(
          size: PdfPoint(width, boxHeight),
          painter: (canvas, size) {
        var penX = startX;
        final baseline = (boxHeight - fontSize) / 2;
        for (final run in shaped.visualRuns) {
          for (final glyph in run.glyphs) {
            final originX = penX + glyph.xOffset * scale;
            final originY = baseline + glyph.yOffset * scale;
            canvas.setFillColor(color);

            for (final command in glyph.outline.cubicCommands) {
              final dynamic pathCommand = command;
              switch (command.runtimeType.toString()) {
                case 'MoveTo':
                  canvas.moveTo(
                    originX + _pathCoordinate(pathCommand.x) * scale,
                    originY + _pathCoordinate(pathCommand.y) * scale,
                  );
                case 'LineTo':
                  canvas.lineTo(
                    originX + _pathCoordinate(pathCommand.x) * scale,
                    originY + _pathCoordinate(pathCommand.y) * scale,
                  );
                case 'CubicTo':
                  canvas.curveTo(
                    originX + _pathCoordinate(pathCommand.c1x) * scale,
                    originY + _pathCoordinate(pathCommand.c1y) * scale,
                    originX + _pathCoordinate(pathCommand.c2x) * scale,
                    originY + _pathCoordinate(pathCommand.c2y) * scale,
                    originX + _pathCoordinate(pathCommand.x) * scale,
                    originY + _pathCoordinate(pathCommand.y) * scale,
                  );
                case 'QuadTo':
                  // cubicCommands converts every quadratic exactly. Keep this
                  // defensive branch so a future Payv API change fails loudly.
                  throw StateError(
                    'Payv cubicCommands returned an unconverted quadratic.',
                  );
                case 'ClosePath':
                  canvas.closePath();
                default:
                  throw StateError('Unsupported Payv outline command: $command');
              }
            }
            if (glyph.outline.isNotEmpty) {
              canvas.fillPath();
            }
            penX += glyph.xAdvance * scale;
          }
        }
      },
        ),
        // Preserve the original logical Unicode string in the PDF content
        // stream. This invisible text layer supplies extraction/search/copy
        // semantics; the visible layer is drawn from Payv-shaped glyph paths.
        // LTR is intentional: logical source order must not be visually
        // reordered in the text layer.
        pw.Positioned.fill(
          child: pw.Text(
            text,
            textDirection: pw.TextDirection.ltr,
            textAlign: pw.TextAlign.left,
            softWrap: false,
            maxLines: 1,
            style: pw.TextStyle(
              font: unicodeFont,
              fontSize: fontSize,
              renderingMode: PdfTextRenderingMode.invisible,
            ),
          ),
        ),
      ],
    );
  }
}

/// Alignment follows the resolved paragraph direction for start/end.
enum ShapedPdfTextAlignment { start, end, left, right, center }
