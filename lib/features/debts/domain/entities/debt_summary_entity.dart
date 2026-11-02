// ============================================================================
// كيانات ملخص الديون وأعمار الذمم (Debt Summary & Aging Entities) — M4-C
// ============================================================================

class AgingSummaryEntity {
  final double bucket0To30;
  final double bucket31To60;
  final double bucket61To90;
  final double bucketOver90;
  final double total;

  const AgingSummaryEntity({
    required this.bucket0To30,
    required this.bucket31To60,
    required this.bucket61To90,
    required this.bucketOver90,
    required this.total,
  });

  double get percentage0To30 => total > 0 ? (bucket0To30 / total) * 100 : 0.0;
  double get percentage31To60 => total > 0 ? (bucket31To60 / total) * 100 : 0.0;
  double get percentage61To90 => total > 0 ? (bucket61To90 / total) * 100 : 0.0;
  double get percentageOver90 => total > 0 ? (bucketOver90 / total) * 100 : 0.0;
}

class PosDebtBreakdownEntity {
  final int posId;
  final String posName;
  final double outstandingDebt;
  final int unpaidInvoicesCount;
  final double? creditLimit;
  final AgingSummaryEntity? agingSummary;

  const PosDebtBreakdownEntity({
    required this.posId,
    required this.posName,
    required this.outstandingDebt,
    required this.unpaidInvoicesCount,
    this.creditLimit,
    this.agingSummary,
  });

  bool get hasCreditFacility => creditLimit != null;
  double get availableLimit => creditLimit != null ? (creditLimit! - outstandingDebt) : 0.0;
}

class PosDebtSummaryEntity {
  final double totalOutstandingDebt;
  final int unpaidInvoicesCount;
  final AgingSummaryEntity agingSummary;
  final List<PosDebtBreakdownEntity> posBreakdown;

  const PosDebtSummaryEntity({
    required this.totalOutstandingDebt,
    required this.unpaidInvoicesCount,
    required this.agingSummary,
    required this.posBreakdown,
  });
}
