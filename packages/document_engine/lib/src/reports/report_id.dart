import '../core/stable_identifier.dart';

/// Stable application-defined report schema identity.
final class ReportId implements Comparable<ReportId> {
  ReportId(String value)
    : value = validateStableIdentifier(value, parameterName: 'reportId');

  final String value;

  @override
  int compareTo(ReportId other) => value.compareTo(other.value);

  @override
  bool operator ==(Object other) => other is ReportId && other.value == value;

  @override
  int get hashCode => Object.hash(ReportId, value);

  @override
  String toString() => value;
}
