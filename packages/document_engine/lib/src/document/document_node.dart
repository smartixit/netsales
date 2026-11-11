import 'dart:convert';
import 'dart:typed_data';

import '../core/stable_identifier.dart';
import 'document_locale.dart';
import 'document_value.dart';

/// Base type for typed document content nodes.
abstract class DocumentNode {
  const DocumentNode();
}

final class DocumentParagraph extends DocumentNode {
  const DocumentParagraph({
    required this.text,
    this.direction = DocumentTextDirection.auto,
  });

  final String text;
  final DocumentTextDirection direction;
}

final class DocumentHeading extends DocumentNode {
  DocumentHeading({
    required this.text,
    this.level = 1,
    this.direction = DocumentTextDirection.auto,
  }) {
    if (level < 1 || level > 6) {
      throw ArgumentError.value(level, 'level', 'Must be between 1 and 6.');
    }
  }

  final String text;
  final int level;
  final DocumentTextDirection direction;
}

/// A supplied display value. The engine does not derive or aggregate it.
final class DocumentMetric extends DocumentNode {
  DocumentMetric({required String label, required this.value, this.caption})
    : label = _requireLabel(label);

  final String label;
  final DocumentValue value;
  final String? caption;

  static String _requireLabel(String value) {
    if (value.trim().isEmpty) {
      throw ArgumentError.value(value, 'label', 'Must not be empty.');
    }
    return value;
  }
}

/// A group of already-calculated metrics arranged as a compact visual grid.
final class DocumentMetricGrid extends DocumentNode {
  DocumentMetricGrid({
    required Iterable<DocumentMetric> metrics,
    this.columns = 2,
  }) : metrics = List<DocumentMetric>.unmodifiable(metrics) {
    if (this.metrics.isEmpty || this.metrics.length > 20) {
      throw ArgumentError(
        'A metric grid must contain between one and twenty metrics.',
      );
    }
    if (columns < 1 || columns > 4) {
      throw ArgumentError.value(columns, 'columns', 'Must be between 1 and 4.');
    }
  }

  final List<DocumentMetric> metrics;
  final int columns;
}

enum DocumentCellAlignment { leading, center, trailing, decimal }

/// Presentation hints for a structured table. Values remain supplied by the host.
final class DocumentTableStyle {
  DocumentTableStyle({
    this.stripedRows = false,
    this.compact = false,
    this.showBorders = true,
    this.headerColor = 'F1F5F9',
    this.alternateRowColor = 'F8FAFC',
    Iterable<double>? columnWeights,
  }) : columnWeights = columnWeights == null
           ? null
           : List<double>.unmodifiable(columnWeights) {
    _validateColor(headerColor, 'headerColor');
    _validateColor(alternateRowColor, 'alternateRowColor');
    if (this.columnWeights != null &&
        (this.columnWeights!.isEmpty ||
            this.columnWeights!.any(
              (weight) => !weight.isFinite || weight <= 0,
            ))) {
      throw ArgumentError.value(
        columnWeights,
        'columnWeights',
        'Weights must be finite positive numbers.',
      );
    }
  }

  final bool stripedRows;
  final bool compact;
  final bool showBorders;
  final String headerColor;
  final String alternateRowColor;
  final List<double>? columnWeights;

  static void _validateColor(String value, String name) {
    if (!RegExp(r'^[0-9A-Fa-f]{6}$').hasMatch(value)) {
      throw ArgumentError.value(value, name, 'Use a six-digit RGB hex value.');
    }
  }
}

final class DocumentTableColumn {
  DocumentTableColumn({
    required String id,
    required String label,
    this.alignment = DocumentCellAlignment.leading,
  }) : id = validateStableIdentifier(id, parameterName: 'columnId'),
       label = _requireLabel(label);

  final String id;
  final String label;
  final DocumentCellAlignment alignment;

  static String _requireLabel(String value) {
    if (value.trim().isEmpty) {
      throw ArgumentError.value(value, 'label', 'Must not be empty.');
    }
    return value;
  }
}

final class DocumentTableCell {
  const DocumentTableCell({required this.value, this.direction});

  final DocumentValue value;
  final DocumentTextDirection? direction;
}

final class DocumentTableRow {
  DocumentTableRow({
    required String id,
    required Iterable<DocumentTableCell> cells,
  }) : id = validateStableIdentifier(id, parameterName: 'rowId'),
       cells = List<DocumentTableCell>.unmodifiable(cells);

  final String id;
  final List<DocumentTableCell> cells;
}

