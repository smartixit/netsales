import 'stable_identifier.dart';

/// Stable identity of an application-registered document template.
final class TemplateId implements Comparable<TemplateId> {
  TemplateId(String value)
    : value = validateStableIdentifier(value, parameterName: 'templateId');

  final String value;

  @override
  int compareTo(TemplateId other) => value.compareTo(other.value);

  @override
  bool operator ==(Object other) => other is TemplateId && other.value == value;

  @override
  int get hashCode => Object.hash(TemplateId, value);

  @override
  String toString() => value;
}
