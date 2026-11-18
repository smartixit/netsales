/// كيان ملخص حالات طلبات التوريد المعتمد من الخادم
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

  static const empty = RequestStatusSummaryEntity(
    total: 0,
    pending: 0,
    approved: 0,
    rejected: 0,
    cancelled: 0,
  );
}
