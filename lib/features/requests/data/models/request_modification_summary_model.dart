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
    final hasModifications = json['has_modifications'];
    final originalTotal = json['original_total'];
    final approvedTotal = json['approved_total'];
    final originalItemsCount = json['original_items_count'];
    final approvedItemsCount = json['approved_items_count'];

    if (hasModifications is! bool ||
        originalTotal is! num ||
        approvedTotal is! num ||
        originalItemsCount is! int ||
        approvedItemsCount is! int) {
      throw const FormatException(
        'ملخص تعديلات الطلب لا يحتوي على الحقول المطلوبة بالأنواع الصحيحة.',
      );
    }

    return RequestModificationSummaryModel(
      hasModifications: hasModifications,
      originalTotal: originalTotal.toDouble(),
      approvedTotal: approvedTotal.toDouble(),
      originalItemsCount: originalItemsCount,
      approvedItemsCount: approvedItemsCount,
    );
  }
}
