/// ============================================================================
/// كائن ملخص الدعم الفني الدوميني النقي (MoreSupportSummaryEntity)
/// ============================================================================
/// كائن دوميني نقي يلخص حالة تذاكر الدعم الفني للمستخدم.
class MoreSupportSummaryEntity {
  final int openTicketsCount;
  final String? latestTicketSubject;
  final DateTime? latestTicketDate;

  const MoreSupportSummaryEntity({
    required this.openTicketsCount,
    this.latestTicketSubject,
    this.latestTicketDate,
  });

  bool get hasOpenTickets => openTicketsCount > 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MoreSupportSummaryEntity &&
          runtimeType == other.runtimeType &&
          openTicketsCount == other.openTicketsCount;

  @override
  int get hashCode => openTicketsCount.hashCode;

  @override
  String toString() =>
      'MoreSupportSummaryEntity(openTickets: $openTicketsCount, subject: $latestTicketSubject)';
}
