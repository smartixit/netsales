/// Server-computed lifecycle counts for the complete authorized request scope.
class RequestStatusSummaryEntity {
  const RequestStatusSummaryEntity({
    required this.total,
    required this.pending,
    required this.approved,
    required this.rejected,
    required this.cancelled,
  });

  final int total;
  final int pending;
  final int approved;
  final int rejected;
  final int cancelled;
}
