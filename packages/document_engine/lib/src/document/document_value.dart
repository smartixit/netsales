/// Typed values accepted by the generic document content model.
///
/// Decimal values are preserved as base-10 strings. They are never converted
/// to floating-point numbers or used for financial calculations.
sealed class DocumentValue {
  const DocumentValue();
}

final class DocumentTextValue extends DocumentValue {
  const DocumentTextValue(this.value);

  final String value;
}

final class DocumentIntegerValue extends DocumentValue {
  const DocumentIntegerValue(this.value);

  final int value;
}

final class DocumentDecimalValue extends DocumentValue {
  DocumentDecimalValue(String value) : value = _validate(value);

  final String value;

  static String _validate(String value) {
    if (!RegExp(r'^-?(?:0|[1-9][0-9]*)(?:\.[0-9]+)?$').hasMatch(value)) {
      throw ArgumentError.value(
        value,
        'value',
        'Must be a canonical base-10 decimal string without grouping or exponent notation.',
      );
    }
    return value;
  }
}

final class DocumentDateTimeValue extends DocumentValue {
  const DocumentDateTimeValue(this.value);

  final DateTime value;
}

final class DocumentBooleanValue extends DocumentValue {
  const DocumentBooleanValue(this.value);

  final bool value;
}
