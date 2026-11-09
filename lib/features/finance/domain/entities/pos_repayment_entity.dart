import 'package:netsales/features/finance/domain/entities/repayment_allocation_invoice_entity.dart';
import 'package:netsales/features/finance/domain/entities/repayment_payment_method.dart';

/// كيان توزيع سداد الديون على فاتورة محددة وفق أسبقية FIFO.
class RepaymentAllocationEntity {
  final int allocationId;
  final int repaymentId;
  final int invoiceId;
  final int networkId;
  final int posId;
  final double allocatedAmount;
  final String? status;
  final String? allocatedAt;
  final RepaymentAllocationInvoiceEntity invoice;

  const RepaymentAllocationEntity({
    required this.allocationId,
    required this.repaymentId,
    required this.invoiceId,
    required this.networkId,
    required this.posId,
    required this.allocatedAmount,
    required this.invoice,
    this.status,
    this.allocatedAt,
  });
}

/// كيان سند سداد مديونية نقطة البيع.
class PosRepaymentEntity {
  final int repaymentId;
  final String? repaymentUuid;
  final int networkId;
  final int posId;
  final double amount;
  final String? paymentMethod;
  final String? referenceNumber;
  final String? notes;
  final String? repaymentDate;
  final String? status;
  final int? createdBy;
  final String? reversedAt;
  final int? reversedBy;
  final String? reversalReason;
  final int? reversalRepaymentId;
  final String? createdAt;
  final String? networkName;
  final String? posName;
  final List<RepaymentAllocationEntity> allocations;

  const PosRepaymentEntity({
    required this.repaymentId,
    this.repaymentUuid,
    required this.networkId,
    required this.posId,
    required this.amount,
    this.paymentMethod,
    this.referenceNumber,
    this.notes,
    this.repaymentDate,
    this.status,
    this.createdBy,
    this.reversedAt,
    this.reversedBy,
    this.reversalReason,
    this.reversalRepaymentId,
    this.createdAt,
    this.networkName,
    this.posName,
    this.allocations = const [],
  });

  RepaymentPaymentMethod get typedPaymentMethod =>
      RepaymentPaymentMethod.fromWire(paymentMethod);

  bool get isCompleted => status == 'COMPLETED';
  bool get isReversed => status == 'REVERSED';
}
