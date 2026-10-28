import 'package:netsales/features/operations/domain/entities/sales_trend_point_entity.dart';

class SalesTrendPointModel extends SalesTrendPointEntity {
  const SalesTrendPointModel({
    required super.period,
    required super.total,
    required super.count,
  });

  factory SalesTrendPointModel.fromJson(Map<String, dynamic> json) {
    return SalesTrendPointModel(
      period: json['period']?.toString() ?? '',
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }
}
