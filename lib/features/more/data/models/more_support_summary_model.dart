import 'package:netsales/features/more/domain/entities/more_support_summary_entity.dart';

/// ============================================================================
/// نموذج بيانات ملخص الدعم الفني (MoreSupportSummaryModel)
/// ============================================================================
/// يرث بالضرورة من الكيان الدوميني [MoreSupportSummaryEntity] طبقاً لقواعد Clean Architecture.
class MoreSupportSummaryModel extends MoreSupportSummaryEntity {
  const MoreSupportSummaryModel({
    required super.openTicketsCount,
    super.latestTicketSubject,
    super.latestTicketDate,
  });

  factory MoreSupportSummaryModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      try {
        return DateTime.tryParse(value.toString());
      } catch (_) {
        return null;
      }
    }

    return MoreSupportSummaryModel(
      openTicketsCount: (json['open_tickets_count'] ?? json['open_count'] ?? 0) as int,
      latestTicketSubject: json['latest_ticket_subject']?.toString(),
      latestTicketDate: parseDate(json['latest_ticket_date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'open_tickets_count': openTicketsCount,
      'latest_ticket_subject': latestTicketSubject,
      if (latestTicketDate != null)
        'latest_ticket_date': latestTicketDate!.toIso8601String(),
    };
  }
}
