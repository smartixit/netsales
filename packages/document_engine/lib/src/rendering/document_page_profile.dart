/// Physical PDF page geometry, expressed in PDF points (1/72 inch).
enum DocumentPageOrientation { portrait, landscape }

/// Immutable page geometry shared by all rendering backends.
final class DocumentPageProfile {
  DocumentPageProfile({
    required this.widthPoints,
    required this.heightPoints,
    this.orientation = DocumentPageOrientation.portrait,
    this.marginTop = 36,
    this.marginRight = 36,
    this.marginBottom = 36,
    this.marginLeft = 36,
  }) {
    if (!_isPositiveFinite(widthPoints) || !_isPositiveFinite(heightPoints)) {
      throw ArgumentError('Page dimensions must be finite and positive.');
    }
    if (orientation == DocumentPageOrientation.portrait &&
        widthPoints > heightPoints) {
      throw ArgumentError('Portrait pages must be taller than they are wide.');
    }
    if (orientation == DocumentPageOrientation.landscape &&
        widthPoints < heightPoints) {
      throw ArgumentError('Landscape pages must be wider than they are tall.');
    }

    final margins = [marginTop, marginRight, marginBottom, marginLeft];
    if (margins.any((value) => !_isNonNegativeFinite(value))) {
      throw ArgumentError('Page margins must be finite and non-negative.');
    }
    if (marginLeft + marginRight >= widthPoints ||
        marginTop + marginBottom >= heightPoints) {
      throw ArgumentError('Margins must leave a positive printable area.');
    }
  }

  factory DocumentPageProfile.a4Portrait({
    double marginTop = 36,
    double marginRight = 36,
    double marginBottom = 36,
    double marginLeft = 36,
  }) => DocumentPageProfile(
    widthPoints: 595.28,
    heightPoints: 841.89,
    marginTop: marginTop,
    marginRight: marginRight,
    marginBottom: marginBottom,
    marginLeft: marginLeft,
  );

  factory DocumentPageProfile.a4Landscape({
    double marginTop = 36,
    double marginRight = 36,
    double marginBottom = 36,
    double marginLeft = 36,
  }) => DocumentPageProfile(
    widthPoints: 841.89,
    heightPoints: 595.28,
    orientation: DocumentPageOrientation.landscape,
    marginTop: marginTop,
    marginRight: marginRight,
    marginBottom: marginBottom,
    marginLeft: marginLeft,
  );

  /// ISO A5 portrait page (148 × 210 mm), expressed in PDF points.
  factory DocumentPageProfile.a5Portrait({
    double marginTop = 28,
    double marginRight = 28,
    double marginBottom = 28,
    double marginLeft = 28,
  }) => DocumentPageProfile(
    widthPoints: 419.53,
    heightPoints: 595.28,
    marginTop: marginTop,
    marginRight: marginRight,
    marginBottom: marginBottom,
    marginLeft: marginLeft,
  );

  /// ISO A5 landscape page (210 × 148 mm), expressed in PDF points.
  factory DocumentPageProfile.a5Landscape({
    double marginTop = 28,
    double marginRight = 28,
    double marginBottom = 28,
    double marginLeft = 28,
  }) => DocumentPageProfile(
    widthPoints: 595.28,
    heightPoints: 419.53,
    orientation: DocumentPageOrientation.landscape,
    marginTop: marginTop,
    marginRight: marginRight,
    marginBottom: marginBottom,
    marginLeft: marginLeft,
  );

  /// Fixed-height receipt page profile for 58 mm thermal paper.
  /// This controls PDF geometry only; it is not an ESC/POS printer driver.
  factory DocumentPageProfile.receipt58mm({
    required double heightPoints,
    double marginTop = 10,
    double marginRight = 8,
    double marginBottom = 10,
    double marginLeft = 8,
  }) => DocumentPageProfile(
    widthPoints: 58 * 72 / 25.4,
    heightPoints: _validateReceiptHeight(heightPoints),
    marginTop: marginTop,
    marginRight: marginRight,
    marginBottom: marginBottom,
    marginLeft: marginLeft,
  );

  /// Fixed-height receipt page profile for 80 mm thermal paper.
  factory DocumentPageProfile.receipt80mm({
    required double heightPoints,
    double marginTop = 10,
    double marginRight = 8,
    double marginBottom = 10,
    double marginLeft = 8,
  }) => DocumentPageProfile(
    widthPoints: 80 * 72 / 25.4,
    heightPoints: _validateReceiptHeight(heightPoints),
    marginTop: marginTop,
    marginRight: marginRight,
    marginBottom: marginBottom,
    marginLeft: marginLeft,
  );

  factory DocumentPageProfile.letterPortrait({
    double marginTop = 36,
    double marginRight = 36,
    double marginBottom = 36,
    double marginLeft = 36,
  }) => DocumentPageProfile(
    widthPoints: 612,
    heightPoints: 792,
    marginTop: marginTop,
    marginRight: marginRight,
    marginBottom: marginBottom,
    marginLeft: marginLeft,
  );

  final double widthPoints;
  final double heightPoints;
  final DocumentPageOrientation orientation;
  final double marginTop;
  final double marginRight;
  final double marginBottom;
  final double marginLeft;

  static double _validateReceiptHeight(double value) {
    if (!value.isFinite || value < 144 || value > 14400) {
      throw ArgumentError.value(
        value,
        'heightPoints',
        'Must be 144-14400 points.',
      );
    }
    return value;
  }

  static bool _isPositiveFinite(double value) => value.isFinite && value > 0;

  static bool _isNonNegativeFinite(double value) =>
      value.isFinite && value >= 0;
}
