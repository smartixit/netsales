import 'dart:typed_data';

/// Copies an iterable while enforcing a hard upper bound before materializing
/// the complete collection.
List<T> copyBoundedDocumentList<T>(
  Iterable<T> values, {
  required int maxLength,
  required String fieldName,
}) {
  if (maxLength < 1) {
    throw ArgumentError.value(maxLength, 'maxLength', 'Must be positive.');
  }

  final result = <T>[];
  for (final value in values) {
    if (result.length == maxLength) {
      throw ArgumentError.value(
        result.length + 1,
        fieldName,
        'Must contain at most $maxLength entries.',
      );
    }
    result.add(value);
  }
  return List<T>.unmodifiable(result);
}

/// Validates asset size before making a defensive copy.
Uint8List copyBoundedDocumentBytes(
  Uint8List bytes, {
  required int maxBytes,
  required String fieldName,
}) {
  if (maxBytes < 1) {
    throw ArgumentError.value(maxBytes, 'maxBytes', 'Must be positive.');
  }
  if (bytes.isEmpty || bytes.length > maxBytes) {
    throw ArgumentError.value(
      bytes.length,
      fieldName,
      'Must contain 1-$maxBytes bytes.',
    );
  }
  return Uint8List.fromList(bytes);
}
