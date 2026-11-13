/// Human-readable representation of one active report criterion.
///
/// Values are presentation metadata only. The typed [ReportCriteria] remains
/// the request contract used for server-side filtering.
class OperationalReportFilterDisplay {
  const OperationalReportFilterDisplay({
    required this.id,
    required this.label,
    required this.value,
  });

  final String id;
  final String label;
  final String value;
}
