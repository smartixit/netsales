import 'dart:typed_data';

/// Semantic font roles supplied by the consuming application.
///
/// The engine never downloads fonts or relies on fonts installed on the
/// recipient's device. A host may inject licensed font bytes for the roles
/// that its documents require.
enum DocumentFontRole {
  thin,
  extraLight,
  light,
  body,
  medium,
  semiBold,
  bold,
  heading,
  display,
  numeric,
}

/// Immutable, framework-neutral brand and typography inputs for PDF rendering.
///
/// All binary assets are supplied by the host. The engine validates their
/// format and size, copies the bytes defensively, and never resolves URLs or
/// reads application assets by itself.
final class DocumentBranding {
  DocumentBranding({
    required String organizationName,
    this.tagline,
    this.primaryColor = '0D7A5F',
    this.secondaryColor = '1ABC9C',
    this.accentColor = '2563EB',
    this.surfaceColor = 'F8FAFC',
    this.textColor = '172033',
    this.mutedTextColor = '64748B',
    Uint8List? logoBytes,
    Map<DocumentFontRole, Uint8List> fonts = const {},
  }) : organizationName = _validateText(
         organizationName,
         'organizationName',
         maxLength: 120,
       ),
       _logoBytes = _copyImage(logoBytes),
       _fonts = _copyFonts(fonts) {
    if (tagline != null && (tagline!.trim().isEmpty || tagline!.length > 180)) {
      throw ArgumentError.value(
        tagline,
        'tagline',
        'Must contain 1-180 characters when supplied.',
      );
    }
    _validateColor(primaryColor, 'primaryColor');
    _validateColor(secondaryColor, 'secondaryColor');
    _validateColor(accentColor, 'accentColor');
    _validateColor(surfaceColor, 'surfaceColor');
    _validateColor(textColor, 'textColor');
    _validateColor(mutedTextColor, 'mutedTextColor');

    final totalFontBytes = _fonts.values.fold<int>(
      0,
      (total, bytes) => total + bytes.length,
    );
    if (totalFontBytes > 12 * 1024 * 1024) {
      throw ArgumentError(
        'Combined injected font assets must not exceed 12 MiB.',
      );
    }
  }

  final String organizationName;
  final String? tagline;
  final String primaryColor;
  final String secondaryColor;
  final String accentColor;
  final String surfaceColor;
  final String textColor;
  final String mutedTextColor;
  final Uint8List? _logoBytes;
  final Map<DocumentFontRole, Uint8List> _fonts;

  /// Returns a defensive copy of the logo bytes, if supplied.
  Uint8List? get logoBytes =>
      _logoBytes == null ? null : Uint8List.fromList(_logoBytes);

  /// Font roles supplied by the host.
  Set<DocumentFontRole> get fontRoles =>
      Set<DocumentFontRole>.unmodifiable(_fonts.keys);

  /// Returns a defensive copy of the font asset for [role].
  Uint8List? fontBytes(DocumentFontRole role) {
    final bytes = _fonts[role];
    return bytes == null ? null : Uint8List.fromList(bytes);
  }

  static String _validateText(
    String value,
    String name, {
    required int maxLength,
  }) {
    final normalized = value.trim();
    if (normalized.isEmpty || normalized.length > maxLength) {
      throw ArgumentError.value(
        value,
        name,
        'Must contain 1-$maxLength characters.',
      );
    }
    return normalized;
  }

  static void _validateColor(String value, String name) {
    if (!RegExp(r'^[0-9A-Fa-f]{6}$').hasMatch(value)) {
      throw ArgumentError.value(value, name, 'Use six-digit RGB hex.');
    }
  }

  static Uint8List? _copyImage(Uint8List? source) {
    if (source == null) return null;
    if (source.isEmpty || source.length > 2 * 1024 * 1024) {
      throw ArgumentError('Logo image must be 1 byte to 2 MiB.');
    }
    if (!_isPng(source) && !_isJpeg(source)) {
      throw ArgumentError('Logo image must be PNG or JPEG.');
    }
    return Uint8List.fromList(source);
  }

  static Map<DocumentFontRole, Uint8List> _copyFonts(
    Map<DocumentFontRole, Uint8List> source,
  ) {
    final result = <DocumentFontRole, Uint8List>{};
    for (final entry in source.entries) {
      final bytes = entry.value;
      if (bytes.isEmpty || bytes.length > 4 * 1024 * 1024) {
        throw ArgumentError.value(
          bytes.length,
          'fonts[${entry.key.name}]',
          'Each font asset must be 1 byte to 4 MiB.',
        );
      }
      if (!_isOpenTypeFont(bytes)) {
        throw ArgumentError(
          'Font asset for ${entry.key.name} is not a recognized TrueType/OpenType file.',
        );
      }
      result[entry.key] = Uint8List.fromList(bytes);
    }
    return Map<DocumentFontRole, Uint8List>.unmodifiable(result);
  }

  static bool _isPng(Uint8List bytes) =>
      bytes.length >= 8 &&
      bytes[0] == 0x89 &&
      bytes[1] == 0x50 &&
      bytes[2] == 0x4E &&
      bytes[3] == 0x47 &&
      bytes[4] == 0x0D &&
      bytes[5] == 0x0A &&
      bytes[6] == 0x1A &&
      bytes[7] == 0x0A;

  static bool _isJpeg(Uint8List bytes) =>
      bytes.length >= 3 &&
      bytes[0] == 0xFF &&
      bytes[1] == 0xD8 &&
      bytes[2] == 0xFF;

  static bool _isOpenTypeFont(Uint8List bytes) {
    if (bytes.length < 4) return false;
    final signature = String.fromCharCodes(bytes.sublist(0, 4));
    return signature == 'OTTO' ||
        signature == 'true' ||
        signature == 'typ1' ||
        (bytes[0] == 0x00 &&
            bytes[1] == 0x01 &&
            bytes[2] == 0x00 &&
            bytes[3] == 0x00);
  }
}
