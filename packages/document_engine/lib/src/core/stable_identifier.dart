/// Validates identifiers used to address document and template definitions.
String validateStableIdentifier(String value, {required String parameterName}) {
  final valid =
      value.isNotEmpty &&
      value == value.trim() &&
      value.length <= 128 &&
      RegExp(r'^[A-Za-z0-9][A-Za-z0-9._:-]*$').hasMatch(value);

  if (!valid) {
    throw ArgumentError.value(
      value,
      parameterName,
      'Must be 1-128 characters, start with a letter or digit, and contain '
      'only letters, digits, ".", "_", ":", or "-".',
    );
  }

  return value;
}
