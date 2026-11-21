import 'package:netsales/features/expenses/domain/entities/expense_summary_entity.dart';

/// نموذج بيانات ملخص وإحصائيات المصروفات (ExpenseSummaryModel)
///
/// يطابق تمثيل الـ JSON الصادر من نقطة نهاية `GET /api/v1/expenses/summary`.
class ExpenseSummaryModel extends ExpenseSummaryEntity {
  const ExpenseSummaryModel({
    super.totalCount = 0,
    super.totalAmount = 0.0,
    super.thisMonthAmount = 0.0,
    super.todayAmount = 0.0,
  });

  factory ExpenseSummaryModel.fromJson(Map<String, dynamic> json) {
    return ExpenseSummaryModel(
      totalCount: json['total_count'] is int
          ? json['total_count'] as int
          : int.tryParse(json['total_count']?.toString() ?? '0') ?? 0,
      totalAmount: json['total_amount'] is num
          ? (json['total_amount'] as num).toDouble()
          : double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0.0,
      thisMonthAmount: json['this_month_amount'] is num
          ? (json['this_month_amount'] as num).toDouble()
          : double.tryParse(json['this_month_amount']?.toString() ?? '0') ??
                0.0,
      todayAmount: json['today_amount'] is num
          ? (json['today_amount'] as num).toDouble()
          : double.tryParse(json['today_amount']?.toString() ?? '0') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'total_count': totalCount,
    'total_amount': totalAmount,
    'this_month_amount': thisMonthAmount,
    'today_amount': todayAmount,
  };
}
