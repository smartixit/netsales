/// Reading direction requested for a document or individual text run.
enum DocumentTextDirection { leftToRight, rightToLeft, auto }

/// Locale metadata supplied by the consuming application.
///
/// The engine records the BCP-47-style language tag and direction. It does not
/// perform localization or infer locale from the operating system.
final class DocumentLocale {
  DocumentLocale({required String languageTag, required this.direction})
    : languageTag = _validateLanguageTag(languageTag);

  final String languageTag;
  final DocumentTextDirection direction;

  static String _validateLanguageTag(String value) {
    final normalized = value.trim();
    final valid =
        normalized == value &&
        RegExp(r'^[A-Za-z]{2,8}(?:-[A-Za-z0-9]{1,8})*$').hasMatch(normalized);

    if (!valid) {
      throw ArgumentError.value(
        value,
        'languageTag',
        'Must be a valid language tag such as "ar", "ar-YE", or "en-US".',
      );
    }

    return normalized;
  }

  @override
  bool operator ==(Object other) =>
      other is DocumentLocale &&
      other.languageTag == languageTag &&
      other.direction == direction;

  @override
  int get hashCode => Object.hash(languageTag, direction);
}
