import 'package:netsales/features/requests/domain/entities/request_status_summary_entity.dart';

/// نموذج بيانات ملخص حالات طلبات التوريد القادم من الخادم عبر GET /api/v1/requests/summary
class RequestStatusSummaryModel extends RequestStatusSummaryEntity {
  const RequestStatusSummaryModel({
    required super.total,
    required super.pending,
    required super.approved,
    required super.rejected,
    required super.cancelled,
  });

  factory RequestStatusSummaryModel.fromJson(Map<String, dynamic> json) {
    return RequestStatusSummaryModel(
      total: (json['total'] as num?)?.toInt() ?? 0,
      pending: (json['pending'] as num?)?.toInt() ?? 0,
      approved: (json['approved'] as num?)?.toInt() ?? 0,
      rejected: (json['rejected'] as num?)?.toInt() ?? 0,
      cancelled: (json['cancelled'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'pending': pending,
      'approved': approved,
      'rejected': rejected,
      'cancelled': cancelled,
    };
  }
}
