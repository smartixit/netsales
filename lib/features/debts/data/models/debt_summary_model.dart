import 'package:netsales/features/debts/domain/entities/debt_summary_entity.dart';

class AgingSummaryModel extends AgingSummaryEntity {
  const AgingSummaryModel({
    required super.bucket0To30,
    required super.bucket31To60,
    required super.bucket61To90,
    required super.bucketOver90,
    required super.total,
  });

  factory AgingSummaryModel.fromJson(Map<String, dynamic> json) {
    double parseAmount(dynamic val) {
      if (val is num) return val.toDouble();
      return double.tryParse(val?.toString() ?? '') ?? 0.0;
    }

    return AgingSummaryModel(
      bucket0To30: parseAmount(json['0-30']),
      bucket31To60: parseAmount(json['31-60']),
      bucket61To90: parseAmount(json['61-90']),
      bucketOver90: parseAmount(json['>90']),
      total: parseAmount(json['total']),
    );
  }
}

class PosDebtBreakdownModel extends PosDebtBreakdownEntity {
  const PosDebtBreakdownModel({
    required super.posId,
    required super.posName,
    required super.outstandingDebt,
    required super.unpaidInvoicesCount,
    super.creditLimit,
    super.agingSummary,
  });

  factory PosDebtBreakdownModel.fromJson(Map<String, dynamic> json) {
    double parseAmount(dynamic val) {
      if (val is num) return val.toDouble();
      return double.tryParse(val?.toString() ?? '') ?? 0.0;
    }

    double? parseLimit(dynamic val) {
      if (val == null) return null;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString());
    }

    final agingMap = json['aging_summary'] is Map ? Map<String, dynamic>.from(json['aging_summary'] as Map) : null;

    return PosDebtBreakdownModel(
      posId: (json['pos_id'] as num?)?.toInt() ?? 0,
      posName: json['pos_name']?.toString() ?? 'نقطة بيع',
      outstandingDebt: parseAmount(json['outstanding_debt']),
      unpaidInvoicesCount: (json['unpaid_invoices_count'] as num?)?.toInt() ?? 0,
      creditLimit: parseLimit(json['credit_limit']),
      agingSummary: agingMap != null ? AgingSummaryModel.fromJson(agingMap) : null,
    );
  }
}

class PosDebtSummaryModel extends PosDebtSummaryEntity {
  const PosDebtSummaryModel({
    required super.totalOutstandingDebt,
    required super.unpaidInvoicesCount,
    required super.agingSummary,
    required super.posBreakdown,
  });

  factory PosDebtSummaryModel.fromJson(Map<String, dynamic> json) {
    double parseAmount(dynamic val) {
      if (val is num) return val.toDouble();
      return double.tryParse(val?.toString() ?? '') ?? 0.0;
    }

    final agingMap = json['aging_summary'] is Map ? Map<String, dynamic>.from(json['aging_summary'] as Map) : <String, dynamic>{};
    final breakdownList = json['pos_breakdown'] is List ? (json['pos_breakdown'] as List<dynamic>) : const <dynamic>[];

    return PosDebtSummaryModel(
      totalOutstandingDebt: parseAmount(json['total_outstanding_debt']),
      unpaidInvoicesCount: (json['unpaid_invoices_count'] as num?)?.toInt() ?? 0,
      agingSummary: AgingSummaryModel.fromJson(agingMap),
      posBreakdown: breakdownList
          .whereType<Map<dynamic, dynamic>>()
          .map((item) => PosDebtBreakdownModel.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }
}
