import 'package:netsales/features/requests/domain/entities/request_modification_summary_entity.dart';

/// DTO لملخص تعديلات الطلب الذي يرسله Laravel عند توفر الفاتورة المرتبطة.
class RequestModificationSummaryModel extends RequestModificationSummaryEntity {
  const RequestModificationSummaryModel({
    required super.hasModifications,
    required super.originalTotal,
    required super.approvedTotal,
    required super.originalItemsCount,
    required super.approvedItemsCount,
  });

  factory RequestModificationSummaryModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return RequestModificationSummaryModel(
      hasModifications: json['has_modifications'] as bool? ?? false,
      originalTotal: (json['original_total'] as num?)?.toDouble() ?? 0,
      approvedTotal: (json['approved_total'] as num?)?.toDouble() ?? 0,
      originalItemsCount: json['original_items_count'] as int? ?? 0,
      approvedItemsCount: json['approved_items_count'] as int? ?? 0,
    );
  }
}
