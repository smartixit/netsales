import 'package:equatable/equatable.dart';

/// كيان ملخص وإحصائيات المصروفات التشغيلية (Expense Summary Entity)
class ExpenseSummaryEntity extends Equatable {
  const ExpenseSummaryEntity({
    required this.totalCount,
    required this.totalAmount,
    required this.thisMonthAmount,
    required this.todayAmount,
  });

  final int totalCount;
  final double totalAmount;
  final double thisMonthAmount;
  final double todayAmount;

  @override
  List<Object?> get props => [
        totalCount,
        totalAmount,
        thisMonthAmount,
        todayAmount,
      ];
}