/// A structured table. Row/cell count must match the declared columns.
final class DocumentTable extends DocumentNode {
  DocumentTable({
    required Iterable<DocumentTableColumn> columns,
    required Iterable<DocumentTableRow> rows,
    DocumentTableStyle? style,
  }) : columns = List<DocumentTableColumn>.unmodifiable(columns),
       rows = List<DocumentTableRow>.unmodifiable(rows),
       style = style ?? DocumentTableStyle() {
    final columnIds = this.columns.map((column) => column.id).toSet();
    if (this.columns.isEmpty || columnIds.length != this.columns.length) {
      throw ArgumentError(
        'Table columns must be non-empty and uniquely identified.',
      );
    }

    final rowIds = this.rows.map((row) => row.id).toSet();
    if (rowIds.length != this.rows.length) {
      throw ArgumentError('Table row identifiers must be unique.');
    }

    for (final row in this.rows) {
      if (row.cells.length != this.columns.length) {
        throw ArgumentError.value(
          row.cells.length,
          'row.cells.length',
          'Must match the number of table columns.',
        );
      }
    }

    if (this.style.columnWeights != null &&
        (this.style.columnWeights!.length != this.columns.length ||
            this.style.columnWeights!.any(
              (weight) => !weight.isFinite || weight <= 0,
            ))) {
      throw ArgumentError.value(
        this.style.columnWeights!.length,
        'style.columnWeights',
        'Must match the number of table columns.',
      );
    }
  }

  final List<DocumentTableColumn> columns;
  final List<DocumentTableRow> rows;
  final DocumentTableStyle style;
}

enum DocumentChartType { bar, line, pie, donut }

final class DocumentChartPoint {
  DocumentChartPoint({
    required String label,
    required this.value,
    this.displayValue,
  }) : label = _requireText(label, 'label') {
    if (!value.isFinite) {
      throw ArgumentError.value(value, 'value', 'Must be finite.');
    }
  }

  final String label;
  final double value;
  final String? displayValue;

  static String _requireText(String value, String name) {
    if (value.trim().isEmpty) {
      throw ArgumentError.value(value, name, 'Must not be empty.');
    }
    return value;
  }
}

final class DocumentChartSeries {
  DocumentChartSeries({
    required String id,
    required String label,
    required Iterable<DocumentChartPoint> points,
    this.color = '0D7A5F',
  }) : id = validateStableIdentifier(id, parameterName: 'seriesId'),
       label = _requireText(label, 'label'),
       points = List<DocumentChartPoint>.unmodifiable(points) {
    if (this.points.isEmpty) {
      throw ArgumentError('A chart series must contain at least one point.');
    }
    if (!RegExp(r'^[0-9A-Fa-f]{6}$').hasMatch(color)) {
      throw ArgumentError.value(
        color,
        'color',
        'Use a six-digit RGB hex value.',
      );
    }
  }

  final String id;
  final String label;
  final List<DocumentChartPoint> points;
  final String color;

  static String _requireText(String value, String name) {
    if (value.trim().isEmpty) {
      throw ArgumentError.value(value, name, 'Must not be empty.');
    }
    return value;
  }
}

/// Vector chart input. The renderer never aggregates or derives source values.
final class DocumentChart extends DocumentNode {
  DocumentChart({
    required String title,
    required this.type,
    required Iterable<DocumentChartSeries> series,
    this.subtitle,
    this.showLegend = true,
    this.showGrid = true,
  }) : title = _requireText(title, 'title'),
       series = List<DocumentChartSeries>.unmodifiable(series) {
    if (this.series.isEmpty || this.series.length > 8) {
      throw ArgumentError('A chart must contain between one and eight series.');
    }
    final ids = this.series.map((item) => item.id).toSet();
    if (ids.length != this.series.length) {
      throw ArgumentError('Chart series identifiers must be unique.');
    }

    if (type == DocumentChartType.pie || type == DocumentChartType.donut) {
      if (this.series.length != 1) {
        throw ArgumentError('Pie and donut charts require exactly one series.');
      }
      if (this.series.single.points.length > 12) {
        throw ArgumentError(
          'Pie and donut charts support at most twelve slices.',
        );
      }
      final values = this.series.single.points.map((point) => point.value);
      if (values.any((value) => value < 0) ||
          values.every((value) => value == 0)) {
        throw ArgumentError(
          'Pie and donut values must be non-negative with a positive total.',
        );
      }
    } else {
      if (this.series.any((item) => item.points.length > 24)) {
        throw ArgumentError(
          'Cartesian chart series support at most 24 points.',
        );
      }
      final labels = this.series.first.points
          .map((point) => point.label)
          .toList();
      if (this.series.any(
        (item) =>
            item.points.length != labels.length ||
            !item.points
                .map((point) => point.label)
                .toList()
                .asMap()
                .entries
                .every((entry) => entry.value == labels[entry.key]),
      )) {
        throw ArgumentError(
          'All Cartesian chart series must share the same categories.',
        );
      }
    }
  }

  final String title;
  final String? subtitle;
  final DocumentChartType type;
  final List<DocumentChartSeries> series;
  final bool showLegend;
  final bool showGrid;

  static String _requireText(String value, String name) {
    if (value.trim().isEmpty) {
      throw ArgumentError.value(value, name, 'Must not be empty.');
    }
    return value;
  }
}

final class DocumentPageBreak extends DocumentNode {
  const DocumentPageBreak();
}

enum DocumentImageFit { contain, cover, fill }

enum DocumentImageAlignment { leading, center, trailing }

