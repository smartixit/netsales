// ============================================================================
// كائنات سندات سداد المديونية وتوزيعاتها (PosRepayment & Allocations Entities)
// ============================================================================

class PosRepaymentAllocationEntity {
  final int allocationId;
  final int repaymentId;
  final int invoiceId;
  final String? invoiceUuid;
  final double allocatedAmount;
  final String status;
  final DateTime allocatedAt;

  const PosRepaymentAllocationEntity({
    required this.allocationId,
    required this.repaymentId,
    required this.invoiceId,
    this.invoiceUuid,
    required this.allocatedAmount,
    required this.status,
    required this.allocatedAt,
  });

  bool get isReversed => status.toUpperCase() == 'REVERSED';
}

class PosRepaymentEntity {
  final int repaymentId;
  final String repaymentUuid;
  final int networkId;
  final int posId;
  final String? posName;
  final double amount;
  final String paymentMethod;
  final String? referenceNumber;
  final String? notes;
  final DateTime repaymentDate;
  final String status;
  final int createdBy;
  final DateTime? reversedAt;
  final int? reversedBy;
  final String? reversalReason;
  final List<PosRepaymentAllocationEntity> allocations;
  final DateTime createdAt;

  const PosRepaymentEntity({
    required this.repaymentId,
    required this.repaymentUuid,
    required this.networkId,
    required this.posId,
    this.posName,
    required this.amount,
    required this.paymentMethod,
    this.referenceNumber,
    this.notes,
    required this.repaymentDate,
    required this.status,
    required this.createdBy,
    this.reversedAt,
    this.reversedBy,
    this.reversalReason,
    required this.allocations,
    required this.createdAt,
  });

  bool get isReversed => status.toUpperCase() == 'REVERSED';
}
