import 'package:netsales/features/requests/domain/entities/request_status_summary_entity.dart';

class RequestStatusSummaryModel extends RequestStatusSummaryEntity {
  const RequestStatusSummaryModel({
    required super.total,
    required super.pending,
    required super.approved,
    required super.rejected,
    required super.cancelled,
  });

  factory RequestStatusSummaryModel.fromJson(Map<String, dynamic> json) {
    int readCount(String key) {
      final value = json[key];
      if (value is int) return value;
      if (value is num) return value.toInt();
      throw FormatException('Invalid request summary count: $key');
    }

    return RequestStatusSummaryModel(
      total: readCount('total'),
      pending: readCount('pending'),
      approved: readCount('approved'),
      rejected: readCount('rejected'),
      cancelled: readCount('cancelled'),
    );
  }
}