/// A bounded image asset supplied by the host; the engine never fetches URLs.
final class DocumentImage extends DocumentNode {
  DocumentImage({
    required Uint8List bytes,
    this.caption,
    this.widthPoints,
    this.heightPoints,
    this.fit = DocumentImageFit.contain,
    this.alignment = DocumentImageAlignment.center,
  }) : _bytes = Uint8List.fromList(bytes) {
    if (_bytes.isEmpty || _bytes.length > 4 * 1024 * 1024) {
      throw ArgumentError('Document image must be 1 byte to 4 MiB.');
    }
    final isPng =
        _bytes.length >= 8 &&
        _bytes[0] == 0x89 &&
        _bytes[1] == 0x50 &&
        _bytes[2] == 0x4E &&
        _bytes[3] == 0x47 &&
        _bytes[4] == 0x0D &&
        _bytes[5] == 0x0A &&
        _bytes[6] == 0x1A &&
        _bytes[7] == 0x0A;
    final isJpeg =
        _bytes.length >= 3 &&
        _bytes[0] == 0xFF &&
        _bytes[1] == 0xD8 &&
        _bytes[2] == 0xFF;
    if (!isPng && !isJpeg) {
      throw ArgumentError('Document image must be PNG or JPEG.');
    }
    if (caption != null && (caption!.trim().isEmpty || caption!.length > 240)) {
      throw ArgumentError.value(
        caption,
        'caption',
        'Must contain 1-240 characters when supplied.',
      );
    }
    for (final entry in {
      'widthPoints': widthPoints,
      'heightPoints': heightPoints,
    }.entries) {
      if (entry.value != null &&
          (!entry.value!.isFinite ||
              entry.value! <= 0 ||
              entry.value! > 1200)) {
        throw ArgumentError.value(
          entry.value,
          entry.key,
          'Must be finite and within (0, 1200].',
        );
      }
    }
  }

  final Uint8List _bytes;
  final String? caption;
  final double? widthPoints;
  final double? heightPoints;
  final DocumentImageFit fit;
  final DocumentImageAlignment alignment;

  Uint8List get bytes => Uint8List.fromList(_bytes);
}

/// Opaque QR content supplied by the host. The engine renders but never
/// encrypts, signs, validates, or interprets this payload.
final class DocumentQrCode extends DocumentNode {
  DocumentQrCode({required this.payload, this.caption, this.sizePoints = 96}) {
    if (payload.trim().isEmpty || utf8.encode(payload).length > 2048) {
      throw ArgumentError.value(
        payload,
        'payload',
        'Must contain 1-2048 UTF-8 bytes.',
      );
    }
    if (caption != null && caption!.trim().isEmpty) {
      throw ArgumentError.value(caption, 'caption', 'Must not be empty.');
    }
    if (!sizePoints.isFinite || sizePoints < 48 || sizePoints > 240) {
      throw ArgumentError.value(sizePoints, 'sizePoints', 'Must be 48-240.');
    }
  }

  final String payload;
  final String? caption;
  final double sizePoints;
}

/// A visual/manual signature area. Printed identity and approval references
/// are supplied by the host; this is not a cryptographic digital signature.
final class DocumentSignatureArea extends DocumentNode {
  DocumentSignatureArea({
    required this.label,
    this.signerName,
    this.roleLabel,
    this.approvalReference,
    this.approvedAt,
    Uint8List? visualSignatureBytes,
  }) : _visualSignatureBytes = visualSignatureBytes == null
           ? null
           : Uint8List.fromList(visualSignatureBytes) {
    if (label.trim().isEmpty || label.length > 120) {
      throw ArgumentError.value(label, 'label', 'Must contain 1-120 chars.');
    }
    for (final entry in {
      'signerName': signerName,
      'roleLabel': roleLabel,
      'approvalReference': approvalReference,
    }.entries) {
      if (entry.value != null &&
          (entry.value!.trim().isEmpty || entry.value!.length > 160)) {
        throw ArgumentError.value(
          entry.value,
          entry.key,
          'Invalid text length.',
        );
      }
    }
    if (_visualSignatureBytes != null) {
      final bytes = _visualSignatureBytes;
      if (bytes.isEmpty || bytes.length > 1024 * 1024) {
        throw ArgumentError('Visual signature image must be 1 byte to 1 MiB.');
      }
      final isPng =
          bytes.length >= 8 &&
          bytes[0] == 0x89 &&
          bytes[1] == 0x50 &&
          bytes[2] == 0x4E &&
          bytes[3] == 0x47 &&
          bytes[4] == 0x0D &&
          bytes[5] == 0x0A &&
          bytes[6] == 0x1A &&
          bytes[7] == 0x0A;
      final isJpeg =
          bytes.length >= 3 &&
          bytes[0] == 0xFF &&
          bytes[1] == 0xD8 &&
          bytes[2] == 0xFF;
      if (!isPng && !isJpeg) {
        throw ArgumentError('Visual signature image must be PNG or JPEG.');
      }
    }
  }

  final String label;
  final String? signerName;
  final String? roleLabel;
  final String? approvalReference;
  final DateTime? approvedAt;
  final Uint8List? _visualSignatureBytes;

  Uint8List? get visualSignatureBytes => _visualSignatureBytes == null
      ? null
      : Uint8List.fromList(_visualSignatureBytes);
}
