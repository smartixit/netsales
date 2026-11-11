/// Typed user-selected values for report criteria.
///
/// Decimal values remain canonical base-10 strings. A filter value is a
/// selection only; it never contains result records or authorization data.
sealed class ReportFilterValue {
  const ReportFilterValue();

  String get type;
  Object? get jsonValue;

  Map<String, Object?> toJson() => <String, Object?>{
    'type': type,
    'value': jsonValue,
  };

  static ReportFilterValue fromJson(Object? json) {
    if (json is! Map<String, Object?>) {
      throw const FormatException('A report filter value must be an object.');
    }
    final type = json['type'];
    final value = json['value'];
    if (type is! String ||
        json.length != 2 ||
        !json.keys.toSet().containsAll({'type', 'value'})) {
      throw const FormatException(
        'A report filter value requires type and value.',
      );
    }

    return switch (type) {
      'text' when value is String => ReportTextFilterValue(value),
      'integer' when value is int => ReportIntegerFilterValue(value),
      'decimal' when value is String => ReportDecimalFilterValue(value),
      'date' when value is String => ReportDateFilterValue(
        DateTime.parse(value),
      ),
      'date_range' when value is Map<String, Object?> =>
        ReportDateRangeFilterValue.fromJson(value),
      'boolean' when value is bool => ReportBooleanFilterValue(value),
      'choice' when value is String => ReportChoiceFilterValue(value),
      'choices'
          when value is List<Object?> &&
              value.every((item) => item is String) =>
        ReportChoicesFilterValue(value.cast<String>()),
      _ => throw FormatException(
        'Unsupported or malformed report filter value type: $type.',
      ),
    };
  }
}

final class ReportTextFilterValue extends ReportFilterValue {
  const ReportTextFilterValue(this.value);
  final String value;
  @override
  String get type => 'text';
  @override
  Object get jsonValue => value;
}

final class ReportIntegerFilterValue extends ReportFilterValue {
  const ReportIntegerFilterValue(this.value);
  final int value;
  @override
  String get type => 'integer';
  @override
  Object get jsonValue => value;
}

final class ReportDecimalFilterValue extends ReportFilterValue {
  ReportDecimalFilterValue(this.value) {
    if (!RegExp(r'^-?(?:0|[1-9][0-9]*)(?:\.[0-9]+)?$').hasMatch(value)) {
      throw ArgumentError.value(
        value,
        'value',
        'Must be a canonical base-10 decimal string.',
      );
    }
  }
  final String value;
  @override
  String get type => 'decimal';
  @override
  Object get jsonValue => value;
}

final class ReportDateFilterValue extends ReportFilterValue {
  const ReportDateFilterValue(this.value);
  final DateTime value;
  @override
  String get type => 'date';
  @override
  Object get jsonValue => value.toIso8601String();
}

final class ReportDateRangeFilterValue extends ReportFilterValue {
  ReportDateRangeFilterValue({required this.start, required this.end}) {
    if (start == null && end == null) {
      throw ArgumentError(
        'A report date range requires at least one boundary.',
      );
    }
    if (start != null && end != null && end!.isBefore(start!)) {
      throw ArgumentError(
        'A report date range end must not precede its start.',
      );
    }
  }

  /// Inclusive lower bound; null represents an open lower boundary.
  final DateTime? start;

  /// Inclusive upper bound; null represents an open upper boundary.
  final DateTime? end;

  factory ReportDateRangeFilterValue.fromJson(Map<String, Object?> value) {
    if (value.length != 2 ||
        (value['start'] != null && value['start'] is! String) ||
        (value['end'] != null && value['end'] is! String) ||
        !value.keys.toSet().containsAll({'start', 'end'})) {
      throw const FormatException('Malformed report date range.');
    }
    final startText = value['start'] as String?;
    final endText = value['end'] as String?;
    return ReportDateRangeFilterValue(
      start: startText == null ? null : DateTime.parse(startText),
      end: endText == null ? null : DateTime.parse(endText),
    );
  }

  @override
  String get type => 'date_range';
  @override
  Object get jsonValue => <String, Object?>{
    'start': start?.toIso8601String(),
    'end': end?.toIso8601String(),
  };
}

final class ReportBooleanFilterValue extends ReportFilterValue {
  const ReportBooleanFilterValue(this.value);
  final bool value;
  @override
  String get type => 'boolean';
  @override
  Object get jsonValue => value;
}

final class ReportChoiceFilterValue extends ReportFilterValue {
  ReportChoiceFilterValue(String value) : value = _validateChoice(value);
  final String value;
  @override
  String get type => 'choice';
  @override
  Object get jsonValue => value;
}

final class ReportChoicesFilterValue extends ReportFilterValue {
  ReportChoicesFilterValue(Iterable<String> values)
    : values = List<String>.unmodifiable(values) {
    if (this.values.toSet().length != this.values.length) {
      throw ArgumentError('A multi-choice value cannot contain duplicates.');
    }
    for (final value in this.values) {
      _validateChoice(value);
    }
  }

  final List<String> values;
  @override
  String get type => 'choices';
  @override
  Object get jsonValue => values;
}

String _validateChoice(String value) {
  if (value.isEmpty || value != value.trim() || value.length > 128) {
    throw ArgumentError.value(
      value,
      'value',
      'Choice values must be 1-128 trimmed characters.',
    );
  }
  return value;
}
