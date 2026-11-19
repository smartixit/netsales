import 'package:netsales/features/expenses/domain/entities/expense_summary_entity.dart';

/// نموذج بيانات ملخص المصروفات التشغيلية من الـ API
class ExpenseSummaryModel extends ExpenseSummaryEntity {
  const ExpenseSummaryModel({
    required super.totalCount,
    required super.totalAmount,
    required super.thisMonthAmount,
    required super.todayAmount,
  });

  factory ExpenseSummaryModel.fromJson(Map<String, dynamic> json) {
    return ExpenseSummaryModel(
      totalCount: (json['total_count'] as num?)?.toInt() ?? 0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      thisMonthAmount: (json['this_month_amount'] as num?)?.toDouble() ?? 0.0,
      todayAmount: (json['today_amount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_count': totalCount,
      'total_amount': totalAmount,
      'this_month_amount': thisMonthAmount,
      'today_amount': todayAmount,
    };
  }
}
